EFUZYBOOT ; efuzy runtime bootstrap and startup helpers
 ;
 Q
 ;
ENSURE(CONF,RES) ; ensure runtime defaults, checks, and directories
 N OK,CRES,DRES,IRES,LRES
 K RES
 S OK=1
 S RES("routine")="EFUZYBOOT"
 D NORMALIZE(.CONF,.RES,.OK)
 D DIRS(.CONF,.DRES)
 M RES("dirs")=DRES
 I '+$G(DRES("ok")) D
 . S OK=0
 . I $G(RES("error"))="" S RES("error")=$S($G(DRES("error"))'="":$G(DRES("error")),1:"dir_create_failed")
 D ENSUREID^EFUZYLIC(.CONF,.IRES)
 M RES("install")=IRES
 I '+$G(IRES("ok")) D
 . S OK=0
 . I $G(RES("error"))="" S RES("error")=$S($G(IRES("error"))'="":$G(IRES("error")),1:"install_id_failed")
 D CHECKENV(.CONF,.CRES)
 M RES("checkenv")=CRES
 I '+$G(CRES("ok")) D
 . S OK=0
 . I $G(RES("error"))="" S RES("error")=$S($G(CRES("error"))'="":$G(CRES("error")),1:"checkenv_failed")
 D STATUS^EFUZYLIC(.CONF,.LRES)
 M RES("license")=LRES
 I '+$G(LRES("ok")) D
 . S OK=0
 . I $G(RES("error"))="" S RES("error")=$S($G(LRES("error"))'="":$G(LRES("error")),1:"license_invalid")
 I OK D SEEDRT(.CONF,.RES)
 S RES("ok")=OK
 S RES("root")=$$ROOT^EFUZYFS(.CONF)
 I 'OK,$G(RES("error"))="" S RES("error")="bootstrap_failed"
 Q:$Q OK Q
 ;
STARTUP(CONF,RES) ; top-level startup/bootstrap entry point
 N OK
 K RES
 S OK=$$ENSURE(.CONF,.RES)
 S ^MIO("EFUZY","boot","last","ok")=OK
 S ^MIO("EFUZY","boot","last","status")=$S(OK:1,1:0)
 S ^MIO("EFUZY","boot","last","root")=$$ROOT^EFUZYFS(.CONF)
 S ^MIO("EFUZY","boot","last","ts")=$$NOWISO^MIOUTIL()
 I 'OK,$G(RES("error"))'="" S ^MIO("EFUZY","boot","last","error")=RES("error")
 Q:$Q OK Q
 ;
DIRS(CONF,RES) ; ensure required runtime directories exist
 N ROOT,OK,N
 K RES
 D CFG^EFUZYLIC(.CONF)
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S RES("routine")="EFUZYBOOT"
 S RES("root")=ROOT
 I '$$ISLOCAL(ROOT) D  Q:$Q 0 Q
 . S RES("ok")=0
 . S RES("error")="root_not_local_tmp"
 S OK=1,N=0
 D ADDDIR("uploads")
 D ADDDIR("staged")
 D ADDDIR("jobs")
 D ADDDIR("exports")
 D ADDDIR("reports")
 D ADDDIR("log")
 D ADDDIR("run")
 D ADDDIR("cache")
 D ADDDIR("tmp")
 ; legacy compatibility dirs kept additive
 D ADDDIR("work")
 D ADDDIR("logs")
 S RES("ok")=OK
 I 'OK,$G(RES("error"))="" S RES("error")="dir_create_failed"
 Q:$Q OK Q
 ;
ADDDIR(NAME)
 N PATH,ERR
 S N=N+1
 S PATH=ROOT_"/"_$G(NAME)
 S RES("dirs",N,"name")=$G(NAME)
 S RES("dirs",N,"path")=PATH
 I $$ENSDIR(PATH,.ERR) D  Q
 . S RES("dirs",N,"ok")=1
 . S RES("dirs",N,"info")="ensured"
 S RES("dirs",N,"ok")=0
 S RES("dirs",N,"error")=$G(ERR("error"),"mkdir_failed")
 S OK=0
 I $G(RES("error"))="" S RES("error")=$G(ERR("error"),"mkdir_failed")
 Q
 ;
CHECKENV(CONF,RES) ; verify runtime prerequisites without creating state
 N OK,ROOT,LRES
 K RES
 S OK=1
 S RES("routine")="EFUZYBOOT"
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S RES("root")=ROOT
 D SETCHK(.RES,"root_local",$$ISLOCAL(ROOT),ROOT)
 I '$$ISLOCAL(ROOT) S OK=0,RES("error")="root_not_local_tmp"
 D SETCHK(.RES,"miohttp",$S($T(PARSE^MIOHTTP)'="":1,1:0),"MIOHTTP") I $T(PARSE^MIOHTTP)="" S OK=0
 D SETCHK(.RES,"mioroute",$S($T(INIT^MIOROUTE)'="":1,1:0),"MIOROUTE") I $T(INIT^MIOROUTE)="" S OK=0
 D SETCHK(.RES,"miomw",$S($T(ENSURE^MIOMW)'="":1,1:0),"MIOMW") I $T(ENSURE^MIOMW)="" S OK=0
 D SETCHK(.RES,"miotpl",$S($T(START^MIOTPL)'="":1,1:0),"MIOTPL") I $T(START^MIOTPL)="" S OK=0
 D SETCHK(.RES,"mioauth",$S($T(ENFORCE^MIOAUTH)'="":1,1:0),"MIOAUTH") I $T(ENFORCE^MIOAUTH)="" S OK=0
 D SETCHK(.RES,"mioauthjwt",$S($T(VERIFY^MIOAUTHJWT)'="":1,1:0),"MIOAUTHJWT") I $T(VERIFY^MIOAUTHJWT)="" S OK=0
 D SETCHK(.RES,"mioauthz",$S($T(ENFORCE^MIOAUTHZ)'="":1,1:0),"MIOAUTHZ") I $T(ENFORCE^MIOAUTHZ)="" S OK=0
 D SETCHK(.RES,"efuzy_routes",$S($T(REG^EFUZY)'="":1,1:0),"EFUZY") I $T(REG^EFUZY)="" S OK=0
 D SETCHK(.RES,"efuzy_cfg",$S($T(SEED^EFUZYCFG)'="":1,1:0),"EFUZYCFG") I $T(SEED^EFUZYCFG)="" S OK=0
 D SETCHK(.RES,"efuzy_fs",$S($T(ROOT^EFUZYFS)'="":1,1:0),"EFUZYFS") I $T(ROOT^EFUZYFS)="" S OK=0
 D SETCHK(.RES,"efuzy_job",$S($T(CREATEQ^EFUZYJOB)'="":1,1:0),"EFUZYJOB") I $T(CREATEQ^EFUZYJOB)="" S OK=0
 D SETCHK(.RES,"efux12job",$S($T(RUN837^EFUX12JOB)'="":1,1:0),"EFUX12JOB") I $T(RUN837^EFUX12JOB)="" S OK=0
 D SETCHK(.RES,"efuwfrun",$S($T(RUN^EFUWFRUN)'="":1,1:0),"EFUWFRUN") I $T(RUN^EFUWFRUN)="" S OK=0
 D SETCHK(.RES,"mws_conf",$S($$CFGPATH()'="":1,1:0),$S($$CFGPATH()'="":$$CFGPATH(),1:"default"))
 D SETCHK(.RES,"ydb_routines",$S($ZTRNLNM("ydb_routines")'="":1,1:0),$S($ZTRNLNM("ydb_routines")'="":"set",1:"not_set"))
 D SETCHK(.RES,"efuzy_license_routine",$S($T(STATUS^EFUZYLIC)'="":1,1:0),"EFUZYLIC") I $T(STATUS^EFUZYLIC)="" S OK=0
 D STATUS^EFUZYLIC(.CONF,.LRES)
 M RES("license")=LRES
 D SETCHK(.RES,"license_ok",+$G(LRES("ok")),$G(LRES("status"))) I '+$G(LRES("ok")) D
 . S OK=0
 . I $G(RES("error"))="" S RES("error")=$S($G(LRES("error"))'="":$G(LRES("error")),1:"license_invalid")
 S RES("ok")=OK
 Q:$Q OK Q
 ;
CHECKONLY(CONF,RES) ; alias for callers that want a named check-only entry point
 I $Q Q $$CHECKENV(.CONF,.RES)
 D CHECKENV(.CONF,.RES)
 Q
 ;
SEEDRT(CONF,RES)
 N ROOT,N
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S ^MIO("EFUZY","runtime","schema")=1
 S ^MIO("EFUZY","runtime","root")=ROOT
 S ^MIO("EFUZY","runtime","bootedAt")=$$NOWISO^MIOUTIL()
 F N="uploads","staged","jobs","exports","reports","log","run","cache","tmp" S ^MIO("EFUZY","runtime","dir",N)=ROOT_"/"_N
 I $T(SEED^EFUZYCFG)'="" D SEED^EFUZYCFG
 S RES("seeded")=1
 Q
 ;
NORMALIZE(CONF,RES,OK)
 N ROOT
 S ROOT=$G(CONF("efuzy","rootDir"))
 I ROOT=""!(ROOT=".")!(ROOT="./") S ROOT="tmp/efuzy"
 S ROOT=$$NORM(ROOT)
 S CONF("efuzy","rootDir")=ROOT
 S RES("normalizedRoot")=ROOT
 I '$$ISLOCAL(ROOT) D
 . S OK=0
 . S RES("error")="root_not_local_tmp"
 Q
 ;
ENSDIR(PATH,ERR) ; mkdir -p + probe write
 N CMD,PROBE
 K ERR
 I $G(PATH)="" Q 1
 S CMD="mkdir -p '"_$TR($G(PATH),"'","''")_"'"
 ZSY CMD
 S PROBE=$G(PATH)_"/.efuzy_boot_probe"
 O PROBE:(newversion:stream:nowrap:writeonly):1 E  D  Q 0
 . S ERR("error")="mkdir_failed"
 U PROBE W "ok" C PROBE
 D DEL1(PROBE)
 Q 1
 ;
SETCHK(RES,NAME,OK,INFO)
 S RES("checks",$G(NAME),"ok")=+$G(OK)
 I $G(INFO)'="" S RES("checks",$G(NAME),"info")=$G(INFO)
 Q
 ;
CFGPATH()
 N P
 S P=""
 I $T(GETCONF^MIOCONF)'="" S P=$$GETCONF^MIOCONF()
 Q P
 ;
ISLOCAL(PATH) ; enforce local repo tmp/efuzy root only
 N P
 S P=$$NORM($G(PATH))
 Q $S(P="tmp/efuzy":1,$E(P,1,10)="tmp/efuzy/":1,$E(P,1,10)="tmp/efuzy-":1,1:0)
 ;
NORM(PATH)
 N P
 S P=$G(PATH)
 I $E(P,1,2)="./" S P=$E(P,3,$L(P))
 F  Q:$E(P,$L(P))'="/"  S P=$E(P,1,$L(P)-1) Q:P=""
 Q P
 ;
DEL1(PATH)
 N $ETRAP,$ESTACK
 I $G(PATH)="" Q
 I $ZSEARCH(PATH)="" Q
 S $ETRAP="SET $ECODE="""" QUIT"
 O PATH:(readonly):1 E  G DEL1Z
 C PATH:DELETE
 I $ZSEARCH(PATH)="" Q
DEL1Z ZSY "rm -f '"_$TR(PATH,"'","''")_"'"
 Q
 ;
