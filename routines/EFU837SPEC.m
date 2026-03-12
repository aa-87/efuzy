EFU837SPEC ; efuzy X12 837 rule tables v2
 ;
 ; Public:
 ;   LOAD(GUIDE,.SPEC)
 ;   KIND(GUIDE)
 ;   REQSVC(GUIDE)
 ;   ENVRULE(MODE,KEY) ; envelope rule by mode
 ;   SEGMIN(GUIDE,LOOP,SEG)
 ;   SEGMAX(GUIDE,LOOP,SEG)
 ;   LOOPREQ(GUIDE,LOOP,SEG)
 ;   ALLOW(GUIDE,LOOP,SEG)
 ;   DATAREQ(GUIDE,KEY) ; semantic/data requirement by guide
 ;   BALTOL(GUIDE)      ; claim/line balance tolerance
 ;
 Q
 ;
LOAD(GUIDE,SPEC) ; materialize one guide rule table into SPEC
 N G,K
 K SPEC
 S G=$$NORMG($G(GUIDE))
 S SPEC("guide")=G
 S K=$$KIND(G)
 S SPEC("kind")=K
 S SPEC("svc","required")=$$REQSVC(G)
 D ENV(.SPEC)
 D BASE(.SPEC)
 D FLAVOR(G,.SPEC)
 D DATA(G,.SPEC)
 Q
 ;
KIND(GUIDE) ; guide => claim flavor
 N G
 S G=$$NORMG($G(GUIDE))
 I G["X224" Q "837D"
 I G["X223" Q "837I"
 I G["X222" Q "837P"
 I G["X299" Q "837I"
 I G["X298" Q "837P"
 Q "837"
 ;
REQSVC(GUIDE) ; guide => required service segment
 N K
 S K=$$KIND($G(GUIDE))
 I K="837P" Q "SV1"
 I K="837I" Q "SV2"
 I K="837D" Q "SV3"
 Q ""
 ;
ENVRULE(MODE,KEY) ; envelope rule by mode
 N K
 S K=$$LC($G(KEY))
 I K="require_isa" Q 1
 I K="require_iea" Q 1
 I K="require_gs" Q 1
 I K="require_ge" Q 1
 I K="require_st" Q 1
 I K="require_se" Q 1
 Q 0
 ;
SEGMIN(GUIDE,LOOP,SEG) ; minimum cardinality
 N G,L,S
 S G=$$NORMG($G(GUIDE)),L=$$U($G(LOOP)),S=$$U($G(SEG))
 I L="2300",S="CLM" Q 1
 I L="2400",S="LX" Q 1
 I L="2400",S=$$REQSVC(G) Q 1
 Q 0
 ;
SEGMAX(GUIDE,LOOP,SEG) ; maximum cardinality, 0 means unbounded/unspecified
 N L,S
 S L=$$U($G(LOOP)),S=$$U($G(SEG))
 I L="2300",S="CLM" Q 1
 I L="2400",S="LX" Q 1
 I L="2400",S="SV1" Q 1
 I L="2400",S="SV2" Q 1
 I L="2400",S="SV3" Q 1
 Q 0
 ;
LOOPREQ(GUIDE,LOOP,SEG) ; whether segment is explicitly required in loop for guide
 Q $S($$SEGMIN($G(GUIDE),$G(LOOP),$G(SEG))>0:1,1:0)
 ;
ALLOW(GUIDE,LOOP,SEG) ; whether segment is allowed in loop for guide
 N G,L,S,R
 S G=$$NORMG($G(GUIDE)),L=$$U($G(LOOP)),S=$$U($G(SEG))
 I L="2300" Q $S(S="CLM":1,S="DTP":1,S="HI":1,S="CL1":1,S="OI":1,S="NM1":1,S="REF":1,1:0)
 I L="2400" D  Q R
 . S R=$S(S="LX":1,S="DTP":1,S="REF":1,S="SV1":1,S="SV2":1,S="SV3":1,1:0)
 Q 0
 ;
DATAREQ(GUIDE,KEY) ; semantic/data requirement by guide
 N K
 S K=$$LC($G(KEY))
 I K="claim_total_balance" Q 1
 I K="subscriber_id" Q 1
 I K="subscriber_name" Q 1
 I K="patient_id_if_distinct" Q 1
 I K="patient_name_if_distinct" Q 1
 Q 0
 ;
BALTOL(GUIDE) ; claim/line balance tolerance
 Q .01
 ;
ENV(SPEC) ; envelope defaults
 S SPEC("env","strict","require_isa")=1
 S SPEC("env","strict","require_iea")=1
 S SPEC("env","strict","require_gs")=1
 S SPEC("env","strict","require_ge")=1
 S SPEC("env","strict","require_st")=1
 S SPEC("env","strict","require_se")=1
 S SPEC("env","lenient","require_isa")=1
 S SPEC("env","lenient","require_iea")=1
 S SPEC("env","lenient","require_gs")=1
 S SPEC("env","lenient","require_ge")=1
 S SPEC("env","lenient","require_st")=1
 S SPEC("env","lenient","require_se")=1
 Q
 ;
BASE(SPEC) ; flavor-agnostic minimum rules
 S SPEC("loop","2300","segment","CLM","min")=1
 S SPEC("loop","2300","segment","CLM","max")=1
 S SPEC("loop","2400","segment","LX","min")=1
 S SPEC("loop","2400","segment","LX","max")=1
 S SPEC("loop","2300","allow","CLM")=1
 S SPEC("loop","2300","allow","DTP")=1
 S SPEC("loop","2300","allow","HI")=1
 S SPEC("loop","2300","allow","CL1")=1
 S SPEC("loop","2300","allow","OI")=1
 S SPEC("loop","2400","allow","LX")=1
 S SPEC("loop","2400","allow","DTP")=1
 S SPEC("loop","2400","allow","REF")=1
 Q
 ;
FLAVOR(GUIDE,SPEC) ; flavor-specific required service rules
 N K,SV
 S K=$$KIND($G(GUIDE)),SV=$$REQSVC($G(GUIDE))
 I SV'="" D
 . S SPEC("loop","2400","segment",SV,"min")=1
 . S SPEC("loop","2400","segment",SV,"max")=1
 . S SPEC("guide",$G(GUIDE),"loop","2400","required",SV)=1
 . S SPEC("svc","required")=SV
 I K="837P" S SPEC("flavor")="professional" Q
 I K="837I" S SPEC("flavor")="institutional" Q
 I K="837D" S SPEC("flavor")="dental" Q
 S SPEC("flavor")="unknown"
 Q
 ;
DATA(GUIDE,SPEC) ; data-quality defaults that validator can enforce
 S SPEC("data","claim_total_balance")=1
 S SPEC("data","subscriber_id")=1
 S SPEC("data","subscriber_name")=1
 S SPEC("data","patient_id_if_distinct")=1
 S SPEC("data","patient_name_if_distinct")=1
 S SPEC("data","balance_tolerance")=$$BALTOL($G(GUIDE))
 Q
 ;
NORMG(X) ; normalize guide string
 N G
 S G=$$U($G(X))
 Q G
 ;
U(X) ; uppercase alpha only
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
