EFU837U ; efuzy X12 837 utility helpers
	;
	; Public helpers:
	;   INIT(ROOT,.OPT)
	;   ADDDIAG(ROOT,SEV,CODE,MSG,SEGNO,SEGID)
	;   SPLIT(STR,SEP,.OUT)
	;   COMP(STR,SEP,.OUT)
	;   DTP(QUAL,FORM,VAL,TROOT)
	;   NAME(TROOT,.TOK)
	;   TRIM(X)
	;   UC(X)
	;   JOINCODES(ROOT,CID,SEP)
	;   BOOL(X)
	;   TXKIND(ROOT,TX)
	;   CSVESC(X)
	;   BASENAME(PATH)
	;   NOEXT(NAME)
	;
	Q
	;
INIT(ROOT,OPT) ; initialize parse root
	K @ROOT
	S @ROOT@("meta","engine")="EFU837"
	S @ROOT@("meta","version")="0.2.0"
	S @ROOT@("meta","mode")=$S($G(OPT("mode"))'="":OPT("mode"),1:"full")
	S @ROOT@("meta","chunk")=$S(+$G(OPT("chunk"))>0:+$G(OPT("chunk")),1:64)
	S @ROOT@("meta","startedH")=$H
	Q
	;
ADDDIAG(ROOT,SEV,CODE,MSG,SEGNO,SEGID) ; append diagnostic
	N IDX
	S SEV=$$LC(SEV)
	S IDX=+$G(@ROOT@("diag",SEV,"last"))+1
	S @ROOT@("diag",SEV,"last")=IDX
	S @ROOT@("diag",SEV,IDX,"code")=$G(CODE)
	S @ROOT@("diag",SEV,IDX,"msg")=$G(MSG)
	S @ROOT@("diag",SEV,IDX,"segno")=+$G(SEGNO)
	S @ROOT@("diag",SEV,IDX,"segid")=$G(SEGID)
	S @ROOT@("stats",SEV)=+$G(@ROOT@("stats",SEV))+1
	Q
	;
SPLIT(STR,SEP,OUT) ; split element string
	N I,N
	K OUT
	S SEP=$G(SEP)
	I SEP="" S OUT(1)=STR,OUT("n")=1 Q
	S N=$L(STR,SEP)
	F I=1:1:N S OUT(I)=$P(STR,SEP,I)
	S OUT("n")=N
	Q
	;
COMP(STR,SEP,OUT) ; split composite string
	N I,N
	K OUT
	S SEP=$G(SEP)
	I SEP="" S OUT(1)=STR,OUT("n")=1 Q
	S N=$L(STR,SEP)
	F I=1:1:N S OUT(I)=$P(STR,SEP,I)
	S OUT("n")=N
	Q
	;
DTP(QUAL,FORM,VAL,TROOT) ; normalize a DTP node at target root
	I $G(TROOT)="" Q
	S @TROOT@("qual")=$G(QUAL)
	S @TROOT@("form")=$G(FORM)
	S @TROOT@("raw")=$G(VAL)
	I FORM="D8" S @TROOT@("value")=VAL Q
	I FORM="DT" S @TROOT@("value")=VAL Q
	I FORM="TM" S @TROOT@("value")=VAL Q
	I FORM="RD8" D  Q
	. S @TROOT@("from")=$P(VAL,"-",1)
	. S @TROOT@("thru")=$P(VAL,"-",2)
	S @TROOT@("value")=VAL
	Q
	;
NAME(TROOT,TOK) ; populate common NM1 fields
	I $G(TROOT)="" Q
	S @TROOT@("entity_code")=$G(TOK(1))
	S @TROOT@("entity_type")=$G(TOK(2))
	S @TROOT@("name_last")=$G(TOK(3))
	S @TROOT@("name_first")=$G(TOK(4))
	S @TROOT@("name_middle")=$G(TOK(5))
	S @TROOT@("name_prefix")=$G(TOK(6))
	S @TROOT@("name_suffix")=$G(TOK(7))
	S @TROOT@("id_qual")=$G(TOK(8))
	S @TROOT@("id")=$G(TOK(9))
	Q
	;
TRIM(X) ; trim leading/trailing spaces
	N Y
	S Y=$G(X)
	F  Q:$E(Y,1)'=" "  S Y=$E(Y,2,$L(Y))
	F  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1) I Y="" Q
	Q Y
	;
UC(X) ; uppercase alpha only
	N Y,I,C,A
	S Y=""
	F I=1:1:$L($G(X)) S C=$E(X,I) D
	. S A=$A(C)
	. I A'<97,A'>122 S C=$C(A-32)
	. S Y=Y_C
	Q Y
	;
LC(X) ; lowercase alpha only
	N Y,I,C,A
	S Y=""
	F I=1:1:$L($G(X)) S C=$E(X,I) D
	. S A=$A(C)
	. I A'<65,A'>90 S C=$C(A+32)
	. S Y=Y_C
	Q Y
	;
BOOL(X) ; normalize boolean-ish values
	N Y
	S Y=$$UC($G(X))
	Q $S((Y="Y")!(Y="1")!(Y="T")!(Y="TRUE"):1,1:0)
	;
JOINCODES(ROOT,CID,SEP) ; join claim HI codes for previews
	N I,S
	S SEP=$S($G(SEP)'="":SEP,1:"|")
	S S="",I=0
	F  S I=$O(@ROOT@("claim",CID,"diag",I)) Q:'I  D
	. I S'="" S S=S_SEP
	. S S=S_$G(@ROOT@("claim",CID,"diag",I,"code"))
	Q S
	;
TXKIND(ROOT,TX) ; infer 837 flavor from guide or service kind
	N G,CID,SK
	S G=$$UC($G(@ROOT@("tx",TX,"st","guide")))
	I G["X224" Q "837D"
	I G["X223" Q "837I"
	I G["X222" Q "837P"
	I G["X299" Q "837I"
	I G["X298" Q "837P"
	S CID=0
	F  S CID=$O(@ROOT@("claim",CID)) Q:'CID  I +$G(@ROOT@("claim",CID,"tx"))=+TX D  Q:SK'=""
	. S SK=$G(@ROOT@("claim",CID,"line",1,"service_kind"))
	I SK="SV3" Q "837D"
	I SK="SV2" Q "837I"
	I SK="SV1" Q "837P"
	Q "837"
	;
CSVESC(X) ; CSV-safe scalar
	N Y
	S Y=$G(X)
	I (Y[",")!(Y[$C(34))!(Y[$C(10))!(Y[$C(13)) D
	. S Y=$TR(Y,$C(34),$C(34,34))
	. S Y=$C(34)_Y_$C(34)
	Q Y
	;
BASENAME(PATH) ; last path component
	N P,I,C,S
	S S=$G(PATH),P=0
	F I=1:1:$L(S) S C=$E(S,I) I (C="/")!(C=$C(92)) S P=I
	Q $E(S,P+1,$L(S))
	;
NOEXT(NAME) ; drop final extension
	N I,P,C,S
	S S=$G(NAME),P=0
	F I=1:1:$L(S) S C=$E(S,I) I C="." S P=I
	I 'P Q S
	Q $E(S,1,P-1)
	;
	;