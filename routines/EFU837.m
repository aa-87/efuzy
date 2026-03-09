EFU837 ; 837 workflow coordinator
 ;
 Q
 ;
PARSE(PATH,JOBID,ERR)
 N CFG,OUT
 K ERR
 S CFG("jobId")=JOBID
 I '$$PARSE^EFU837P(PATH,.CFG,.OUT,.ERR) Q 0
 D APPLY^EFU837N(JOBID,.OUT)
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
