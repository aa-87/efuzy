EFUZYFS ; efuzy filesystem helpers
	;
	Q
	;
ROOT(CONF,USERID)
	N R,U
	S R=$G(CONF("efuzy","rootDir"))
	I R=""!(R=".")!(R="./") S R="tmp/efuzy"
	S U=+$G(USERID)
	I U>0 S R=R_"/users/u-"_U
	Q R
	;
UPLOADDIR(CONF,USERID)
	Q $$ROOT(.CONF,+$G(USERID))_"/uploads"
	;
EXPORTDIR(CONF,USERID)
	Q $$ROOT(.CONF,+$G(USERID))_"/exports"
	;
NEXTFILE()
	N ID
	L +^MIO("EFUZY","SEQ","FILE"):2 E  Q 0
	S ID=$I(^MIO("EFUZY","SEQ","FILE"))
	L -^MIO("EFUZY","SEQ","FILE")
	Q ID
	;
STAGEUPLOAD(CONF,MP,FILEID,ERR,USERID)
	N IDX,FN,PATH,CUR,CH,DIR
	K ERR
	S IDX=$$FIRSTFILE(.MP)
	I 'IDX S ERR("error")="no_file_part" Q 0
	S FILEID=$$NEXTFILE()
	I 'FILEID S ERR("error")="file_seq_busy" Q 0
	S FN=$$SAFEFN($G(MP("part",IDX,"filename")))
	I FN="" S FN="upload-"_FILEID_".x12"
	S DIR=$$UPLOADDIR(.CONF,+$G(USERID))
	I '$$ENSDIR^EFUZYBOOT(DIR,.ERR) Q 0
	S PATH=DIR_"/"_FILEID_"-"_FN
	O PATH:(newversion:stream:nowrap):1 E  S ERR("error")="stage_open_failed" Q 0
	U PATH
	D PARTOPEN^MIOHTTPMPU(.MP,IDX,.CUR,.CONF)
	F  Q:'$$PARTNEXT^MIOHTTPMPU(.MP,IDX,.CUR,.CH)  W CH
	D ITCLOSE^MIOHTTPMPU(.CUR)
	C PATH
	S ^MIO("EFUZY","file",FILEID,"id")=FILEID
	S ^MIO("EFUZY","file",FILEID,"name")=FN
	S ^MIO("EFUZY","file",FILEID,"path")=PATH
	S ^MIO("EFUZY","file",FILEID,"contentType")=$G(MP("part",IDX,"ctype"))
	S ^MIO("EFUZY","file",FILEID,"size")=+$G(MP("part",IDX,"len"))
	S ^MIO("EFUZY","file",FILEID,"createdAt")=$$NOWISO^MIOUTIL()
	I +$G(USERID)>0 D STAMPFILE^EFUZYAUTH(FILEID,+$G(USERID))
	Q 1
	;
FIRSTFILE(MP)
	N I
	S I=0
	F  S I=$O(MP("part",I)) Q:'I  I $G(MP("part",I,"filename"))'="" Q
	Q +I
	;
SAFEFN(FN)
	N X,I,C,O
	S X=$G(FN),O=""
	F I=1:1:$L(X) S C=$E(X,I) D
	. I C?1AN S O=O_C Q
	. I C=" " S O=O_"_" Q
	. I "-_.,"[C S O=O_C Q
	. S O=O_"_"
	Q O
	;
LOADFILES(CONF,LIMIT,TCTX,USERID)
	N ID,N,MAX
	S N=0,MAX=+$G(LIMIT) I MAX<1 S MAX=8
	I +$G(USERID)>0 D  Q
	. S ID=$O(^MIO("EFUZY","idx","owner","file",+USERID,""),-1)
	. F  Q:ID=""!(N>=MAX)  D  S ID=$O(^MIO("EFUZY","idx","owner","file",+USERID,ID),-1)
	. . I '$D(^MIO("EFUZY","file",+ID)) Q
	. . S N=N+1
	. . D FILECTX(+ID,.TCTX,N)
	. I 'N S TCTX("filesEmpty")=1
	S ID=$O(^MIO("EFUZY","file",""),-1)
	F  Q:ID=""!(N>=MAX)  D  S ID=$O(^MIO("EFUZY","file",ID),-1)
	. I '$D(^MIO("EFUZY","file",+ID)) Q
	. S N=N+1
	. D FILECTX(+ID,.TCTX,N)
	I 'N S TCTX("filesEmpty")=1
	Q
	;
FILECTX(ID,TCTX,N)
	S TCTX("files",N,"id")=ID
	S TCTX("files",N,"name")=$G(^MIO("EFUZY","file",ID,"name"))
	S TCTX("files",N,"size")=$G(^MIO("EFUZY","file",ID,"size"))
	S TCTX("files",N,"createdAt")=$G(^MIO("EFUZY","file",ID,"createdAt"))
	Q
	;
LISTFILES(CONF,OBJ,USERID)
	N ID,N
	S OBJ("ok")=1,N=0,ID=0
	I +$G(USERID)>0 D  Q
	. F  S ID=$O(^MIO("EFUZY","idx","owner","file",+USERID,ID)) Q:'ID  D
	. . I '$D(^MIO("EFUZY","file",ID)) Q
	. . S N=N+1
	. . D FILEJSON(ID,.OBJ,N)
	F  S ID=$O(^MIO("EFUZY","file",ID)) Q:'ID  D
	. S N=N+1
	. D FILEJSON(ID,.OBJ,N)
	Q
	;
FILEJSON(ID,OBJ,N)
	S OBJ("files",N,"id")=ID
	S OBJ("files",N,"name")=$G(^MIO("EFUZY","file",ID,"name"))
	S OBJ("files",N,"path")=$G(^MIO("EFUZY","file",ID,"path"))
	S OBJ("files",N,"size")=$G(^MIO("EFUZY","file",ID,"size"))
	Q
	;
GETPATH(FILEID,USERID)
	I +$G(USERID)>0,'$$OWNSFILE^EFUZYAUTH(+USERID,+$G(FILEID)) Q ""
	Q $G(^MIO("EFUZY","file",+FILEID,"path"))
	;
GETNAME(FILEID,USERID)
	I +$G(USERID)>0,'$$OWNSFILE^EFUZYAUTH(+USERID,+$G(FILEID)) Q ""
	Q $G(^MIO("EFUZY","file",+FILEID,"name"))
	;
SAFE(X)
	Q $$SAFEFN($G(X))
	;
