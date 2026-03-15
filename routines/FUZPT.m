FUZPT ; FUZ render smoke tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - FUZPT"
 Q
 ;
ALL(FAIL)
 D T100(.FAIL)
 D T110(.FAIL)
 D T115(.FAIL)
 D T116(.FAIL)
 D T117(.FAIL)
 D T120(.FAIL)
 D T130(.FAIL)
 D T140(.FAIL)
 D T150(.FAIL)
 Q
 ;
BASECONF(CONF)
 K CONF
 D CONFDEF^FUZUI(.CONF)
 D START^MIOTPL(.CONF)
 Q
 ;
T100(FAIL) ; home renders and contains brand
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDHOME^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_home.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T100][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T100][brand]",OUT["efuzy",1)
 D EQ(.FAIL,"[T100][contact cta]",OUT["Contact us",1)
 D EQ(.FAIL,"[T100][manual card]",OUT["User manual",1)
 Q
 ;
T110(FAIL) ; features render includes workflow section
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDFEAT^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_features.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T110][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T110][workflow]",OUT["Workflow details",1)
 D EQ(.FAIL,"[T110][trust]",OUT["Additive test coverage",1)
 Q
 ;
T115(FAIL) ; guide render includes standard workflow text
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDGUIDE^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_guide.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T115][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T115][workflow]",OUT["Standard workflow",1)
 D EQ(.FAIL,"[T115][trace]",OUT["Diagnostics and trace",1)
 Q
 ;
T116(FAIL) ; manual render includes technical architecture
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDMANUAL^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_manual.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T116][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T116][technical]",OUT["Technical architecture",1)
 D EQ(.FAIL,"[T116][tmp]",OUT["tmp/efuzy",1)
 Q
 ;
T117(FAIL) ; services render includes fee and support
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDSERVICES^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_services.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T117][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T117][fee]",OUT["for a fee",1)
 D EQ(.FAIL,"[T117][support]",OUT["Support",1)
 Q
 ;
T120(FAIL) ; demo render includes expiry disclaimer
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDDEMO^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_demo.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T120][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T120][disclaimer]",OUT["expire",1)
 D EQ(.FAIL,"[T120][workspace link]",OUT["/efuzy/workspace",1)
 Q
 ;
T130(FAIL) ; contact render includes form fields
 N CONF,REQ,CTX,STATE,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDCONTACT^FUZUI(.CONF,.REQ,.CTX,.STATE,.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_contact.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T130][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T130][form]",OUT["name=""email""",1)
 D EQ(.FAIL,"[T130][method]",OUT["method=""post""",1)
 D EQ(.FAIL,"[T130][services]",OUT["Installation services",1)
 Q
 ;
T140(FAIL) ; privacy render includes privacy heading
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDLEGAL^FUZUI(.CONF,.REQ,.CTX,"privacy",.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_legal.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T140][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T140][privacy]",OUT["Privacy notice",1)
 Q
 ;
T150(FAIL) ; terms render includes terms heading
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDLEGAL^FUZUI(.CONF,.REQ,.CTX,"terms",.TCTX)
 D RENDERPAGE^MIOTPL("pages/fuz_legal.html","layouts/fuz_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T150][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T150][terms]",OUT["Terms of use",1)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
