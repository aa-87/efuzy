EFUZYHEALT ; tests for EFUZYHEALTH
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 D T004
 Q
 ;
T001 ; STATUS reports healthy bootstrap after startup
 N ROOT,CONF,RES
 S ROOT=$$TMPROOT^EFUZYTESTU("health1")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 D OK^MIOTASSERT($$STATUS^EFUZYHEALTH(.CONF,.RES),"[T001][status ok]")
 D EQ^MIOTASSERT($G(RES("status")),"ok","[T001][status text]")
 D OK^MIOTASSERT(+$G(RES("checks","dir_uploads","ok")),"[T001][uploads check]")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 Q
 ;
T002 ; READY fails before routes and listener pid are present
 N ROOT,CONF,RES
 S ROOT=$$TMPROOT^EFUZYTESTU("health2")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 D EQ^MIOTASSERT($$READY^EFUZYHEALTH(.CONF,.RES),0,"[T002][ready fail]")
 D EQ^MIOTASSERT($G(RES("status")),"not_ready","[T002][status]")
 D EQ^MIOTASSERT(+$G(RES("checks","routes_ready","ok")),0,"[T002][routes missing]")
 D EQ^MIOTASSERT(+$G(RES("checks","listener_pid","ok")),0,"[T002][pid missing]")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 Q
 ;
T003 ; READY passes when routes and listener pid are present
 N ROOT,CONF,RES
 S ROOT=$$TMPROOT^EFUZYTESTU("health3")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 S ^MIO("ROUTE","COMPILE","ok")=1
 S ^MIO("CTL","PID")=$J
 D OK^MIOTASSERT($$READY^EFUZYHEALTH(.CONF,.RES),"[T003][ready ok]")
 D EQ^MIOTASSERT($G(RES("status")),"ready","[T003][status]")
 D OK^MIOTASSERT(+$G(RES("tempcheck","ok")),"[T003][temp probe]")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 Q
 ;
T004 ; READY fails when a required runtime directory is missing
 N ROOT,CONF,RES
 S ROOT=$$TMPROOT^EFUZYTESTU("health4")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 D RMDIR^EFUZYTESTU(ROOT_"/cache")
 S ^MIO("ROUTE","COMPILE","ok")=1
 S ^MIO("CTL","PID")=$J
 D EQ^MIOTASSERT($$READY^EFUZYHEALTH(.CONF,.RES),0,"[T004][ready fail]")
 D EQ^MIOTASSERT(+$G(RES("checks","dir_cache","ok")),0,"[T004][cache missing]")
 D RESET^EFUZYTESTU(ROOT)
 K ^MIO("ROUTE"),^MIO("CTL")
 Q
 ;
