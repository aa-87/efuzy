EFUZYFS ; efuzy filesystem helpers
	;
	Q
	;
ROOT(CONF)
	N R
	S R=$G(CONF("efuzy","rootDir"))
	I R="" S R="."
	Q R
	;
UPLOADDIR(CONF)
	Q $$ROOT(.CONF)_"/uploads"
	;
EXPORTDIR(CONF)
	Q $$ROOT(.CONF)_"/exports"
	;
NEXTFILE()
	N ID
	L +^MIO("EFUZY","SEQ","FILE"):2 E  Q 0
	S ID=$I(^MIO("EFUZY","SEQ","FILE"))
	L -^MIO("EFUZY","SEQ","FILE")
	Q ID
	;
STAGEUPLOAD(CONF,MP,FILEID,ERR)
	N IDX,FN,PATH,CUR,CH,OK,DEV,PART
	K ERR
	S IDX=$$FIRSTFILE(.MP)
	I 'IDX S ERR("error")="no_file_part" Q 0
	S FILEID=$$NEXTFILE()
	I 'FILEID S ERR("error")="file_seq_busy" Q 0
	S FN=$$SAFEFN($G(MP("part",IDX,"filename")))
	I FN="" S FN="upload-"_FILEID_".x12"
	S PATH=$$UPLOADDIR(.CONF)_"/"_FILEID_"-"_FN
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
	. I "-_."[C S O=O_C Q
	. S O=O_"_"
	Q O
	;
LOADFILES(CONF,LIMIT,TCTX)
	N ID,N
	S N=0,ID=""
	F  S ID=$O(^MIO("EFUZY","file",ID),-1) Q:'ID!(N>=+$G(LIMIT))  D
	. S N=N+1
	. S TCTX("files",N,"id")=ID
	. S TCTX("files",N,"name")=$G(^MIO("EFUZY","file",ID,"name"))
	. S TCTX("files",N,"size")=$G(^MIO("EFUZY","file",ID,"size"))
	. S TCTX("files",N,"createdAt")=$G(^MIO("EFUZY","file",ID,"createdAt"))
	I 'N S TCTX("filesEmpty")=1
	Q
	;
LISTFILES(CONF,OBJ)
	N ID,N
	S OBJ("ok")=1,N=0,ID=0
	F  S ID=$O(^MIO("EFUZY","file",ID)) Q:'ID  D
	. S N=N+1
	. S OBJ("files",N,"id")=ID
	. S OBJ("files",N,"name")=$G(^MIO("EFUZY","file",ID,"name"))
	. S OBJ("files",N,"path")=$G(^MIO("EFUZY","file",ID,"path"))
	. S OBJ("files",N,"size")=$G(^MIO("EFUZY","file",ID,"size"))
	Q
	;
GETPATH(FILEID)
	Q $G(^MIO("EFUZY","file",+FILEID,"path"))
	;
GETNAME(FILEID)
	Q $G(^MIO("EFUZY","file",+FILEID,"name"))
	;
	;
SAFE(X)
	Q $$SAFEFN($G(X))
	;
	;