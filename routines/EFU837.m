EFU837 ; 837 workflow coordinator
 ;
 Q
 ;
PARSE(PATH,JOBID,ERR)
 N ROOT,OPT,RES,NRES
 K ERR
 I $G(PATH)="" S ERR("error")="path_required" Q 0
 I +$G(JOBID)'>0 S ERR("error")="job_required" Q 0
 S ROOT=$NA(^TMP($J,"EFU837","WF",JOBID))
 K @ROOT
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 I '+$G(RES("ok")) D  Q 0
 . S ERR("error")=$S($G(RES("error"))'="":RES("error"),1:"parse_failed")
 . D COPYDIAG(ROOT,JOBID)
 D BUILD^EFU837N(ROOT,.OPT,.NRES)
 D COPYWRK(ROOT,JOBID)
 D COPYSTAT(ROOT,JOBID)
 D COPYDIAG(ROOT,JOBID)
 K @ROOT
 Q 1
 ;
LOADPREVIEW(CONF,JOBID,TCTX)
 N I,N
 S TCTX("preview","segmentCount")=$G(^MIO("EFUZY","job",JOBID,"stats","segmentCount"))
 S TCTX("preview","claimCount")=$G(^MIO("EFUZY","job",JOBID,"stats","claimCount"))
 S TCTX("preview","serviceLineCount")=$G(^MIO("EFUZY","job",JOBID,"stats","serviceLineCount"))
 S TCTX("preview","senderId")=$G(^MIO("EFUZY","job",JOBID,"stats","senderId"))
 S TCTX("preview","receiverId")=$G(^MIO("EFUZY","job",JOBID,"stats","receiverId"))
 S TCTX("preview","version")=$G(^MIO("EFUZY","job",JOBID,"stats","version"))
 S TCTX("preview","lineCount")=$G(^MIO("EFUZY","job",JOBID,"stats","lineCount"))
 S N=0,I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","claim",I)) Q:'I!(N>=8)  D
 . S N=N+1
 . S TCTX("preview","claims",N,"claim_id")=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",I,"claim_id"))
 . S TCTX("preview","claims",N,"total_charge")=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",I,"total_charge"))
 . S TCTX("preview","claims",N,"claim_date")=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",I,"claim_date"))
 . S TCTX("preview","claims",N,"subscriber_id")=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",I,"subscriber_id"))
 . S TCTX("preview","claims",N,"patient_name")=$$PNAME(JOBID,I)
 . S TCTX("preview","claims",N,"payer_name")=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",I,"payer_name"))
 S N=0,I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","line",I)) Q:'I!(N>=12)  D
 . S N=N+1
 . S TCTX("preview","lines",N,"claim_id")=$G(^MIO("EFUZY","job",JOBID,"wrk","line",I,"claim_id"))
 . S TCTX("preview","lines",N,"line_number")=$G(^MIO("EFUZY","job",JOBID,"wrk","line",I,"line_number"))
 . S TCTX("preview","lines",N,"procedure_code")=$G(^MIO("EFUZY","job",JOBID,"wrk","line",I,"procedure_code"))
 . S TCTX("preview","lines",N,"line_charge")=$G(^MIO("EFUZY","job",JOBID,"wrk","line",I,"line_charge"))
 . S TCTX("preview","lines",N,"line_service_date")=$G(^MIO("EFUZY","job",JOBID,"wrk","line",I,"line_service_date"))
 Q
 ;
PNAME(JOBID,CLAIM)
 N L,F
 S L=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",CLAIM,"patient_last"))
 S F=$G(^MIO("EFUZY","job",JOBID,"wrk","claim",CLAIM,"patient_first"))
 Q $$COMB^EFU837MAP(L,F)
 ;
COPYSTAT(ROOT,JOBID)
 D SETSTAT^EFUZYJOB(JOBID,"segmentCount",+$G(@ROOT@("stats","segment_total")))
 D SETSTAT^EFUZYJOB(JOBID,"claimCount",+$G(@ROOT@("stats","claims")))
 D SETSTAT^EFUZYJOB(JOBID,"serviceLineCount",+$G(@ROOT@("stats","lines")))
 D SETSTAT^EFUZYJOB(JOBID,"lineCount",+$G(@ROOT@("stats","lines")))
 D SETSTAT^EFUZYJOB(JOBID,"version",$G(@ROOT@("meta","isa","version")))
 D SETSTAT^EFUZYJOB(JOBID,"senderId",$G(@ROOT@("meta","isa","sender_id")))
 D SETSTAT^EFUZYJOB(JOBID,"receiverId",$G(@ROOT@("meta","isa","receiver_id")))
 Q
 ;
COPYWRK(ROOT,JOBID)
 N CID,SID,PID,PK,LN,LIDX
 K ^MIO("EFUZY","job",JOBID,"wrk")
 S (CID,LIDX)=0
 F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . S SID=+$G(@ROOT@("norm","claim",CID,"subscriber_id"))
 . S PID=+$G(@ROOT@("norm","claim",CID,"patient_id"))
 . S PK=$S(PID>0&$D(@ROOT@("patient",PID)):"patient",1:"sub")
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"claim_index")=CID
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"claim_id")=$G(@ROOT@("norm","claim",CID,"claim_id"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"total_charge")=$G(@ROOT@("norm","claim",CID,"total_charge"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"claim_date")=$S($G(@ROOT@("norm","claim",CID,"from_date"))'="":$G(@ROOT@("norm","claim",CID,"from_date")),1:$G(@ROOT@("norm","claim",CID,"thru_date")))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"subscriber_id")=$G(@ROOT@("norm","claim",CID,"subscriber_member_id"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"subscriber_last")=$G(@ROOT@("sub",SID,"name","name_last"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"subscriber_first")=$G(@ROOT@("sub",SID,"name","name_first"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"patient_last")=$$PATLAST(ROOT,PK,PID,SID)
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"patient_first")=$$PATFIRST(ROOT,PK,PID,SID)
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"billing_provider_name")=$G(@ROOT@("norm","claim",CID,"billing_provider_name"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"payer_name")=$G(@ROOT@("norm","claim",CID,"primary_payer_name"))
 . S ^MIO("EFUZY","job",JOBID,"wrk","claim",CID,"service_line_count")=+$G(@ROOT@("norm","claim",CID,"line_count"))
 . S LN=0
 . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
 . . S LIDX=LIDX+1
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"claim_index")=CID
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"claim_id")=$G(@ROOT@("norm","line",CID,LN,"claim_id"))
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"line_number")=$G(@ROOT@("norm","line",CID,LN,"line_no"))
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"procedure_code")=$G(@ROOT@("norm","line",CID,LN,"procedure_code"))
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"procedure_qualifier")=$G(@ROOT@("norm","line",CID,LN,"procedure_qual"))
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"line_charge")=$G(@ROOT@("norm","line",CID,LN,"charge"))
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"units")=$G(@ROOT@("norm","line",CID,LN,"qty"))
 . . S ^MIO("EFUZY","job",JOBID,"wrk","line",LIDX,"line_service_date")=$G(@ROOT@("norm","line",CID,LN,"svc_date"))
 Q
 ;
PATLAST(ROOT,PK,PID,SID)
 I $G(PK)="patient" Q $G(@ROOT@("patient",PID,"name","name_last"))
 Q $G(@ROOT@("sub",SID,"name","name_last"))
 ;
PATFIRST(ROOT,PK,PID,SID)
 I $G(PK)="patient" Q $G(@ROOT@("patient",PID,"name","name_first"))
 Q $G(@ROOT@("sub",SID,"name","name_first"))
 ;
COPYDIAG(ROOT,JOBID)
 N SEV,I,N,TXT,CODE,SEGNO,SEGID
 K ^MIO("EFUZY","job",JOBID,"diag")
 F SEV="fatal","error","warning","info" D
 . S N=0,I=0
 . F  S I=$O(@ROOT@("diag",SEV,I)) Q:'I  D
 . . S N=N+1
 . . S CODE=$G(@ROOT@("diag",SEV,I,"code"))
 . . S TXT=$G(@ROOT@("diag",SEV,I,"msg"))
 . . S SEGNO=$G(@ROOT@("diag",SEV,I,"segno"))
 . . S SEGID=$G(@ROOT@("diag",SEV,I,"segid"))
 . . S ^MIO("EFUZY","job",JOBID,"diag",SEV,N)=$S(CODE'="":CODE_": ",1:"")_TXT
 . . I SEGNO'="" S ^MIO("EFUZY","job",JOBID,"diag",SEV,N)=^MIO("EFUZY","job",JOBID,"diag",SEV,N)_" [seg "_SEGNO_"]"
 . . I SEGID'="" S ^MIO("EFUZY","job",JOBID,"diag",SEV,N)=^MIO("EFUZY","job",JOBID,"diag",SEV,N)_" "_SEGID
 . I N>0 S ^MIO("EFUZY","job",JOBID,$S(SEV="warning":"warningCount",SEV="error":"errorCount",1:SEV_"Count"))=N
 Q
 ;
