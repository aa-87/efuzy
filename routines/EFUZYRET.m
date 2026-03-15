EFUZYRET ; efuzy retention and cleanup helpers
 ;
 Q
 ;
RUN(CONF,OPT,RES) ; run default retention policy
 N OK,FRES,JRES
 K RES
 S RES("routine")="EFUZYRET"
 I '$$ISLOCAL^EFUZYBOOT($$ROOT^EFUZYFS(.CONF)) D  Q:$Q 0 Q
 . S RES("ok")=0
 . S RES("error")="root_not_local_tmp"
 S OK=1
 D PURGEFILES(.CONF,.OPT,.FRES)
 M RES("files")=FRES
 I '+$G(FRES("ok")) S OK=0
 D PURGEJOBS(.CONF,.OPT,.JRES)
 M RES("jobs")=JRES
 I '+$G(JRES("ok")) S OK=0
 S RES("ok")=OK
 I 'OK,$G(RES("error"))="" S RES("error")="retention_failed"
 Q:$Q OK Q
 ;
PURGEFILES(CONF,OPT,RES) ; purge stale staged/upload file records
 N ROOT,KEEPD,ID,ISO,PATH,DEL
 K RES
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S KEEPD=$$DAYOPT(.CONF,.OPT,"uploadsDays",2)
 S RES("root")=ROOT
 S RES("keepDays")=KEEPD
 S RES("ok")=1
 S ID=0
 F  S ID=$O(^MIO("EFUZY","file",ID)) Q:'ID  D
 . S ISO=$G(^MIO("EFUZY","file",ID,"createdAt"))
 . I '$$STALE(ISO,KEEPD) S RES("kept")=+$G(RES("kept"))+1 Q
 . S PATH=$G(^MIO("EFUZY","file",ID,"path"))
 . S DEL=$$DELFILE(PATH,ROOT)
 . I $G(PATH)'="",'DEL D  Q
 . . S RES("failed")=+$G(RES("failed"))+1
 . . S RES("ok")=0
 . K ^MIO("EFUZY","file",ID)
 . S RES("removed")=+$G(RES("removed"))+1
 Q
 ;
PURGEJOBS(CONF,OPT,RES) ; purge stale completed/failed jobs and artifacts
 N ROOT,KEEPD,ALLOW,ID,ISO,STATUS,OLD,PATH,KEY,X
 K RES
 S ROOT=$$ROOT^EFUZYFS(.CONF)
 S KEEPD=$$DAYOPT(.CONF,.OPT,"jobsDays",30)
 S ALLOW=+$$DAYOPT(.CONF,.OPT,"allowDeletePublished",0)
 S RES("root")=ROOT
 S RES("keepDays")=KEEPD
 S RES("ok")=1
 S ID=0
 F  S ID=$O(^MIO("EFUZY","job",ID)) Q:'ID  D
 . S STATUS=$G(^MIO("EFUZY","job",ID,"status"))
 . I $$KEEPJOB(ID,STATUS,ALLOW) S RES("kept")=+$G(RES("kept"))+1 Q
 . S ISO=$S($G(^MIO("EFUZY","job",ID,"endedAt"))'="":$G(^MIO("EFUZY","job",ID,"endedAt")),1:$G(^MIO("EFUZY","job",ID,"createdAt")))
 . I '$$STALE(ISO,KEEPD) S RES("kept")=+$G(RES("kept"))+1 Q
 . S KEY=""
 . F  S KEY=$O(^MIO("EFUZY","job",ID,"artifact",KEY)) Q:KEY=""  D
 . . S PATH=$G(^MIO("EFUZY","job",ID,"artifact",KEY,"path"))
 . . I PATH'="" S X=$$DELFILE(PATH,ROOT)
 . S PATH=$G(^MIO("EFUZY","job",ID,"outputPath"))
 . I PATH'="" S X=$$DELFILE(PATH,ROOT)
 . S PATH=ROOT_"/jobs/"_ID
 . S X=$$DELDIR(PATH,ROOT)
 . S OLD=$G(^MIO("EFUZY","job",ID,"status"))
 . I OLD'="" K ^MIO("EFUZY","idx","job","status",OLD,ID)
 . K ^MIO("EFUZY","job",ID)
 . S RES("removed")=+$G(RES("removed"))+1
 Q
 ;
KEEPJOB(ID,STATUS,ALLOW)
 I $G(STATUS)="queued" Q 1
 I $G(STATUS)="running" Q 1
 I $G(STATUS)="current" Q 1
 I $G(STATUS)="published",'ALLOW Q 1
 I +$G(^MIO("EFUZY","job",ID,"published")),'ALLOW Q 1
 Q 0
 ;
DAYOPT(CONF,OPT,KEY,DEF)
 N V
 S V=$G(OPT($G(KEY)))
 I V="" S V=$G(CONF("efuzy","retention",$G(KEY)))
 I V="" S V=$G(DEF)
 Q +V
 ;
STALE(ISO,DAYS)
 N CUT,DAY
 S DAY=$E($G(ISO),1,10)
 I DAY="" Q 0
 S CUT=$ZDATE(($P($H,",",1)-+$G(DAYS)),"YYYY-MM-DD")
 Q $S(DAY']CUT:1,1:0)
 ;
DELFILE(PATH,ROOT)
 N $ETRAP,$ESTACK
 I $G(PATH)="" Q 1
 I '$$SAFEPATH(PATH,ROOT) Q 0
 I '$$FEX(PATH) Q 1
 S $ETRAP="SET $ECODE="""" QUIT"
 O PATH:(readonly):1 E  G DELFILEZ
 C PATH:DELETE
 I '$$FEX(PATH) Q 1
DELFILEZ ZSY "rm -f '"_$TR(PATH,"'","''")_"'"
 Q $S($$FEX(PATH):0,1:1)
 ;
DELDIR(PATH,ROOT)
 N CMD
 I $G(PATH)="" Q 1
 I '$$SAFEPATH(PATH,ROOT) Q 0
 I '$$DIREX(PATH) Q 1
 S CMD="rmdir '"_$TR(PATH,"'","''")_"'"
 ZSY CMD
 I '$$DIREX(PATH) Q 1
 S CMD="rm -rf '"_$TR(PATH,"'","''")_"'"
 ZSY CMD
 Q $S($$DIREX(PATH):0,1:1)
 ;
SAFEPATH(PATH,ROOT)
 N P,R
 S P=$$NORM($G(PATH)),R=$$NORM($G(ROOT))
 I P=""!(R="") Q 0
 I $E(P,1,$L(R)+1)'=R_"/" Q 0
 Q 1
 ;
FEX(PATH)
 Q $S($ZSEARCH($G(PATH))'="":1,1:0)
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
NORM(PATH)
 N P
 S P=$G(PATH)
 I $E(P,1,2)="./" S P=$E(P,3,$L(P))
 F  Q:$E(P,$L(P))'="/"  S P=$E(P,1,$L(P)-1) Q:P=""
 Q P
 ;
