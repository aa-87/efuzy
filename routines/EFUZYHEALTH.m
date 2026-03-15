EFUZYHEALTH ; efuzy health and readiness helpers
 ;
 Q
 ;
STATUS(CONF,RES) ; bootstrap/filesystem status check
 N OK,BRES,ROOT,LRES
 K RES
 S OK=1
 S RES("routine")="EFUZYHEALTH"
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S RES("root")=ROOT
 D CHECKENV^EFUZYBOOT(.CONF,.BRES)
 M RES("bootstrap")=BRES
 I '+$G(BRES("ok")) S OK=0
 D DIRCHK(.CONF,.RES,.OK)
 D SETCHK(.RES,"boot_record",+$G(^MIO("EFUZY","boot","last","ok")),$G(^MIO("EFUZY","boot","last","ts")))
 D SETCHK(.RES,"runtime_root",$S($G(^MIO("EFUZY","runtime","root"))=ROOT:1,1:0),$G(^MIO("EFUZY","runtime","root")))
 D SETCHK(.RES,"profiles_seeded",+$G(^MIO("EFUZY","cfg","seeded")),"EFUZYCFG")
 D SETCHK(.RES,"route_compiled",+$G(^MIO("ROUTE","COMPILE","ok")),"MIOROUTE")
 D SETCHK(.RES,"server_pid",$S(+$G(^MIO("CTL","PID"))>0:1,1:0),$G(^MIO("CTL","PID")))
 D STATUS^EFUZYLIC(.CONF,.LRES)
 M RES("license")=LRES
 D SETCHK(.RES,"license_ok",+$G(LRES("ok")),$G(LRES("status")))
 I '+$G(LRES("ok")) S OK=0
 S RES("ok")=OK
 S RES("status")=$S(OK:"ok",1:"degraded")
 Q:$Q OK Q
 ;
READY(CONF,RES) ; strict ready check for live operation
 N OK,TRES
 K RES
 S OK=$$STATUS(.CONF,.RES)
 D ROUTECHK(.RES,.OK)
 D PIDCHK(.RES,.OK)
 D TEMPCHK(.CONF,.TRES)
 M RES("tempcheck")=TRES
 I '+$G(TRES("ok")) S OK=0
 S RES("ok")=OK
 S RES("status")=$S(OK:"ready",1:"not_ready")
 I 'OK,$G(RES("error"))="" S RES("error")="not_ready"
 Q:$Q OK Q
 ;
DIRCHK(CONF,RES,OK)
 N ROOT,N,NAME,PATH,EX
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 F N=1:1 S NAME=$P("uploads,staged,jobs,exports,reports,log,run,cache,tmp",",",N) Q:NAME=""  D
 . S PATH=ROOT_"/"_NAME
 . S EX=$$DIREX(PATH)
 . D SETCHK(.RES,"dir_"_NAME,EX,PATH)
 . I 'EX S OK=0
 Q
 ;
ROUTECHK(RES,OK)
 N X
 S X=+$G(^MIO("ROUTE","COMPILE","ok"))
 D SETCHK(.RES,"routes_ready",X,"compiled")
 I 'X S OK=0
 Q
 ;
PIDCHK(RES,OK)
 N PID
 S PID=+$G(^MIO("CTL","PID"))
 D SETCHK(.RES,"listener_pid",$S(PID>0:1,1:0),PID)
 I PID<1 S OK=0
 Q
 ;
TEMPCHK(CONF,RES)
 N ROOT,PATH,DEV,CMD
 K RES
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S PATH=ROOT_"/tmp/.efuzy_ready_probe"
 S RES("path")=PATH
 I '$$ISSAFEP(PATH,ROOT) D  Q:$Q 0 Q
 . S RES("ok")=0
 . S RES("error")="unsafe_temp_probe_path"
 S DEV=PATH
 O DEV:(newversion:stream:nowrap:writeonly):1 E  D  Q:$Q 0 Q
 . S RES("ok")=0
 . S RES("error")="temp_probe_open_failed"
 U DEV W "ready"
 C DEV
 S CMD="rm -f '"_$TR(PATH,"'","''")_"'"
 ZSY CMD
 S RES("ok")=$S($$FEX(PATH):0,1:1)
 I 'RES("ok") S RES("error")="temp_probe_delete_failed"
 Q:$Q +$G(RES("ok")) Q
 ;
SETCHK(RES,NAME,OK,INFO)
 S RES("checks",$G(NAME),"ok")=+$G(OK)
 I $G(INFO)'="" S RES("checks",$G(NAME),"info")=$G(INFO)
 Q
 ;
DIREX(PATH)
 N P
 S P=$G(PATH)
 I P="" Q 0
 I $L(P)>1,$E(P,$L(P))="/" S P=$E(P,1,$L(P)-1)
 I $ZSEARCH(P_"/.")'="" Q 1
 I $ZSEARCH(P_"/")'="" Q 1
 I $ZSEARCH(P)'="" Q 1
 Q 0
 ;
FEX(PATH)
 Q $S($ZSEARCH($G(PATH))'="":1,1:0)
 ;
ISSAFEP(PATH,ROOT)
 N P,R
 S P=$$NORM($G(PATH)),R=$$NORM($G(ROOT))
 I P=""!(R="") Q 0
 I $E(P,1,$L(R)+1)'=R_"/" Q 0
 Q 1
 ;
NORM(PATH)
 N P
 S P=$G(PATH)
 I $E(P,1,2)="./" S P=$E(P,3,$L(P))
 F  Q:$E(P,$L(P))'="/"  S P=$E(P,1,$L(P)-1) Q:P=""
 Q P
 ;
