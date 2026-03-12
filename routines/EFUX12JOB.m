EFUX12JOB ; efuzy x12 job artifact packaging helpers
 ;
 ; Public:
 ;   RUN837(INPATH,WORKBASE,JOBROOT,.OPT,.RES)
 ;   PUBLISH(JOBROOT,JOBID)
 ;
 ; Notes:
 ;   - additive artifact-oriented orchestration for 837 workflows
 ;   - standardizes job artifacts without replacing existing parser/export code
 ;   - keeps file artifacts on disk and summary/preview metadata in globals
 ;
 Q
 ;
RUN837(INPATH,WORKBASE,JOBROOT,OPT,RES) ; standard 837 artifact job
 N PROOT,CROOT,BROOT,PRES,ERES,LRES,WRES,BRES,CRES
 N BUILD,RTCHECK,MODE,PSPATH,RTPATH,JMPATH,JOBID
 K RES
 I $G(JOBROOT)="" S JOBROOT=$NA(^TMP($J,"EFUX12JOB"))
 K @JOBROOT
 S RES("ok")=0
 D INIT(JOBROOT,$G(INPATH),$G(WORKBASE),.OPT)
 I $G(INPATH)="" D FAIL(JOBROOT,"missing_inpath","Input path is required") G EXIT
 I $G(WORKBASE)="" D FAIL(JOBROOT,"missing_workbase","Work base is required") G EXIT
 S JOBID=+$G(OPT("jobid"))
 S BUILD=$$BOOL($G(OPT("build_rebuilt")),1)
 S RTCHECK=$$BOOL($G(OPT("roundtrip")),0)
 I RTCHECK S BUILD=1
 S MODE=$$OPTVAL("compare_mode","export_safe",.OPT)
 S @JOBROOT@("meta","compare_mode")=MODE
 D STAGE(JOBROOT,"input_raw","input",INPATH,"edi",$$BNAME(INPATH))
 ; parse input
 S PROOT=$NA(@JOBROOT@("wrk","parse"))
 D PARSE^EFU837P(INPATH,PROOT,.OPT,.PRES)
 M @JOBROOT@("step","parse")=PRES
 I '+$G(PRES("ok")) D FAIL(JOBROOT,"parse_failed",$G(PRES("error"),"parse_failed")) G EXIT
 D COPYSUM(PROOT,JOBROOT,.PRES)
 D COPYPREV(PROOT,JOBROOT,+$$OPTVAL("preview_claim_limit",25,.OPT),+$$OPTVAL("preview_line_limit",200,.OPT))
 ; canonical export
 D EXPORT^EFU837CAN(PROOT,WORKBASE_"-canon",.ERES)
 M @JOBROOT@("step","export")=ERES
 I '+$G(ERES("ok")) D FAIL(JOBROOT,"export_failed",$G(ERES("error"),"export_failed")) G EXIT
 D STAGE(JOBROOT,"canonical_claims","canonical",$G(ERES("claims_path")),"csv",$$BNAME($G(ERES("claims_path"))))
 D STAGE(JOBROOT,"canonical_lines","canonical",$G(ERES("lines_path")),"csv",$$BNAME($G(ERES("lines_path"))))
 I $$FEX(WORKBASE_"-canon-manifest.txt") D STAGE(JOBROOT,"canonical_manifest","canonical",WORKBASE_"-canon-manifest.txt","text",$$BNAME(WORKBASE_"-canon-manifest.txt"))
 ; parse summary report
 S PSPATH=WORKBASE_"-parse-summary.txt"
 I $$WRPSUM(PSPATH,JOBROOT) D STAGE(JOBROOT,"parse_summary","report",PSPATH,"text",$$BNAME(PSPATH))
 ; canonical load for writer
 S CROOT=$NA(@JOBROOT@("wrk","canon"))
 D LOAD^EFU837CAN(WORKBASE_"-canon",CROOT,.LRES)
 M @JOBROOT@("step","load")=LRES
 I '+$G(LRES("ok")) D FAIL(JOBROOT,"load_failed",$G(LRES("error"),"load_failed")) G EXIT
 ; deterministic writer / rebuilt artifact
 I BUILD D  I $G(@JOBROOT@("meta","status"))="failed" G EXIT
 . D WRITE^EFU837W(CROOT,WORKBASE_"-rebuilt.edi",.OPT,.WRES)
 . M @JOBROOT@("step","write")=WRES
 . I '+$G(WRES("ok")) D FAIL(JOBROOT,"write_failed",$G(WRES("error"),"write_failed")) Q
 . D STAGE(JOBROOT,"rebuilt_x12","rebuilt",WORKBASE_"-rebuilt.edi","edi",$$BNAME(WORKBASE_"-rebuilt.edi"))
 . S @JOBROOT@("summary","rebuilt_transactions")=+$G(WRES("transactions"))
 ; optional rebuilt parse + compare report
 I RTCHECK,$G(@JOBROOT@("meta","status"))'="failed" D  I $G(@JOBROOT@("meta","status"))="failed" G EXIT
 . S BROOT=$NA(@JOBROOT@("wrk","rebuilt"))
 . D PARSE^EFU837P(WORKBASE_"-rebuilt.edi",BROOT,.OPT,.BRES)
 . M @JOBROOT@("step","parse_rebuilt")=BRES
 . I '+$G(BRES("ok")) D FAIL(JOBROOT,"parse_rebuilt_failed",$G(BRES("error"),"parse_rebuilt_failed")) Q
 . D DOCOMP(PROOT,BROOT,MODE,.OPT,.CRES)
 . M @JOBROOT@("step","compare")=CRES
 . S @JOBROOT@("summary","roundtrip_ok")=+$G(CRES("ok"))
 . S @JOBROOT@("summary","roundtrip_mismatch_count")=+$G(CRES("summary","mismatch_count"))
 . S @JOBROOT@("summary","roundtrip_missing_count")=+$G(CRES("summary","missing_count"))
 . S RTPATH=WORKBASE_"-roundtrip.txt"
 . I $$WRRT(RTPATH,.CRES) D STAGE(JOBROOT,"roundtrip_report","report",RTPATH,"text",$$BNAME(RTPATH))
 . I '+$G(CRES("ok")) D FAIL(JOBROOT,"roundtrip_compare_failed","Round-trip comparison failed") Q
 ; success
 I $G(@JOBROOT@("meta","status"))'="failed" D DONE(JOBROOT)
EXIT ; finalize job manifest and optional efuzy publication
 S JMPATH=WORKBASE_"-job.txt"
 I $G(WORKBASE)'="" I $$WRJOB(JMPATH,JOBROOT,.RES) D STAGE(JOBROOT,"job_manifest","manifest",JMPATH,"text",$$BNAME(JMPATH))
 S RES("ok")=$S($G(@JOBROOT@("meta","status"))="completed":1,1:0)
 S RES("status")=$G(@JOBROOT@("meta","status"))
 S RES("root")=JOBROOT
 S RES("artifacts")=+$G(@JOBROOT@("artifact_last"))
 M RES("summary")=@JOBROOT@("summary")
 I JOBID>0 D PUBLISH(JOBROOT,JOBID)
 Q
 ;
INIT(JOBROOT,INPATH,WORKBASE,OPT) ; initialize job root metadata
 S @JOBROOT@("meta","workflow")=$$OPTVAL("workflow","837_artifact_job",.OPT)
 S @JOBROOT@("meta","status")="running"
 S @JOBROOT@("meta","created_h")=$H
 S @JOBROOT@("meta","input_path")=$G(INPATH)
 S @JOBROOT@("meta","workbase")=$G(WORKBASE)
 S @JOBROOT@("meta","roundtrip_requested")=$$BOOL($G(OPT("roundtrip")),0)
 S @JOBROOT@("meta","build_rebuilt")=$$BOOL($G(OPT("build_rebuilt")),1)
 Q
 ;
DONE(JOBROOT) ; mark job completed
 S @JOBROOT@("meta","status")="completed"
 S @JOBROOT@("meta","ended_h")=$H
 Q
 ;
FAIL(JOBROOT,CODE,TXT) ; mark job failed
 S @JOBROOT@("meta","status")="failed"
 S @JOBROOT@("meta","ended_h")=$H
 S @JOBROOT@("meta","error_code")=$G(CODE)
 S @JOBROOT@("meta","error_text")=$G(TXT)
 Q
 ;
STAGE(JOBROOT,KEY,ROLE,PATH,TYPE,NAME) ; register one artifact
 N N
 I $G(KEY)="" Q
 S N=+$G(@JOBROOT@("artifact_last"))+1
 S @JOBROOT@("artifact_last")=N
 S @JOBROOT@("artifact",KEY,"id")=N
 S @JOBROOT@("artifact",KEY,"key")=KEY
 S @JOBROOT@("artifact",KEY,"role")=$G(ROLE)
 S @JOBROOT@("artifact",KEY,"path")=$G(PATH)
 S @JOBROOT@("artifact",KEY,"type")=$G(TYPE)
 S @JOBROOT@("artifact",KEY,"name")=$S($G(NAME)'="":$G(NAME),1:$$BNAME($G(PATH)))
 S @JOBROOT@("artifact",KEY,"exists")=$$FEX($G(PATH))
 S @JOBROOT@("artifact",KEY,"created_h")=$H
 S @JOBROOT@("artifact_by_id",N)=KEY
 S @JOBROOT@("artifact_by_role",$G(ROLE),KEY)=""
 Q
 ;
COPYSUM(PROOT,JOBROOT,PRES) ; copy top-level parse stats and diag counts
 S @JOBROOT@("summary","claims")=+$G(@PROOT@("stats","claims"))
 S @JOBROOT@("summary","lines")=+$G(@PROOT@("stats","lines"))
 S @JOBROOT@("summary","transactions")=+$G(@PROOT@("stats","transactions"))
 S @JOBROOT@("summary","segments")=+$G(@PROOT@("stats","segment_total"))
 S @JOBROOT@("summary","warnings")=+$G(PRES("warnings"),+$G(@PROOT@("diag","warning","last")))
 S @JOBROOT@("summary","errors")=+$G(PRES("errors"),+$G(@PROOT@("diag","error","last")))
 S @JOBROOT@("summary","tx_kind")=$G(@PROOT@("norm","claim",1,"tx_kind"))
 S @JOBROOT@("summary","guide")=$G(@PROOT@("norm","claim",1,"guide"))
 Q
 ;
COPYPREV(PROOT,JOBROOT,CLIM,LLIM) ; lightweight preview copy for UI/job history use
 N CID,CN,LN,LNOUT
 K @JOBROOT@("preview")
 S CLIM=+$G(CLIM) I CLIM<1 S CLIM=25
 S LLIM=+$G(LLIM) I LLIM<1 S LLIM=200
 S CID=0,CN=0,LNOUT=0
 F  S CID=$O(@PROOT@("norm","claim",CID)) Q:'CID!(CN>=CLIM)  D
 . S CN=CN+1
 . D PREVC(PROOT,JOBROOT,CID,CN)
 . S LN=0
 . F  S LN=$O(@PROOT@("norm","line",CID,LN)) Q:'LN!(LNOUT>=LLIM)  D
 . . S LNOUT=LNOUT+1
 . . D PREVL(PROOT,JOBROOT,CID,LN,LNOUT)
 S @JOBROOT@("preview","claims")=CN
 S @JOBROOT@("preview","lines")=LNOUT
 Q
 ;
PREVC(PROOT,JOBROOT,CID,CN) ; one preview claim row
 N K
 F K="claim_id","tx_kind","guide","tx_control","total_charge","from_date","thru_date","facility_code","claim_freq","claim_type","subscriber_name","subscriber_member_id","patient_name","patient_member_id","primary_payer_name","billing_provider_name","billing_provider_npi","attending_provider_name","attending_provider_id","diag_codes","line_count" D
 . S @JOBROOT@("preview","claim",CN,K)=$G(@PROOT@("norm","claim",CID,K))
 Q
 ;
PREVL(PROOT,JOBROOT,CID,LN,LNOUT) ; one preview line row
 N K
 F K="claim_id","line_no","service_kind","revenue_code","procedure_qual","procedure_code","charge","uom","qty","svc_date" D
 . S @JOBROOT@("preview","line",LNOUT,K)=$G(@PROOT@("norm","line",CID,LN,K))
 Q
 ;
DOCOMP(PROOT,BROOT,MODE,OPT,CRES) ; compare wrapper with backward compatibility
 K CRES
 I $T(COMPAREM^EFU837RT)'="" D  Q
 . D COMPAREM^EFU837RT(PROOT,BROOT,$G(MODE),.OPT,.CRES)
 D COMPARE^EFU837RT(PROOT,BROOT,.CRES)
 S CRES("compare_mode")=$G(MODE)
 S CRES("summary","mode")=$G(MODE)
 Q
 ;
WRPSUM(PATH,JOBROOT) ; write parse summary report file
 N DEV,OLDIO,OK
 S OK=0,DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q 0
 U DEV
 W "workflow="_$G(@JOBROOT@("meta","workflow")),!
 W "status="_$G(@JOBROOT@("meta","status")),!
 W "input_path="_$G(@JOBROOT@("meta","input_path")),!
 W "claims="_$G(@JOBROOT@("summary","claims")),!
 W "lines="_$G(@JOBROOT@("summary","lines")),!
 W "transactions="_$G(@JOBROOT@("summary","transactions")),!
 W "segments="_$G(@JOBROOT@("summary","segments")),!
 W "warnings="_$G(@JOBROOT@("summary","warnings")),!
 W "errors="_$G(@JOBROOT@("summary","errors")),!
 W "tx_kind="_$G(@JOBROOT@("summary","tx_kind")),!
 W "guide="_$G(@JOBROOT@("summary","guide")),!
 C DEV U OLDIO
 Q 1
 ;
WRRT(PATH,CRES) ; write round-trip comparison summary report
 N DEV,OLDIO
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q 0
 U DEV
 W "compare_mode="_$G(CRES("compare_mode"),$G(CRES("summary","mode"))),!
 W "ok="_+$G(CRES("ok")),!
 W "mismatch_count="_+$G(CRES("summary","mismatch_count")),!
 W "missing_count="_+$G(CRES("summary","missing_count")),!
 W "claim_compared="_+$G(CRES("summary","claim_compared")),!
 W "line_compared="_+$G(CRES("summary","line_compared")),!
 C DEV U OLDIO
 Q 1
 ;
WRJOB(PATH,JOBROOT,RES) ; write top-level job manifest/report
 N DEV,OLDIO,N,KEY
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q 0
 U DEV
 W "workflow="_$G(@JOBROOT@("meta","workflow")),!
 W "status="_$G(@JOBROOT@("meta","status")),!
 W "error_code="_$G(@JOBROOT@("meta","error_code")),!
 W "error_text="_$G(@JOBROOT@("meta","error_text")),!
 W "input_path="_$G(@JOBROOT@("meta","input_path")),!
 W "workbase="_$G(@JOBROOT@("meta","workbase")),!
 W "compare_mode="_$G(@JOBROOT@("meta","compare_mode")),!
 W "claims="_$G(@JOBROOT@("summary","claims")),!
 W "lines="_$G(@JOBROOT@("summary","lines")),!
 W "transactions="_$G(@JOBROOT@("summary","transactions")),!
 W "warnings="_$G(@JOBROOT@("summary","warnings")),!
 W "errors="_$G(@JOBROOT@("summary","errors")),!
 W "artifacts="_+$G(@JOBROOT@("artifact_last")),!
 S N=0
 F  S N=$O(@JOBROOT@("artifact_by_id",N)) Q:'N  D
 . S KEY=$G(@JOBROOT@("artifact_by_id",N)) Q:KEY=""
 . W "artifact."_KEY_".role="_$G(@JOBROOT@("artifact",KEY,"role")),!
 . W "artifact."_KEY_".path="_$G(@JOBROOT@("artifact",KEY,"path")),!
 . W "artifact."_KEY_".type="_$G(@JOBROOT@("artifact",KEY,"type")),!
 C DEV U OLDIO
 Q 1
 ;
PUBLISH(JOBROOT,JOBID) ; optional publish into ^MIO("EFUZY","job") global shape
 N KEY,N
 I +$G(JOBID)<1 Q
 S ^MIO("EFUZY","job",JOBID,"workflowType")=$G(@JOBROOT@("meta","workflow"))
 S ^MIO("EFUZY","job",JOBID,"status")=$G(@JOBROOT@("meta","status"))
 S ^MIO("EFUZY","job",JOBID,"inputPath")=$G(@JOBROOT@("meta","input_path"))
 S ^MIO("EFUZY","job",JOBID,"diagSummary")=$S($G(@JOBROOT@("meta","error_text"))'="":$G(@JOBROOT@("meta","error_text")),1:"")
 S ^MIO("EFUZY","job",JOBID,"warningCount")=+$G(@JOBROOT@("summary","warnings"))
 S ^MIO("EFUZY","job",JOBID,"errorCount")=+$G(@JOBROOT@("summary","errors"))
 S ^MIO("EFUZY","job",JOBID,"stats","claims")=+$G(@JOBROOT@("summary","claims"))
 S ^MIO("EFUZY","job",JOBID,"stats","lines")=+$G(@JOBROOT@("summary","lines"))
 S ^MIO("EFUZY","job",JOBID,"stats","transactions")=+$G(@JOBROOT@("summary","transactions"))
 S ^MIO("EFUZY","job",JOBID,"stats","roundtripOk")=+$G(@JOBROOT@("summary","roundtrip_ok"))
 S N=0
 F  S N=$O(@JOBROOT@("artifact_by_id",N)) Q:'N  D
 . S KEY=$G(@JOBROOT@("artifact_by_id",N)) Q:KEY=""
 . S ^MIO("EFUZY","job",JOBID,"artifact",KEY,"path")=$G(@JOBROOT@("artifact",KEY,"path"))
 . S ^MIO("EFUZY","job",JOBID,"artifact",KEY,"type")=$G(@JOBROOT@("artifact",KEY,"type"))
 . S ^MIO("EFUZY","job",JOBID,"artifact",KEY,"name")=$G(@JOBROOT@("artifact",KEY,"name"))
 Q
 ;
BOOL(VAL,DEF) ; normalize boolean-like option value
 I $G(VAL)="" Q +$G(DEF)
 I +$G(VAL)=0 Q 0
 Q 1
 ;
OPTVAL(KEY,DEF,OPT) ; option value helper
 I $D(OPT($G(KEY))) Q $G(OPT($G(KEY)))
 Q $G(DEF)
 ;
BNAME(PATH) ; basename of path
 N N
 S N=$L($G(PATH),"/")
 Q $P($G(PATH),"/",N)
 ;
FEX(PATH) ; file exists helper
 Q $S($ZSEARCH($G(PATH))'="":1,1:0)
 ;
