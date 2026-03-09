EFU837N ; normalization pass hooks
 ;
 ; Current baseline:
 ; The parser already stores normalized working rows.
 ; This routine exists as the extension point for:
 ; - stricter loop normalization
 ; - diagnosis enrichment
 ; - future 835 / HL7 / generic workflows
 ;
 Q
 ;
APPLY(JOBID,OUT)
 ; Populate a few redundant stats or future-normalized markers here.
 I +$G(JOBID)<1 Q
 S ^MIO("EFUZY","job",JOBID,"stats","normalized")=1
 Q
 ;
