EFUZYPT ; efuzy render smoke tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYPT"
 Q
 ;
ALL(FAIL)
 D T100(.FAIL)
 Q
 ;
BASECONF(CONF)
 K CONF
 D START^MIOTPL(.CONF)
 Q
 ;
T100(FAIL) ; desktop page renders and includes automation desktop copy
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D RESET^EFUZYTESTU("")
 D SEED^EFUZYT
 D BASECONF(.CONF)
 D BUILDDSK^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/efuzy_desktop.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T100][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T100][desktop copy]",OUT["Virtual folders",1)
 D EQ(.FAIL,"[T100][drop copy]",OUT["Drop file to run",1)
 D EQ(.FAIL,"[T100][desktop nav]",OUT["/efuzy/desktop",1)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
