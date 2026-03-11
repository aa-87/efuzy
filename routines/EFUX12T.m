EFUX12T ; efuzy additive X12 coverage and conversion suite
 ;
 ; Purpose
 ;   Add broader external-file coverage without destabilizing EFU837T.
 ;   This suite is grounded in the real Example 1 / Example 2 trees.
 ;
 ; Public
 ;   START
 ;   ALL(BASE)
 ;   STRICT837(BASE)
 ;
 ; Notes
 ;   - quiet on success
 ;   - BASE should point to the directory that contains
 ;       Examples_1 / Examples_2
 ;     or
 ;       Examples 1 / Examples 2
 ;   - This suite covers:
 ;       * raw 837 Example 1 and Example 2 coverage
 ;       * conversion-ready 837 X12->CSV row-count checks
 ;       * raw smoke coverage for other X12 types in Example 1
 ;   - Exact byte-for-byte CSV compare is intentionally NOT enforced here.
 ;     The current compact exporter schema is much narrower than the
 ;     vendor benchmark CSV schema in Example 1.
 ;
 D START
 Q
 ;
START ;
 N BASE
 S BASE=$$AUTBASE()
 D ALL(BASE)
 Q
 ;
ALL(BASE) ;
 N FAIL,RBASE
 S FAIL=0
 S RBASE=$$RESBASE($G(BASE))
 I RBASE="" S RBASE=$$AUTBASE()
 I RBASE="" D FAILBASE(.FAIL,$G(BASE)) Q
 D T300(.FAIL,RBASE)
 D T301(.FAIL,RBASE)
 D T302(.FAIL,RBASE)
 D T310(.FAIL,RBASE)
 D T320(.FAIL,RBASE)
 I 'FAIL W !,"OK - EFUX12T"
 Q
 ;
STRICT837(BASE) ; conversion-focused 837 benchmark suite
 N FAIL,RBASE
 S FAIL=0
 S RBASE=$$RESBASE($G(BASE))
 I RBASE="" S RBASE=$$AUTBASE()
 I RBASE="" D FAILBASE(.FAIL,$G(BASE)) Q
 D T301(.FAIL,RBASE)
 I 'FAIL W !,"OK - EFUX12T STRICT837"
 Q
 ;
T300(FAIL,BASE) ; Example 1 837 raw structure coverage
 N I,REC,FILE,KIND,GUIDE,CLAIMS,LINES,LAB,PATH,RAW,EX
 F I=1:1 S REC=$P($T(EX1837+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . S FILE=$P(REC,"|",1),KIND=$P(REC,"|",2),GUIDE=$P(REC,"|",3)
 . S CLAIMS=+$P(REC,"|",4),LINES=+$P(REC,"|",5)
 . S PATH=$$EX1SRCF(BASE,FILE),LAB="[T300]["_FILE_"]",EX=$S(PATH'="":1,1:0)
 . D EQ(.FAIL,LAB_"[source exists]",EX,1)
 . I 'EX Q
 . D RAWMETA(PATH,.RAW)
 . D EQ(.FAIL,LAB_"[raw ok]",+$G(RAW("ok")),1)
 . I '+$G(RAW("ok")) Q
 . D EQ(.FAIL,LAB_"[st]",$G(RAW("st")),"837")
 . D EQ(.FAIL,LAB_"[kind]",$G(RAW("kind")),KIND)
 . D EQ(.FAIL,LAB_"[guide]",$$GUIDEOK($G(RAW("guide")),GUIDE),1)
 . D EQ(.FAIL,LAB_"[claims]",+$G(RAW("claims")),CLAIMS)
 . D EQ(.FAIL,LAB_"[lines]",+$G(RAW("lines")),LINES)
 Q
 ;
T301(FAIL,BASE) ; conversion-ready Example 1 837 X12->CSV row-count checks
 N I,REC,FILE,PATH,OUTBASE,ROOT,RES,LAB,BC,BCL,BL
 N OPT,STEM
 F I=1:1 S REC=$P($T(BENCH837+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . S FILE=$P(REC,"|",1),LAB="[T301]["_FILE_"]"
 . S PATH=$$EX1SRCF(BASE,FILE)
 . D EQ(.FAIL,LAB_"[source exists]",$S(PATH'="":1,1:0),1)
 . I PATH="" Q
 . K OPT S OPT("lenient")=1,OPT("accept_bad_envelope")=1
 . S STEM=$$NOEXT^EFU837U(FILE)
 . S OUTBASE=$$TMPBASE(STEM)
 . S ROOT=$NA(^TMP($J,"EFUX12T","EXP",I))
 . D EXPORT^EFU837CSV(PATH,OUTBASE,ROOT,.OPT,.RES)
 . D EQ(.FAIL,LAB_"[export ok]",+$G(RES("ok")),1)
 . I '+$G(RES("ok")) Q
 . S BC=$$EX1BENCH(BASE,FILE,"COMBINED")
 . S BCL=$$EX1BENCH(BASE,FILE,"CLAIM")
 . S BL=$$EX1BENCH(BASE,FILE,"LINE")
 . I BC'="" D EQ(.FAIL,LAB_"[combined rows]",$$CSVROWS(OUTBASE_".csv"),$$CSVROWS(BC))
 . I BCL'="" D EQ(.FAIL,LAB_"[claim rows]",$$CSVROWS(OUTBASE_"-Claims.csv"),$$CSVROWS(BCL))
 . I BL'="" D EQ(.FAIL,LAB_"[line rows]",$$CSVROWS(OUTBASE_"-Lines.csv"),$$CSVROWS(BL))
 Q
 ;
T302(FAIL,BASE) ; Example 2 837 raw structure coverage
 N I,REC,FAM,FILE,KIND,GUIDE,CLAIMS,LINES,LAB,PATH,RAW,EX
 F I=1:1 S REC=$P($T(EX2837+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . S FAM=$P(REC,"|",1),FILE=$P(REC,"|",2),KIND=$P(REC,"|",3),GUIDE=$P(REC,"|",4)
 . S CLAIMS=+$P(REC,"|",5),LINES=+$P(REC,"|",6)
 . S PATH=$$EX2SRCF(BASE,FAM,FILE),LAB="[T302]["_FILE_"]",EX=$S(PATH'="":1,1:0)
 . D EQ(.FAIL,LAB_"[source exists]",EX,1)
 . I 'EX Q
 . D RAWMETA(PATH,.RAW)
 . D EQ(.FAIL,LAB_"[raw ok]",+$G(RAW("ok")),1)
 . I '+$G(RAW("ok")) Q
 . D EQ(.FAIL,LAB_"[st]",$G(RAW("st")),"837")
 . D EQ(.FAIL,LAB_"[kind]",$G(RAW("kind")),KIND)
 . D EQ(.FAIL,LAB_"[guide]",$$GUIDEOK($G(RAW("guide")),GUIDE),1)
 . D EQ(.FAIL,LAB_"[claims]",+$G(RAW("claims")),CLAIMS)
 . D EQ(.FAIL,LAB_"[lines]",+$G(RAW("lines")),LINES)
 Q
 ;
T310(FAIL,BASE) ; Example 1 non-837 raw smoke
 N I,REC,DIR,FILE,ST,GS,CONV,LAB,PATH,RAW,EX
 F I=1:1 S REC=$P($T(OTHDATA+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . S DIR=$P(REC,"|",1),FILE=$P(REC,"|",2),ST=$P(REC,"|",3),GS=$P(REC,"|",4),CONV=+$P(REC,"|",5)
 . S PATH=$$OTHSRC(BASE,DIR,FILE),LAB="[T310]["_FILE_"]",EX=$S(PATH'="":1,1:0)
 . D EQ(.FAIL,LAB_"[source exists]",EX,1)
 . I 'EX Q
 . D RAWMETA(PATH,.RAW)
 . D EQ(.FAIL,LAB_"[raw ok]",+$G(RAW("ok")),1)
 . I '+$G(RAW("ok")) Q
 . D EQ(.FAIL,LAB_"[st]",$G(RAW("st")),ST)
 . D EQ(.FAIL,LAB_"[gs]",$G(RAW("gs")),GS)
 Q
 ;
T320(FAIL,BASE) ; inventory counts
 D EQ(.FAIL,"[T320][ex1 837 count]",$$COUNTEX1837(BASE),18)
 D EQ(.FAIL,"[T320][ex2 837 count]",$$COUNTEX2837(BASE),29)
 D EQ(.FAIL,"[T320][other x12 count]",$$COUNTOTH(BASE),37)
 Q
 ;
T330(FAIL,BASE) ; benchmark inventory sanity for conversion-ready 837 set
 N I,REC,FILE,LAB
 N BC,BCL,BL
 F I=1:1 S REC=$P($T(BENCH837+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . S FILE=$P(REC,"|",1),LAB="[T330]["_FILE_"]"
 . S BC=$$EX1BENCH(BASE,FILE,"COMBINED")
 . S BCL=$$EX1BENCH(BASE,FILE,"CLAIM")
 . S BL=$$EX1BENCH(BASE,FILE,"LINE")
 . D EQ(.FAIL,LAB_"[combined bench]",$S(BC'="":1,1:0),+$P(REC,"|",2))
 . D EQ(.FAIL,LAB_"[claim bench]",$S(BCL'="":1,1:0),+$P(REC,"|",3))
 . D EQ(.FAIL,LAB_"[line bench]",$S(BL'="":1,1:0),+$P(REC,"|",4))
 Q
 ;
 ; -------- raw file helpers --------
RAWMETA(PATH,OUT) ; light raw X12 scanner for external coverage tests
 N TXT,ERR,SEP,TERM,N,I,SEG,TOK,ID
 K OUT
 S OUT("ok")=0,OUT("claims")=0,OUT("lines")=0,OUT("transactions")=0
 S OUT("sv1")=0,OUT("sv2")=0,OUT("sv3")=0
 S TXT=$$READALL(PATH,.ERR)
 I +$G(ERR)!(TXT="") Q
 S SEP=$$RAWSEP(TXT) I SEP="" S SEP="*"
 S TERM=$$RAWTERM(TXT) I TERM="" S TERM="~"
 S N=$L(TXT,TERM)
 F I=1:1:N D
 . S SEG=$$TRSEG($P(TXT,TERM,I))
 . I SEG="" Q
 . D TOKR(SEG,SEP,.TOK)
 . S ID=$G(TOK("id"))
 . I ID="GS" S OUT("gs")=$G(TOK(1)) I $G(TOK(8))'="" S OUT("gs_guide")=$G(TOK(8))
 . I ID="ST" D
 . . S OUT("st")=$G(TOK(1))
 . . S OUT("transactions")=+$G(OUT("transactions"))+1
 . . I $G(TOK(3))'="" S OUT("guide")=$G(TOK(3))
 . I ID="CLM" S OUT("claims")=+$G(OUT("claims"))+1
 . I ID="SV1" S OUT("sv1")=+$G(OUT("sv1"))+1,OUT("lines")=+$G(OUT("lines"))+1
 . I ID="SV2" S OUT("sv2")=+$G(OUT("sv2"))+1,OUT("lines")=+$G(OUT("lines"))+1
 . I ID="SV3" S OUT("sv3")=+$G(OUT("sv3"))+1,OUT("lines")=+$G(OUT("lines"))+1
 I $G(OUT("guide"))="" S OUT("guide")=$G(OUT("gs_guide"))
 S OUT("kind")=$$RAWTXK(.OUT)
 S OUT("ok")=1
 Q
 ;
READALL(PATH,ERR) ; read whole file into scalar for test-only inspection
 N DEV,OLDIO,TXT,CH,DONE,$ETRAP,$ESTACK
 S ERR=0,TXT="",DEV=$G(PATH),OLDIO=$IO,DONE=0
 I '$$EXIST(DEV) S ERR=1 Q ""
 S $ETRAP="S ERR=1,DONE=1,$ECODE="""""
 O DEV:(READONLY:STREAM):1
 I '$T U OLDIO Q ""
 U DEV
 F  Q:DONE  D
 . S CH=""
 . R CH#4096:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S ERR=1,DONE=1
 . I CH'="" S TXT=TXT_CH
 . I $ZEOF S DONE=1
 C DEV
 U OLDIO
 Q TXT
 ;
RAWSEP(TXT) ; element separator
 N P,S
 S S=$G(TXT),P=$F(S,"ISA")
 I P>0,$L(S)'<(P+1) Q $E(S,P)
 I S["ST*" Q "*"
 I S["ST|" Q "|"
 Q "*"
 ;
RAWTERM(TXT) ; segment terminator
 N P,S
 S S=$G(TXT),P=$F(S,"ISA")
 I P>0,$L(S)'<(P+102) Q $E(S,P+102)
 I S["~" Q "~"
 I S[$C(10) Q $C(10)
 I S[$C(13) Q $C(13)
 Q ""
 ;
TOKR(SEG,SEP,TOK) ;
 N I,N,S
 K TOK
 S SEP=$S($G(SEP)'="":SEP,1:"*")
 S S=$$TRSEG($G(SEG))
 I S="" Q
 S TOK("id")=$P(S,SEP,1)
 S N=$L(S,SEP)
 F I=2:1:N S TOK(I-1)=$P(S,SEP,I)
 Q
 ;
TRSEG(X) ; trim CR/LF/TAB/SP
 N Y
 S Y=$G(X)
 F  Q:Y=""  Q:$A(Y)'=10  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$A(Y)'=13  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$A(Y)'=9  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$E(Y)'=" "  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$A(Y,$L(Y))'=10  S Y=$E(Y,1,$L(Y)-1)
 F  Q:Y=""  Q:$A(Y,$L(Y))'=13  S Y=$E(Y,1,$L(Y)-1)
 F  Q:Y=""  Q:$A(Y,$L(Y))'=9  S Y=$E(Y,1,$L(Y)-1)
 F  Q:Y=""  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1)
 Q Y
 ;
RAWTXK(OUT) ; infer 837 flavor
 N G
 S G=$$UC^EFU837U($G(OUT("guide")))
 I G["X224" Q "837D"
 I G["X223" Q "837I"
 I G["X222" Q "837P"
 I G["X299" Q "837I"
 I G["X298" Q "837P"
 I +$G(OUT("sv3"))>0 Q "837D"
 I +$G(OUT("sv2"))>0 Q "837I"
 I +$G(OUT("sv1"))>0 Q "837P"
 I $G(OUT("st"))="837" Q "837"
 Q ""
 ;
GUIDEOK(ACT,EXP) ;
 N A,E
 S A=$$UC^EFU837U($G(ACT)),E=$$UC^EFU837U($G(EXP))
 I E="" Q 1
 I A=E Q 1
 I $E(A,1,$L(E))=E Q 1
 Q 0
 ;
 ; -------- count / compare helpers --------
CSVROWS(PATH) ; count CSV data rows, excluding header and blank lines
 N DEV,LINE,CNT,HDR,DONE,OLDIO,$ETRAP,$ESTACK
 I '$$EXIST(PATH) Q -1
 S DEV=PATH,CNT=0,HDR=0,DONE=0,OLDIO=$IO
 O DEV:(READONLY:STREAM):1 E  Q -1
 U DEV
 S $ETRAP="S DONE=1,$ECODE="""""
 F  Q:DONE  D
 . S LINE=""
 . R LINE:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S DONE=1
 . S LINE=$$TRSEG(LINE)
 . I LINE="" Q
 . I 'HDR S HDR=1 Q
 . S CNT=CNT+1
 . I $ZEOF S DONE=1
 C DEV
 U OLDIO
 Q CNT
 ;
EQ(FAIL,LAB,GOT,EXP) ;
 I $G(GOT)'=$G(EXP) D
 . S FAIL=1
 . W !,"FAIL: ",LAB,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
TMPBASE(STEM) ;
 Q "/tmp/efux12t-"_$J_"-"_$TR($G(STEM)," /()","____")
 ;
 ; -------- example inventory helpers --------
COUNTEX1837(BASE) ;
 N I,REC,C
 S C=0
 F I=1:1 S REC=$P($T(EX1837+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . I $$EX1SRCF(BASE,$P(REC,"|",1))'="" S C=C+1
 Q C
 ;
COUNTEX2837(BASE) ;
 N I,REC,C
 S C=0
 F I=1:1 S REC=$P($T(EX2837+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . I $$EX2SRCF(BASE,$P(REC,"|",1),$P(REC,"|",2))'="" S C=C+1
 Q C
 ;
COUNTOTH(BASE) ;
 N I,REC,C
 S C=0
 F I=1:1 S REC=$P($T(OTHDATA+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . I $$OTHSRC(BASE,$P(REC,"|",1),$P(REC,"|",2))'="" S C=C+1
 Q C
 ;
EX1BENCH(BASE,FILE,TYPE) ; Example 1 benchmark CSV path or empty
 N ROOT,STEM,P
 S ROOT=$$EX1ROOT(BASE),STEM=$$NOEXT^EFU837U($G(FILE))
 I ROOT="" Q ""
 I $$UC^EFU837U($G(TYPE))="COMBINED" D  Q P
 . S P=ROOT_"/converted_files/837/"_STEM_".csv"
 . I '$$EXIST(P) S P=""
 I $$UC^EFU837U($G(TYPE))="CLAIM" D  Q P
 . S P=ROOT_"/converted_files/837/"_STEM_"-Claims.csv"
 . I '$$EXIST(P) S P=""
 I $$UC^EFU837U($G(TYPE))="LINE" D  Q P
 . S P=ROOT_"/converted_files/837/"_STEM_"-Lines.csv"
 . I '$$EXIST(P) S P=""
 Q ""
 ;
EX1SRCF(BASE,FILE) ;
 N ROOT,PATH
 S ROOT=$$EX1ROOT(BASE)
 I ROOT="" Q ""
 S PATH=ROOT_"/edi_files/837/"_$G(FILE)
 I '$$EXIST(PATH) Q ""
 Q PATH
 ;
OTHSRC(BASE,DIR,FILE) ;
 N ROOT,PATH
 S ROOT=$$EX1ROOT(BASE)
 I ROOT="" Q ""
 S PATH=ROOT_"/edi_files/"_$G(DIR)_"/"_$G(FILE)
 I '$$EXIST(PATH) Q ""
 Q PATH
 ;
HASCONV(BASE,DIR,FILE) ; at least one converted artifact exists
 N ROOT,STEM,P
 S ROOT=$$EX1ROOT(BASE)
 I ROOT="" Q 0
 S STEM=$$NOEXT^EFU837U($G(FILE))
 S P=ROOT_"/converted_files/"_$G(DIR)_"/"_STEM_".json"
 I $$EXIST(P) Q 1
 S P=ROOT_"/converted_files/"_$G(DIR)_"/"_STEM_".csv"
 I $$EXIST(P) Q 1
 S P=ROOT_"/converted_files/"_$G(DIR)_"/"_STEM_".xlsx"
 I $$EXIST(P) Q 1
 S P=ROOT_"/converted_files/"_$G(DIR)_"/"_STEM_".jsonl"
 I $$EXIST(P) Q 1
 Q 0
 ;
EX2SRCF(BASE,SUB,FILE) ;
 N ROOT,DIR,PATH
 S ROOT=$$EX2ROOT(BASE)
 I ROOT="" Q ""
 S DIR=$$EX2SUB(ROOT,$G(SUB))
 I DIR="" Q ""
 S PATH=DIR_"/"_$G(FILE)
 I '$$EXIST(PATH) Q ""
 Q PATH
 ;
EX2SUB(ROOT,SUB) ;
 N C1,C2,C3
 S C1=ROOT_"/"_$G(SUB)
 I $$EXIST(C1_"/"_$$EX2MARK($G(SUB))) Q C1
 S C2=ROOT_"/"_$$SP2US($G(SUB))
 I $$EXIST(C2_"/"_$$EX2MARK($G(SUB))) Q C2
 S C3=ROOT_"/"_$$NOSPC($G(SUB))
 I $$EXIST(C3_"/"_$$EX2MARK($G(SUB))) Q C3
 Q ""
 ;
EX2MARK(SUB) ;
 I $G(SUB)["X222" Q "X222-ambulance.edi"
 I $G(SUB)["X223" Q "X223-837-institutional-claim.edi"
 I $G(SUB)["X224" Q "X224-sales-tax.edi"
 Q ""
 ;
EX1ROOT(BASE) ;
 N B,R
 S B=$G(BASE)
 I B="" Q ""
 I $$EX1OK(B) Q B
 S R=B_"/Examples_1" I $$EX1OK(R) Q R
 S R=B_"/Examples 1" I $$EX1OK(R) Q R
 S R=B_"/Examples1" I $$EX1OK(R) Q R
 S R=B_"/files/Examples_1" I $$EX1OK(R) Q R
 S R=B_"/files/Examples 1" I $$EX1OK(R) Q R
 S R=B_"/files/Examples1" I $$EX1OK(R) Q R
 Q ""
 ;
EX2ROOT(BASE) ;
 N B,R
 S B=$G(BASE)
 I B="" Q ""
 I $$EX2OK(B) Q B
 S R=B_"/Examples_2" I $$EX2OK(R) Q R
 S R=B_"/Examples 2" I $$EX2OK(R) Q R
 S R=B_"/Examples2" I $$EX2OK(R) Q R
 S R=B_"/files/Examples_2" I $$EX2OK(R) Q R
 S R=B_"/files/Examples 2" I $$EX2OK(R) Q R
 S R=B_"/files/Examples2" I $$EX2OK(R) Q R
 Q ""
 ;
EX1OK(ROOT) ;
 I $G(ROOT)="" Q 0
 I '$$EXIST(ROOT_"/edi_files/837/837P-all-fields.dat") Q 0
 I '$$EXIST(ROOT_"/edi_files/837/837I-all-fields.dat") Q 0
 I '$$EXIST(ROOT_"/edi_files/837/837D-all-fields.dat") Q 0
 Q 1
 ;
EX2OK(ROOT) ;
 I $G(ROOT)="" Q 0
 I $$EX2SUB(ROOT,"005010X222 Health Care Claim Professional")="" Q 0
 I $$EX2SUB(ROOT,"005010X223 Health Care Claim Institutional")="" Q 0
 I $$EX2SUB(ROOT,"005010X224 Health Care Claim Dental")="" Q 0
 Q 1
 ;
AUTBASE() ;
 I $$HASBASE("edi") Q "edi"
 I $$HASBASE("./edi") Q "./edi"
 I $$HASBASE("edi/files") Q "edi/files"
 I $$HASBASE("./edi/files") Q "./edi/files"
 I $$HASBASE("files") Q "files"
 I $$HASBASE("./files") Q "./files"
 I $$HASBASE("/mnt/data/edi_local/files") Q "/mnt/data/edi_local/files"
 I $$HASBASE("/mnt/data/edi_local") Q "/mnt/data/edi_local"
 I $$HASBASE(".") Q "."
 Q ""
 ;
RESBASE(BASE) ;
 I $G(BASE)="" Q ""
 I $$HASBASE(BASE) Q BASE
 I $$HASBASE("./"_BASE) Q "./"_BASE
 I $$HASBASE(BASE_"/files") Q BASE_"/files"
 I $$HASBASE("./"_BASE_"/files") Q "./"_BASE_"/files"
 I $$HASBASE("edi") Q "edi"
 I $$HASBASE("./edi") Q "./edi"
 I $$HASBASE("edi/files") Q "edi/files"
 I $$HASBASE("./edi/files") Q "./edi/files"
 I $$HASBASE("files") Q "files"
 I $$HASBASE("./files") Q "./files"
 I $$HASBASE("/mnt/data/edi_local/files") Q "/mnt/data/edi_local/files"
 I $$HASBASE("/mnt/data/edi_local") Q "/mnt/data/edi_local"
 Q ""
 ;
HASBASE(BASE) ;
 Q ($$EX1ROOT($G(BASE))'="")&($$EX2ROOT($G(BASE))'="")
 ;
FAILBASE(FAIL,BASE) ;
 S FAIL=1
 W !,"FAIL: [EFUX12T][base]: could not locate full example tree under ",$G(BASE)
 Q
 ;
EXIST(PATH) ; exact existence check
 N DEV,OK,$ETRAP,$ESTACK
 S DEV=$G(PATH),OK=0
 I DEV="" Q 0
 S $ETRAP="S OK=0,$ECODE="""""
 O DEV:(READONLY):0
 I $T S OK=1 C DEV
 Q OK
 ;
SP2US(X) ;
 N I,Y,C
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I),Y=Y_$S(C=" ":"_",1:C)
 Q Y
 ;
NOSPC(X) ;
 N I,Y,C
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I) I C'=" " S Y=Y_C
 Q Y
 ;
 ; -------- metadata --------
EX1837 ;
 ;;837D-all-fields.dat|837D|005010X224|1|2
 ;;837I-X299-all-fields.dat|837I|005010X299|1|1
 ;;837I-all-fields.dat|837I|005010X223A2|1|2
 ;;837I-inst-claim.dat|837I|005010X223|1|2
 ;;837P-X298-all-fields.dat|837P|005010X298|1|1
 ;;837P-all-fields.dat|837P|005010X222A2|1|4
 ;;ambulance.dat|837P|005010X222|1|4
 ;;anesthesia.dat|837P|005010X222|1|2
 ;;chiro.dat|837P|005010X222|1|1
 ;;cob-payera-payerb.dat|837P|005010X222|1|3
 ;;cob-prov-payera.dat|837P|005010X222|1|3
 ;;commercial-replacement.dat|837P|005010X222|1|4
 ;;commercial.dat|837P|005010X222|1|3
 ;;home-infusion-ndc.dat|837P|005010X222|1|6
 ;;multi-tran.dat|837P|005010X222|3|7
 ;;ppo-repriced.dat|837P|005010X222|1|2
 ;;prof-encounter.dat|837P|005010X222|1|4
 ;;wheelchair.dat|837P|005010X222|1|1
 ;
BENCH837 ; file|combined bench|claim bench|line bench
 ;;837I-inst-claim.dat|1|0|0
 ;;anesthesia.dat|1|0|0
 ;;chiro.dat|1|0|0
 ;;cob-payera-payerb.dat|1|0|0
 ;;cob-prov-payera.dat|1|0|0
 ;;commercial-replacement.dat|1|0|0
 ;;home-infusion-ndc.dat|1|0|0
 ;;multi-tran.dat|1|0|0
 ;;ppo-repriced.dat|1|0|0
 ;;wheelchair.dat|1|0|0
 ;
EX2837 ;
 ;;005010X222 Health Care Claim Professional|X222-COB-claim-from-billing-provider-to-payer-a.edi|837P|005010X222A1|1|3
 ;;005010X222 Health Care Claim Professional|X222-COB-claim-from-billing-provider-to-payer-b.edi|837P|005010X222A1|1|3
 ;;005010X222 Health Care Claim Professional|X222-COB-claim-from-payer-a-to-payer-b-in-payer-to-payer.edi|837P|005010X222A1|1|3
 ;;005010X222 Health Care Claim Professional|X222-ambulance.edi|837P|005010X222A1|1|4
 ;;005010X222 Health Care Claim Professional|X222-anesthesia.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-chiropractic.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-commercial-health-insurance.edi|837P|005010X222A1|1|4
 ;;005010X222 Health Care Claim Professional|X222-drug-administered-in-the-physician-office.edi|837P|005010X222A1|1|2
 ;;005010X222 Health Care Claim Professional|X222-encounter.edi|837P|005010X222A1|1|4
 ;;005010X222 Health Care Claim Professional|X222-home-infusion-therapy-pharmacy-(adjudicated-with-HCPCS-in-loop-2400-or-NDC-in-loop-2410).edi|837P|005010X222A1|1|6
 ;;005010X222 Health Care Claim Professional|X222-home-infusion-therapy-pharmacy-(adjudicated-with-NDC-in-loop-2410).edi|837P|005010X222A1|1|6
 ;;005010X222 Health Care Claim Professional|X222-medicare-secondary-payer-COB.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-out-of-network-repriced-claim.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-oxygen.edi|837P|005010X222A1|1|2
 ;;005010X222 Health Care Claim Professional|X222-ppo-repriced-claim.edi|837P|005010X222A1|1|2
 ;;005010X222 Health Care Claim Professional|X222-wheelchair.edi|837P|005010X222A1|1|1
 ;;005010X223 Health Care Claim Institutional|X223-837-institutional-claim.edi|837I|005010X223A2|1|2
 ;;005010X223 Health Care Claim Institutional|X223-automobile-accident.edi|837I|005010X223A2|1|4
 ;;005010X223 Health Care Claim Institutional|X223-out-of-network-repriced-claim.edi|837I|005010X223A2|1|1
 ;;005010X223 Health Care Claim Institutional|X223-ppo-repriced-claim.edi|837I|005010X223A2|1|2
 ;;005010X223 Health Care Claim Institutional|X223-two-claims-for-the-same-provider.edi|837I|005010X223A2|2|3
 ;;005010X224 Health Care Claim Dental|X224-claim-from-billing-provider-to-payer-a.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-claim-from-billing-provider-to-payer-b.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-claim-multi-quantity-single-line.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-commercial-health-insurance.edi|837D|005010X224A2|1|2
 ;;005010X224 Health Care Claim Dental|X224-multiple-tooth-numbers.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-orthodontic-treatment-plan.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-predetermination-of-benefits.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-sales-tax.edi|837D|005010X224A2|1|3
 ;
OTHDATA ;
 ;;271|X279-error-response-from-payer-to-clinic-not-eligible-for-inquiries-with-payer.edi|271|HB|1
 ;;271|X279-generic-request-by-clinic-for-patient-(subscriber)-eligibility.edi|270|HS|1
 ;;271|X279-generic-request-by-physician-for-patient-(dependent)-eligibility.edi|270|HS|1
 ;;271|X279-response-to-generic-request-by-clinic-for-patient-(subscriber)-eligibility.edi|271|HB|1
 ;;271|X279-response-to-generic-request-by-physician-for-patient-(dependent)-eligibility.edi|271|HB|1
 ;;274|274.edi|274|HR|1
 ;;277|277CA-all-fields.edi|277|HN|1
 ;;277|277CA-receiver-rejected.edi|277|HN|1
 ;;277|X212-276-claim-ncpdp-request.edi|276|HR|0
 ;;277|X212-276-claim-request.edi|276|HR|0
 ;;277|X212-276-info-receiver-request.edi|276|HR|0
 ;;277|X212-276-provider-request.edi|276|HR|0
 ;;277|X212-277-claim-ncpdp-response.edi|277|HR|1
 ;;277|X212-277-claim-response.edi|277|HR|1
 ;;277|X212-277-info-receiver-response.edi|277|HR|1
 ;;277|X212-277-provider-response.edi|277|HR|1
 ;;277|X214-payer-response-multiple-responders.edi|277|HN|1
 ;;277|X214-payer-response.edi|277|HN|1
 ;;810|810-test.edi|810|SC|0
 ;;834|834-all-fields.edi|834|BE|1
 ;;834|X220-add-dependent-(full-time-student)-to-existing-enrollment.edi|834|BE|1
 ;;834|X220-add-subscriber-coverage.edi|834|BE|1
 ;;834|X220-cancel-a-dependent.edi|834|BE|1
 ;;834|X220-change-subscriber-information.edi|834|BE|1
 ;;834|X220-enroll-employee-in-managed-care-product.edi|834|BE|1
 ;;834|X220-enroll-employee-in-multiple-health-care-insurance-products.edi|834|BE|1
 ;;834|X220-reinstate-an-employee.edi|834|BE|1
 ;;834|X220-reinstate-employee-at-coverage-(hd)-level.edi|834|BE|1
 ;;834|X220-reinstate-member-eligibility-(ins).edi|834|BE|1
 ;;834|X220-terminate-eligibility-for-subscriber.edi|834|BE|1
 ;;835|835-all-fields.dat|835|HP|1
 ;;835|835-denial.dat|835|HP|1
 ;;835|835-provider-level-adjustment.dat|835|HP|1
 ;;835|claim_adj_reason.dat|835|HP|1
 ;;835|dollars_data_separate.dat|835|HP|1
 ;;835|negotiated_discount.dat|835|HP|1
 ;;835|not_covered_inpatient.dat|835|HP|1
