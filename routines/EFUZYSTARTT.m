EFUZYSTARTT ; tests for startup helpers and script presence
	;
	Q
	;
START
	D T001
	D T002
	D T003
	D T004
	D T005
	D T006
	Q
	;
T001 ; required operational scripts exist
	D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU("scripts/start_efuzy.sh"),1,"[T001][start script]")
	D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU("scripts/check_efuzy.sh"),1,"[T001][check script]")
	D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU("scripts/compile_efuzy.sh"),1,"[T001][compile script]")
	D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU("scripts/install_efuzy.sh"),1,"[T001][install script]")
	Q
	;
T002 ; STARTUP writes boot record and runtime globals
	N ROOT,CONF,RES
	S ROOT=$$TMPROOT^EFUZYTESTU("start2")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	D SETCONF^EFUZYTESTU(.CONF,ROOT)
	D OK^MIOTASSERT($$STARTUP^EFUZYBOOT(.CONF,.RES),"[T002][startup ok]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","boot","last","ok")),1,"[T002][boot ok]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","boot","last","root")),ROOT,"[T002][boot root]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","runtime","root")),ROOT,"[T002][runtime root]")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	Q
	;
T003 ; STARTUP fails safely for non-local roots
	N CONF,RES
	D RESET^EFUZYTESTU("")
	K ^MIO("ROUTE"),^MIO("CTL")
	S CONF("efuzy","rootDir")="/tmp/efuzy"
	D EQ^MIOTASSERT($$STARTUP^EFUZYBOOT(.CONF,.RES),0,"[T003][startup fail]")
	D EQ^MIOTASSERT($G(RES("error")),"root_not_local_tmp","[T003][error]")
	Q
	;
T004 ; STARTUP normalizes ./tmp local roots
	N ROOT,CONF,RES
	S ROOT=$$TMPROOT^EFUZYTESTU("start4")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	S CONF("efuzy","rootDir")="./"_ROOT_"/"
	D OK^MIOTASSERT($$STARTUP^EFUZYBOOT(.CONF,.RES),"[T004][startup ok]")
	D EQ^MIOTASSERT($G(CONF("efuzy","rootDir")),ROOT,"[T004][normalized root]")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	Q
	;
T005 ; STARTUP fails for paid mode without a license file
	N ROOT,CONF,RES
	S ROOT=$$TMPROOT^EFUZYTESTU("start5")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	D SETCONF^EFUZYTESTU(.CONF,ROOT)
	S CONF("efuzy","license","mode")="paid"
	S CONF("efuzy","license","filePath")="tmp/efuzy-test-no-such/license.license"
	D EQ^MIOTASSERT($$STARTUP^EFUZYBOOT(.CONF,.RES),0,"[T005][startup fail]")
	D EQ^MIOTASSERT($G(RES("license","error")),"license_file_missing","[T005][license error]")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	Q
	;
T006 ; STARTUP succeeds for paid mode with a valid local license
	N ROOT,CONF,RES,LFILE,IDFILE,ID,OK
	S ROOT=$$TMPROOT^EFUZYTESTU("start6")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	D SETCONF^EFUZYTESTU(.CONF,ROOT)
	S CONF("efuzy","license","mode")="paid"
	S LFILE=ROOT_"/license/efuzy.license"
	S IDFILE=ROOT_"/license/efuzy.install_id"
	D MKDIR^EFUZYTESTU(ROOT_"/license")
	S ID="start6-install"
	D WRITEFILE^EFUZYTESTU(IDFILE,ID,.OK)
	D WRLIC^EFUZYTESTU(LFILE,"standard",ID,"",$$DATEPLUS^EFUZYTESTU(30),.OK)
	S CONF("efuzy","license","filePath")=LFILE
	S CONF("efuzy","license","installIdPath")=IDFILE
	D OK^MIOTASSERT($$STARTUP^EFUZYBOOT(.CONF,.RES),"[T006][startup ok]")
	D EQ^MIOTASSERT($G(RES("license","status")),"licensed","[T006][license status]")
	D RESET^EFUZYTESTU(ROOT)
	K ^MIO("ROUTE"),^MIO("CTL")
	Q
	;
	;
	;