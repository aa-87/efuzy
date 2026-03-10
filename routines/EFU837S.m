EFU837S ; efuzy X12 837 streaming scanner
 ;
 ; Public:
 ;   DETECT(PATH,.DEL,.ERR)
 ;   OPEN(PATH,.SCAN,.OPT,.ERR)
 ;   NEXT(.SCAN,.SEG,.EOF,.ERR)
 ;   CLOSE(.SCAN)
 ;
 ; Notes:
 ;   - supports full ISA-framed interchanges
 ;   - supports transaction-only samples that begin at ST
 ;   - keeps only a rolling scalar buffer, not the full file
 ;   - restores the caller's current device after file work
 ;
 Q
 ;
DETECT(PATH,DEL,ERR) ; detect delimiters from ISA or transaction sample
 N DEV,HDR,OLDIO
 K DEL S ERR=0
 I $G(PATH)="" S ERR=1 Q
 S DEV=PATH,OLDIO=$IO,HDR=""
 O DEV:(READONLY:STREAM):1
 I '$T S ERR=1 Q
 D READHDR(DEV,2048,.HDR,.ERR)
 C DEV
 U OLDIO
 I +$G(ERR) Q
 I HDR="" S ERR=1 Q
 D LTRIM(.HDR)
 I $L(HDR)<3 S ERR=1 Q
 I $E(HDR,1,3)="ISA" D DETECTISA(.HDR,.DEL,.ERR) Q
 D DETECTTX(.HDR,.DEL,.ERR)
 Q
 ;
READHDR(DEV,MAX,HDR,ERR) ; safe bounded header read
 N C,ATEOF,READERR,TMO,$ETRAP,$ESTACK
 S HDR="",ERR=0
 F  Q:$L(HDR)'<+$G(MAX)  D  Q:ATEOF!(READERR)
 . S C="",ATEOF=0,READERR=0,TMO=0
 . S $ETRAP="D RDERR^EFU837S"
 . U DEV R C#1:1
 . S TMO='$T
 . S $ETRAP=""
 . I READERR S ERR=1 Q
 . I ATEOF Q
 . I TMO S ATEOF=1 Q
 . I C="" S ATEOF=1 Q
 . S HDR=HDR_C
 Q
 ;
DETECTISA(HDR,DEL,ERR) ; fixed-width ISA detection
 K DEL S ERR=0
 I $L(HDR)<106 S ERR=1 Q
 S DEL("elem")=$E(HDR,4)
 S DEL("rep")=$E(HDR,83)
 S DEL("comp")=$E(HDR,105)
 S DEL("seg")=$E(HDR,106)
 S DEL("framing")="interchange"
 S DEL("has_isa")=1
 Q
 ;
DETECTTX(HDR,DEL,ERR) ; fallback detection for ST-first samples
 N POS,TERM,ELEM
 K DEL S ERR=0
 S ELEM=$$ESEP(HDR)
 I ELEM="" S ELEM="*"
 S TERM=$$TERM(HDR)
 I TERM="" S TERM="~"
 S DEL("elem")=ELEM
 S DEL("seg")=TERM
 S DEL("comp")=":"
 S DEL("rep")="^"
 S DEL("framing")="transaction"
 S DEL("has_isa")=0
 S POS=$F(HDR,TERM)
 I POS>0 D
 . I $E(HDR,1,POS-2)[":" S DEL("comp")=":" Q
 . I $E(HDR,1,POS-2)[">" S DEL("comp")=">" Q
 Q
 ;
ESEP(HDR) ; infer element separator from first segment
 N I,C
 S C=""
 F I=1:1:$L(HDR) D  Q:C'=""
 . S C=$E(HDR,I)
 . I (C=" ")!(C=$C(9))!(C=$C(10))!(C=$C(13)) S C="" Q
 . I C?1A!(C?1N) S C="" Q
 Q C
 ;
TERM(HDR) ; infer segment terminator from early bytes
 N P1,P2,P3,P
 S P1=$F(HDR,"~") I 'P1 S P1=999999
 S P2=$F(HDR,$C(10)) I 'P2 S P2=999999
 S P3=$F(HDR,$C(13)) I 'P3 S P3=999999
 S P=P1 I P2<P S P=P2
 I P3<P S P=P3
 I P=999999 Q ""
 Q $E(HDR,P-1)
 ;
LTRIM(HDR) ; strip leading BOM/CR/LF/SP/TAB safely
 I $E(HDR,1,3)=$C(239,187,191) S HDR=$E(HDR,4,$L(HDR))
 F  Q:HDR=""  Q:$E(HDR,1)'=$C(10)  S HDR=$E(HDR,2,$L(HDR))
 F  Q:HDR=""  Q:$E(HDR,1)'=$C(13)  S HDR=$E(HDR,2,$L(HDR))
 F  Q:HDR=""  Q:$E(HDR,1)'=" "  S HDR=$E(HDR,2,$L(HDR))
 F  Q:HDR=""  Q:$E(HDR,1)'=$C(9)  S HDR=$E(HDR,2,$L(HDR))
 Q
 ;
OPEN(PATH,SCAN,OPT,ERR) ; open stream and initialize buffer state
 N DEV,DEL
 K SCAN S ERR=0
 D DETECT(PATH,.DEL,.ERR)
 I +$G(ERR) Q
 M SCAN("del")=DEL
 S SCAN("path")=PATH
 S SCAN("dev")=PATH
 S SCAN("oldio")=$IO
 S SCAN("chunk")=$S(+$G(OPT("chunk"))>0:+$G(OPT("chunk")),1:8192)
 S SCAN("buf")=""
 S SCAN("segno")=0
 S SCAN("eof")=0
 S DEV=SCAN("dev")
 O DEV:(READONLY:STREAM):1
 I '$T S ERR=1 Q
 U DEV
 Q
 ;
NEXT(SCAN,SEG,EOF,ERR) ; next segment without terminator
 N DEV,POS,CHUNK,TERM,ATEOF,READERR,TMO,$ETRAP,$ESTACK
 S SEG="",EOF=0,ERR=0
 S DEV=$G(SCAN("dev"))
 S TERM=$G(SCAN("del","seg"))
 I TERM="" S ERR=1 Q
 F  D  Q:SEG'=""!(EOF)!(ERR)
 . D STRIP(.SCAN)
 . S POS=$F($G(SCAN("buf")),TERM)
 . I POS>0 D  Q
 . . S SEG=$E(SCAN("buf"),1,POS-2)
 . . S SCAN("buf")=$E(SCAN("buf"),POS,$L(SCAN("buf")))
 . . D STRIPSEG(.SEG)
 . . I SEG'="" S SCAN("segno")=+$G(SCAN("segno"))+1
 . I +$G(SCAN("eof")) D  Q
 . . I $G(SCAN("buf"))'="" D
 . . . S SEG=SCAN("buf")
 . . . S SCAN("buf")=""
 . . . D STRIPSEG(.SEG)
 . . . I SEG'="" S SCAN("segno")=+$G(SCAN("segno"))+1
 . . E  S EOF=1
 . S CHUNK="",ATEOF=0,READERR=0,TMO=0
 . S $ETRAP="D RDERR^EFU837S"
 . U DEV R CHUNK#SCAN("chunk"):1
 . S TMO='$T
 . S $ETRAP=""
 . I READERR S ERR=1 Q
 . I ATEOF!(TMO) S SCAN("eof")=1 Q
 . I CHUNK'="" S SCAN("buf")=$G(SCAN("buf"))_CHUNK Q
 . I $ZEOF!(CHUNK="") S SCAN("eof")=1 Q
 . S ERR=1
 Q
 ;
RDERR ; read error trap helper for DETECT/NEXT
 I $ZSTATUS["IOEOF" S ATEOF=1,$ECODE="" Q
 S READERR=1,ERR=1,$ECODE="" Q
 ;
STRIP(SCAN) ; strip CR/LF between segments
 N C
 F  Q:$G(SCAN("buf"))=""  D  Q:(C'=$C(10))&(C'=$C(13))
 . S C=$E(SCAN("buf"),1)
 . I (C=$C(10))!(C=$C(13)) S SCAN("buf")=$E(SCAN("buf"),2,$L(SCAN("buf")))
 Q
 ;
STRIPSEG(SEG) ; strip CR/LF around segment payload
 F  Q:SEG=""  Q:$E(SEG,1)'=$C(10)  S SEG=$E(SEG,2,$L(SEG))
 F  Q:SEG=""  Q:$E(SEG,1)'=$C(13)  S SEG=$E(SEG,2,$L(SEG))
 F  Q:SEG=""  Q:$E(SEG,$L(SEG))'=$C(10)  S SEG=$E(SEG,1,$L(SEG)-1)
 F  Q:SEG=""  Q:$E(SEG,$L(SEG))'=$C(13)  S SEG=$E(SEG,1,$L(SEG)-1)
 Q
 ;
CLOSE(SCAN) ; close scan device and restore prior current device
 N DEV,OLDIO
 S DEV=$G(SCAN("dev")),OLDIO=$G(SCAN("oldio"))
 I DEV'="" C DEV
 I OLDIO'="" U OLDIO
 K SCAN
 Q
 ;
