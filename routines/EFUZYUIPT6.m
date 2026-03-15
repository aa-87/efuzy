EFUZYUIPT6 ; desktop automation folder SSR tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYUIPT6"
 Q
 ;
ALL(FAIL)
 D T960(.FAIL)
 D T970(.FAIL)
 Q
 ;
T960(FAIL) ; authenticated desktop seeds and exposes default automation folders
 N CONF,REQ,CTX,TCTX,N,HASPROF,HASWORK
 D RESET^EFUZYTESTU("")
 S CTX("efuzy","userId")=42
 D BUILDDESK^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T960][automation any]",+$G(TCTX("automationAny")),1)
 D EQ(.FAIL,"[T960][icon1]",$G(TCTX("desktop","icons",1,"label")),"Claim-level export")
 D EQ(.FAIL,"[T960][icon2]",$G(TCTX("desktop","icons",2,"label")),"Line-level export")
 D EQ(.FAIL,"[T960][input folder1]",$G(TCTX("desktop","inputFolders",1,"name")),"Claim-level export")
 D EQ(.FAIL,"[T960][profile label1]",$G(TCTX("desktop","inputFolders",1,"profileLabel")),"Claim Summary")
 D EQ(.FAIL,"[T960][delete action]",$G(TCTX("desktop","inputFolders",1,"deleteAction")),"/efuzy/api/automation/delete")
 S (N,HASPROF,HASWORK)=0 F  S N=$O(TCTX("desktop","icons",N)) Q:'N  D
 . I $G(TCTX("desktop","icons",N,"label"))="Profiles" S HASPROF=1
 . I $G(TCTX("desktop","icons",N,"label"))="Workspace" S HASWORK=1
 D EQ(.FAIL,"[T960][no profiles icon]",HASPROF,0)
 D EQ(.FAIL,"[T960][no workspace icon]",HASWORK,0)
 Q
 ;
T970(FAIL) ; authenticated desktop template renders automation folder hooks
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D RESET^EFUZYTESTU("")
 S CTX("efuzy","userId")=42
 S CONF("server","templateDir")="templates"
 D START^MIOTPL(.CONF)
 D BUILDDESK^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/efuzy_desktop.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T970][render ok]",$D(ERR),0)
 D EQ(.FAIL,"[T970][drop target hook]",$F(OUT,"data-desktop-drop-target")>0,1)
 D EQ(.FAIL,"[T970][automation input]",$F(OUT,"name=""automationId""")>0,1)
 D EQ(.FAIL,"[T970][publish input]",$F(OUT,"name=""autoPublish""")>0,1)
 D EQ(.FAIL,"[T970][delete automation]",$F(OUT,"Delete automation")>0,1)
 D EQ(.FAIL,"[T970][claim folder text]",$F(OUT,"Claim-level export")>0,1)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 