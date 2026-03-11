EFU837XFORM ; efuzy 837 export profile value extraction
 ;
 ; Public:
 ;   GET(ROOT,CID,LN,PATH)
 ;   APPLY(ROOT,CID,LN,.DEF)
 ;
 Q
 ;
GET(ROOT,CID,LN,PATH) ; resolve one normalized-path value
 N P,HEAD,TAIL,REST
 S P=$G(PATH)
 I P="" Q ""
 S HEAD=$P(P,".",1),TAIL=$P(P,".",2,99)
 I HEAD="claim" Q $G(@ROOT@("norm","claim",CID,TAIL))
 I HEAD="line" Q $G(@ROOT@("norm","line",CID,+$G(LN),TAIL))
 I HEAD="sub" Q $G(@ROOT@("norm","party","subscriber",CID,TAIL))
 I HEAD="patient" Q $G(@ROOT@("norm","party","patient",CID,TAIL))
 I HEAD="prov" D  Q REST
 . N P2,T2
 . S P2=$P(TAIL,".",1),T2=$P(TAIL,".",2,99)
 . I P2="billing" S REST=$G(@ROOT@("norm","provider","billing",CID,T2)) Q
 . I P2="attending" S REST=$G(@ROOT@("norm","provider","claim",CID,"71",T2)) Q
 . S REST=""
 Q ""
 ;
APPLY(ROOT,CID,LN,DEF) ; apply field definition to root/claim/line context
 N V,XF
 S V=$$GET(ROOT,CID,$G(LN),$G(DEF("path")))
 I V="",$D(DEF("default")) S V=DEF("default")
 S XF=$$UC^EFU837U($G(DEF("xf")))
 I XF="UPPER" Q $$UC^EFU837U(V)
 I XF="LOWER" Q $$LC^EFU837U(V)
 I XF="YN" Q $S(+V:"Y",1:"N")
 Q V
 ;
