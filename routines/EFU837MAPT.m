EFU837EXPMPT ; tests for EFU837EXPMP
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 Q
 ;
T001 ; load maps exposes expected modes and fields
 N TCTX
 D LOADMAPS^EFU837EXPMP(.TCTX)
 D EQ^MIOTASSERT($G(TCTX("maps","modes",1,"id")),"claim_summary","[T001][mode1]")
 D EQ^MIOTASSERT($G(TCTX("maps","modes",2,"id")),"service_line","[T001][mode2]")
 D EQ^MIOTASSERT($G(TCTX("maps","fields","claim_summary",1,"name")),"claim_id","[T001][claim field]")
 D EQ^MIOTASSERT($G(TCTX("maps","fields","service_line",3,"name")),"procedure_code","[T001][line field]")
 Q
 ;
T002 ; defaults and row source
 D EQ^MIOTASSERT($$DFLIST^EFU837EXPMP("claim_summary"),"claim_id,total_charge,claim_date,subscriber_id,subscriber_last,subscriber_first,patient_last,patient_first,billing_provider_name,payer_name,service_line_count","[T002][claim dflist]")
 D EQ^MIOTASSERT($$ROWSRC^EFU837EXPMP("service_line"),"line","[T002][line row source]")
 D EQ^MIOTASSERT($$ROWSRC^EFU837EXPMP("provider_context"),"claim","[T002][claim row source]")
 Q
 ;
T003 ; combine helper
 D EQ^MIOTASSERT($$COMB^EFU837EXPMP("DOE","JANE"),"DOE, JANE","[T003][comb full]")
 D EQ^MIOTASSERT($$COMB^EFU837EXPMP("DOE",""),"DOE","[T003][comb last only]")
 Q
 ;
