EFUZYWATT ; tests for desktop-drop automation helpers
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 Q
 ;
T001 ; drop path stages file and triggers conversion
 N CONF,ROOT,PATH,OK,POST,AUTOID,PID,ERR,RES,TXT
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("desktop-drop")
 D MKDIR^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S CONF("efuzy","userId")=41
 S CONF("efuzy","username")="deskuser"
 S PATH=ROOT_"/sample.837"
 D SAMPLE837^EFUZYTESTU(PATH,.OK)
 D OK^MIOTASSERT(OK,"[T001][sample written]")
 S POST("name")="Drop Profile"
 S POST("exportMode")="claim_summary"
 D OK^MIOTASSERT($$SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR),"[T001][profile save]")
 K POST
 S POST("name")="Desktop Auto"
 S POST("inputFolder")="/desk/in"
 S POST("outputFolder")="/desk/out"
 S POST("archiveFolder")="/desk/archive"
 S POST("errorFolder")="/desk/error"
 S POST("selectedProfile")=PID
 S POST("enabled")=1
 D OK^MIOTASSERT($$SAVEAUTO^EFUZYCFG(.CONF,.POST,.AUTOID,.ERR),"[T001][auto save]")
 D OK^MIOTASSERT($$DROPPATH^EFUZYWAT(.CONF,AUTOID,PATH,"sample.837",.RES,.ERR),"[T001][drop ok]")
 D EQ^MIOTASSERT($G(RES("conversionOk")),1,"[T001][conversion ok]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",+$G(RES("jobId")),"status")),"completed","[T001][job status]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",+$G(RES("jobId")),"automationId")),AUTOID,"[T001][automation id]")
 D OK^MIOTASSERT($$READFILE^EFUZYTESTU($G(^MIO("EFUZY","job",+$G(RES("jobId")),"outputPath")),.TXT),"[T001][read output]")
 D OK^MIOTASSERT(TXT["CLM0001,100","[T001][output row]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",+$G(RES("jobId")),"desktop","sourceResultFolder")),"archive","[T001][archive result]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
T002 ; invalid drop produces failed job and error folder state
 N CONF,ROOT,OK,POST,AUTOID,ERR,RES
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("desktop-drop-bad")
 D MKDIR^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S CONF("efuzy","userId")=42
 S CONF("efuzy","username")="deskbad"
 D WRITEFILE^EFUZYTESTU(ROOT_"/bad.837","NOTX12",.OK)
 D OK^MIOTASSERT(OK,"[T002][bad file written]")
 S POST("name")="Desktop Auto"
 S POST("inputFolder")="/desk/in"
 S POST("outputFolder")="/desk/out"
 S POST("archiveFolder")="/desk/archive"
 S POST("errorFolder")="/desk/error"
 S POST("enabled")=1
 D OK^MIOTASSERT($$SAVEAUTO^EFUZYCFG(.CONF,.POST,.AUTOID,.ERR),"[T002][auto save]")
 D OK^MIOTASSERT($$DROPPATH^EFUZYWAT(.CONF,AUTOID,ROOT_"/bad.837","bad.837",.RES,.ERR),"[T002][drop accepted]")
 D EQ^MIOTASSERT($G(RES("conversionOk")),0,"[T002][conversion failed]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",+$G(RES("jobId")),"status")),"failed","[T002][job status]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",+$G(RES("jobId")),"desktop","sourceResultFolder")),"error","[T002][error result]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;


T003 ; completed drop returns preview redirect and writes under user root
 N CONF,ROOT,PATH,OK,POST,AUTOID,PID,ERR,RES,JOBID,OUTPATH
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("desktop-drop-user-root")
 D MKDIR^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S CONF("efuzy","userId")=77
 S CONF("efuzy","username")="deskowner"
 S PATH=ROOT_"/sample-user.837"
 D SAMPLE837^EFUZYTESTU(PATH,.OK)
 D OK^MIOTASSERT(OK,"[T003][sample written]")
 S POST("name")="Desktop Profile"
 S POST("exportMode")="claim_summary"
 D OK^MIOTASSERT($$SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR),"[T003][profile save]")
 K POST
 S POST("name")="Desktop Auto"
 S POST("inputFolder")="/desk/in"
 S POST("outputFolder")="/desk/out"
 S POST("archiveFolder")="/desk/archive"
 S POST("errorFolder")="/desk/error"
 S POST("selectedProfile")=PID
 S POST("enabled")=1
 D OK^MIOTASSERT($$SAVEAUTO^EFUZYCFG(.CONF,.POST,.AUTOID,.ERR),"[T003][auto save]")
 D OK^MIOTASSERT($$DROPPATH^EFUZYWAT(.CONF,AUTOID,PATH,"sample-user.837",.RES,.ERR),"[T003][drop ok]")
 S JOBID=+$G(RES("jobId"))
 S OUTPATH=$G(^MIO("EFUZY","job",JOBID,"outputPath"))
 D EQ^MIOTASSERT($G(RES("redirect")),"/efuzy/preview/"_JOBID,"[T003][redirect preview]")
 D EQ^MIOTASSERT(OUTPATH[$$ROOT^EFUZYFS(.CONF),1,"[T003][user root output]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"ownerId")),77,"[T003][owner kept]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
