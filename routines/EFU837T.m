EFU837T ; efuzy X12 837 parser tests
 ;
 ; Public:
 ;   START
 ;   ALL(BASE)
 ;   CORE(.FAIL)
 ;   EXAMPLES(BASE,.FAIL)
 ;
 ; Notes:
 ;   - quiet on success
 ;   - D ^EFU837T runs START
 ;   - BASE should point to the extracted folder that contains
 ;       Examples 1/
 ;       Examples 2/
 ;
 D START
 Q
 ;
START ; run core suite, optionally auto-detect external example base
 N BASE
 S BASE=$$AUTBASE()
 D ALL(BASE)
 Q
 ;
ALL(BASE) ; full suite
 N FAIL,RBASE
 S FAIL=0
 D CORE(.FAIL)
 D META(.FAIL)
 S RBASE=$$RESBASE($G(BASE))
 I $G(BASE)="",RBASE="" S RBASE=$$AUTBASE()
 I RBASE'="" D EXAMPLES(RBASE,.FAIL)
 E  I $G(BASE)'="" D FAILBASE(.FAIL,BASE)
 I 'FAIL W !,"OK - EFU837T"
 Q
;
CORE(FAIL) ; embedded parser / validator / exporter tests
 D T001(.FAIL)
 D T002(.FAIL)
 D T003(.FAIL)
 D T004(.FAIL)
 D T005(.FAIL)
 D T006(.FAIL)
 D T007(.FAIL)
 D T008(.FAIL)
 D T009(.FAIL)
 D T010(.FAIL)
 D T011(.FAIL)
 D T012(.FAIL)
 D T013(.FAIL)
 D T014(.FAIL)
 D T015(.FAIL)
 D T016(.FAIL)
 D T017(.FAIL)
 D T018(.FAIL)
 D T019(.FAIL)
 D T020(.FAIL)
 D T021(.FAIL)
 D T022(.FAIL)
 D T023(.FAIL)
 D T024(.FAIL)
 Q
 ;
META(FAIL) ; metadata and table consistency checks
 D M001(.FAIL)
 D M002(.FAIL)
 Q
 ;
EXAMPLES(BASE,FAIL) ; run uploaded example suites
 N RBASE
 S RBASE=$$RESBASE($G(BASE))
 I RBASE="" S RBASE=$$AUTBASE()
 I RBASE="" D FAILBASE(.FAIL,$G(BASE)) Q
 D T100(.FAIL,RBASE)
 D T101(.FAIL,RBASE)
 D T102(.FAIL,RBASE)
 D T200(.FAIL,RBASE)
 D T201(.FAIL,RBASE)
 Q
 ;
T001(FAIL) ; delimiter detection on canonical ISA sample
 N PATH,ERR,DEL
 S PATH=$$WRFILE($$SAMPLEI())
 D DETECT^EFU837S(PATH,.DEL,.ERR)
 D EQ(.FAIL,"[T001][detect err]",+$G(ERR),0)
 D EQ(.FAIL,"[T001][elem]",$G(DEL("elem")),"*")
 D EQ(.FAIL,"[T001][seg]",$G(DEL("seg")),"~")
 D EQ(.FAIL,"[T001][comp]",$G(DEL("comp")),":")
 D EQ(.FAIL,"[T001][rep]",$G(DEL("rep")),">")
 D EQ(.FAIL,"[T001][framing]",$G(DEL("framing")),"interchange")
 D RMFILE(PATH)
 Q
 ;
T002(FAIL) ; parse institutional sample counts and key fields
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",2))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T002][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T002][transactions]",+$G(@ROOT@("stats","transactions")),1)
 D EQ(.FAIL,"[T002][claims]",+$G(@ROOT@("stats","claims")),1)
 D EQ(.FAIL,"[T002][lines]",+$G(@ROOT@("stats","lines")),2)
 D EQ(.FAIL,"[T002][guide]",$G(@ROOT@("tx",1,"st","guide")),"005010X223A2")
 D EQ(.FAIL,"[T002][claim id]",$G(@ROOT@("claim",1,"claim_id")),"756048Q")
 D EQ(.FAIL,"[T002][svc1 code]",$G(@ROOT@("claim",1,"line",1,"proc_code")),"85025")
 D EQ(.FAIL,"[T002][svc2 code]",$G(@ROOT@("claim",1,"line",2,"proc_code")),"93005")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T003(FAIL) ; normalization rows and payer folding
 N PATH,ROOT,RES,ROW,OPT
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",3))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D ROWCLAIM^EFU837MAP(ROOT,1,.ROW)
 D EQ(.FAIL,"[T003][claim row id]",$G(ROW(1)),"756048Q")
 D EQ(.FAIL,"[T003][from date]",$G(ROW(3)),"19960911")
 D EQ(.FAIL,"[T003][thru date]",$G(ROW(4)),"19960911")
 D EQ(.FAIL,"[T003][subscriber]",$G(@ROOT@("norm","claim",1,"subscriber_name")),"DOE, JOHN T")
 D EQ(.FAIL,"[T003][primary payer]",$G(@ROOT@("norm","claim",1,"primary_payer_name")),"MEDICARE B")
 D EQ(.FAIL,"[T003][other payer]",$G(@ROOT@("norm","claim",1,"other_payer_name")),"STATE TEACHERS")
 D EQ(.FAIL,"[T003][billing prov]",$G(@ROOT@("norm","claim",1,"billing_provider_name")),"JONES HOSPITAL")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T004(FAIL) ; diagnosis extraction and institutional line kind
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",4))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T004][diag1 qual]",$G(@ROOT@("claim",1,"diag",1,"qual")),"BK")
 D EQ(.FAIL,"[T004][diag1 code]",$G(@ROOT@("claim",1,"diag",1,"code")),"3669")
 D EQ(.FAIL,"[T004][line kind]",$G(@ROOT@("norm","line",1,1,"service_kind")),"SV2")
 D EQ(.FAIL,"[T004][rev code]",$G(@ROOT@("norm","line",1,1,"revenue_code")),"0305")
 D EQ(.FAIL,"[T004][diag join]",$G(@ROOT@("norm","claim",1,"diag_codes")),"3669|4019|79431|A1|A2|B1|B2|A2|09")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T005(FAIL) ; malformed missing IEA
 N PATH,ROOT,RES,DATA,OPT
 S DATA=$$SAMPLEI()
 S DATA=$P(DATA,"IEA*",1)
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",5))
 D PREVIEW^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T005][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T005][missing iea diag]",$$HASDIAG(ROOT,"error","missing_iea"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T006(FAIL) ; malformed LX before CLM
 N PATH,ROOT,RES,DATA,OPT
 S DATA="ISA*00*          *00*          *ZZ*SENDERID1234567*ZZ*RECEIVER1234567*080503*1705*^*00501*000000001*0*T*:~"
 S DATA=DATA_"GS*HC*S*R*20080503*1705*1*X*005010X223A2~"
 S DATA=DATA_"ST*837*1*005010X223A2~BHT*0019*00*ABC*20260309*1200*CH~LX*1~SV2*0305*HC:85025*13.39*UN*1~SE*5*1~GE*1*1~IEA*1*000000001~"
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",6))
 D PREVIEW^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T006][lx error]",$$HASDIAG(ROOT,"error","lx_without_claim"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T007(FAIL) ; chunk boundary smoke on institutional sample
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",7))
 S OPT("chunk")=7
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T007][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T007][claims]",+$G(@ROOT@("stats","claims")),1)
 D EQ(.FAIL,"[T007][lines]",+$G(@ROOT@("stats","lines")),2)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T008(FAIL) ; subscriber doubles as patient when no 2000C HL
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",8))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T008][patient name]",$G(@ROOT@("norm","claim",1,"patient_name")),"DOE, JOHN T")
 D EQ(.FAIL,"[T008][patient member id]",$G(@ROOT@("norm","claim",1,"patient_member_id")),"030005074A")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T009(FAIL) ; transaction-only sample parses with warning, not error
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEP())
 S ROOT=$NA(^TMP($J,"EFU837T",9))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T009][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T009][framing]",$G(@ROOT@("meta","delim","framing")),"transaction")
 D EQ(.FAIL,"[T009][tx_only warn]",$$HASDIAG(ROOT,"warning","tx_only_no_isa"),1)
 D EQ(.FAIL,"[T009][kind]",$G(@ROOT@("norm","claim",1,"tx_kind")),"837P")
 D EQ(.FAIL,"[T009][proc]",$G(@ROOT@("norm","line",1,1,"procedure_code")),"99213")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T010(FAIL) ; SE count mismatch is warning only
 N PATH,ROOT,RES,DATA,OPT
 S DATA=$$SAMPLEP()
 S DATA=$$REPL(DATA,"SE*14*1~","SE*99*1~")
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",10))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T010][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T010][warning]",$$HASDIAG(ROOT,"warning","se_count_mismatch"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T011(FAIL) ; ST and SE control mismatch is hard error
 N PATH,ROOT,RES,DATA,OPT
 S DATA=$$SAMPLEP()
 S DATA=$$REPL(DATA,"SE*14*1~","SE*14*999~")
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",11))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T011][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T011][st se mismatch]",$$HASDIAG(ROOT,"error","st_se_mismatch"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T012(FAIL) ; GS and GE control mismatch is hard error
 N PATH,ROOT,RES,DATA,OPT
 S DATA=$$SAMPLEI()
 S DATA=$$REPL(DATA,"GE*1*20213~","GE*1*99999~")
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",12))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T012][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T012][gs ge mismatch]",$$HASDIAG(ROOT,"error","gs_ge_mismatch"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T013(FAIL) ; ISA and IEA control mismatch is hard error
 N PATH,ROOT,RES,DATA,OPT
 S DATA=$$SAMPLEI()
 S DATA=$$REPL(DATA,"IEA*1*000010216~","IEA*1*000010999~")
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",13))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T013][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T013][isa iea mismatch]",$$HASDIAG(ROOT,"error","isa_iea_mismatch"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T014(FAIL) ; multi-transaction transaction-only sample
 N PATH,ROOT,RES,DATA,OPT
 S DATA=$$SAMPLEP()_$$SAMPLEP2()
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",14))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T014][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T014][transactions]",+$G(@ROOT@("stats","transactions")),2)
 D EQ(.FAIL,"[T014][claims]",+$G(@ROOT@("stats","claims")),2)
 D EQ(.FAIL,"[T014][lines]",+$G(@ROOT@("stats","lines")),2)
 D EQ(.FAIL,"[T014][claim2 id]",$G(@ROOT@("claim",2,"claim_id")),"PCLM2")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T015(FAIL) ; professional SV1 line normalization
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEP())
 S ROOT=$NA(^TMP($J,"EFU837T",15))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T015][service kind]",$G(@ROOT@("norm","line",1,1,"service_kind")),"SV1")
 D EQ(.FAIL,"[T015][proc qual]",$G(@ROOT@("norm","line",1,1,"procedure_qual")),"HC")
 D EQ(.FAIL,"[T015][proc code]",$G(@ROOT@("norm","line",1,1,"procedure_code")),"99213")
 D EQ(.FAIL,"[T015][svc date]",$G(@ROOT@("norm","line",1,1,"svc_date")),"20260115")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T016(FAIL) ; dental SV3 line normalization
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLED())
 S ROOT=$NA(^TMP($J,"EFU837T",16))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T016][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T016][kind]",$G(@ROOT@("norm","claim",1,"tx_kind")),"837D")
 D EQ(.FAIL,"[T016][service kind]",$G(@ROOT@("norm","line",1,1,"service_kind")),"SV3")
 D EQ(.FAIL,"[T016][proc qual]",$G(@ROOT@("norm","line",1,1,"procedure_qual")),"AD")
 D EQ(.FAIL,"[T016][proc code]",$G(@ROOT@("norm","line",1,1,"procedure_code")),"D0120")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T017(FAIL) ; transaction fallback delimiter detection with alternate element separator
 N PATH,ROOT,RES,DEL,ERR,OPT
 S PATH=$$WRFILE($$SAMPLEPIPE())
 D DETECT^EFU837S(PATH,.DEL,.ERR)
 D EQ(.FAIL,"[T017][detect err]",+$G(ERR),0)
 D EQ(.FAIL,"[T017][elem]",$G(DEL("elem")),"|")
 D EQ(.FAIL,"[T017][seg]",$G(DEL("seg")),"~")
 S ROOT=$NA(^TMP($J,"EFU837T",17))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T017][parse ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T017][claim]",$G(@ROOT@("claim",1,"claim_id")),"PIPE1")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T018(FAIL) ; CRLF between segments is tolerated
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$CRLF($$SAMPLEI()))
 S ROOT=$NA(^TMP($J,"EFU837T",18))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T018][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T018][claims]",+$G(@ROOT@("stats","claims")),1)
 D EQ(.FAIL,"[T018][lines]",+$G(@ROOT@("stats","lines")),2)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T019(FAIL) ; single-file CSV export writes all expected files
 N PATH,ROOT,RES,OPT,OUTBASE
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",19))
 S OUTBASE="/tmp/efu837t-exp-"_$J_"-19"
 D EXPORT^EFU837CSV(PATH,OUTBASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T019][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T019][combined rows]",+$G(RES("combined_rows")),2)
 D EQ(.FAIL,"[T019][claim rows]",+$G(RES("claim_rows")),1)
 D EQ(.FAIL,"[T019][line rows]",+$G(RES("line_rows")),2)
 D EQ(.FAIL,"[T019][combined exists]",$$EXIST(OUTBASE_".csv"),1)
 D EQ(.FAIL,"[T019][claims exists]",$$EXIST(OUTBASE_"-Claims.csv"),1)
 D EQ(.FAIL,"[T019][lines exists]",$$EXIST(OUTBASE_"-Lines.csv"),1)
 D EQ(.FAIL,"[T019][subs exists]",$$EXIST(OUTBASE_"-Subscribers.csv"),1)
 D EQ(.FAIL,"[T019][prov exists]",$$EXIST(OUTBASE_"-Providers.csv"),1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T020(FAIL) ; CSVROWS excludes header and blank trailing lines
 N PATH,DATA
 S DATA="a,b,c"_$C(10)_"1,2,3"_$C(10)_"4,5,6"_$C(10,10)
 S PATH=$$WRFILE(DATA)
 D EQ(.FAIL,"[T020][combined csv rows]",$$CSVROWS(PATH),2)
 D RMFILE(PATH)
 Q
 ;
T021(FAIL) ; preview mode returns counts and skips normalization requirement
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEP())
 S ROOT=$NA(^TMP($J,"EFU837T",21))
 D PREVIEW^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T021][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T021][claims]",+$G(RES("claims")),1)
 D EQ(.FAIL,"[T021][segments positive]",+$G(RES("segments"))>0,1)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T022(FAIL) ; no-claims preview warns but does not error when ST/SE are present
 N PATH,ROOT,RES,DATA,OPT
 S DATA="ST*837*1*005010X222A1~BHT*0019*00*B1*20260115*1015*CH~SE*3*1~"
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T",22))
 D PREVIEW^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T022][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T022][no claims warn]",$$HASDIAG(ROOT,"warning","no_claims"),1)
 D EQ(.FAIL,"[T022][claims zero]",+$G(@ROOT@("stats","claims")),0)
 D RMFILE(PATH) K @ROOT
 Q
 ;
T023(FAIL) ; claim-level provider normalization from institutional sample
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837T",23))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T023][attending name]",$G(@ROOT@("norm","claim",1,"attending_provider_name")),"JONES, JOHN J")
 D EQ(.FAIL,"[T023][attending id]",$G(@ROOT@("norm","claim",1,"attending_provider_id")),"")
 D EQ(.FAIL,"[T023][prov ref 1g]",$G(@ROOT@("claim",1,"provider","71","ref","1G")),"B99937")
 D RMFILE(PATH) K @ROOT
 Q
 ;
T024(FAIL) ; scanner handles very small chunk sizes on tx-only professional sample
 N PATH,ROOT,RES,OPT
 S PATH=$$WRFILE($$SAMPLEP())
 S ROOT=$NA(^TMP($J,"EFU837T",24))
 S OPT("chunk")=3
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T024][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T024][claim]",$G(@ROOT@("claim",1,"claim_id")),"PCLM1")
 D EQ(.FAIL,"[T024][line]",$G(@ROOT@("claim",1,"line",1,"proc_code")),"99213")
 D RMFILE(PATH) K @ROOT
 Q
 ;
M001(FAIL) ; metadata tables remain aligned with expected file counts
 D EQ(.FAIL,"[M001][ex1 rows]",$$COUNTDATA("EX1DATA"),18)
 D EQ(.FAIL,"[M001][ex2 rows]",$$COUNTDATA("EX2DATA"),29)
 Q
 ;
M002(FAIL) ; embedded samples represent all current MVP transaction kinds
 D EQ(.FAIL,"[M002][sample i kind]",$$SAMPLEK($$SAMPLEI()),"837I")
 D EQ(.FAIL,"[M002][sample p kind]",$$SAMPLEK($$SAMPLEP()),"837P")
 D EQ(.FAIL,"[M002][sample d kind]",$$SAMPLEK($$SAMPLED()),"837D")
 Q
 ;
T100(FAIL,BASE) ; Example 1 raw-structure + benchmark integrity suite
 N I,REC,FILE,KIND,GUIDE,CLAIMS,LINES,COMB,CCSV,LCSV,EX
 N PATH,RAW,BN,BC,BCL,BL,LAB
 F I=1:1 S REC=$P($T(EX1DATA+I),";;",2,99) Q:REC=""  D
 . S FILE=$P(REC,"|",1),KIND=$P(REC,"|",2),GUIDE=$P(REC,"|",3)
 . S CLAIMS=+$P(REC,"|",4),LINES=+$P(REC,"|",5),COMB=+$P(REC,"|",6)
 . S CCSV=+$P(REC,"|",7),LCSV=+$P(REC,"|",8)
 . S PATH=$$EX1SRCF(BASE,FILE),LAB="[T100]["_FILE_"]",EX=$$EXIST(PATH)
 . D EQ(.FAIL,LAB_"[source exists]",EX,1)
 . I 'EX Q
 . D RAWMETA(PATH,.RAW)
 . D EQ(.FAIL,LAB_"[raw ok]",+$G(RAW("ok")),1)
 . I '+$G(RAW("ok")) Q
 . D EQ(.FAIL,LAB_"[kind]",$G(RAW("kind")),KIND)
 . D EQ(.FAIL,LAB_"[guide]",$$GUIDEOK($G(RAW("guide")),GUIDE),1)
 . D EQ(.FAIL,LAB_"[claims]",+$G(RAW("claims")),CLAIMS)
 . D EQ(.FAIL,LAB_"[lines]",+$G(RAW("lines")),LINES)
 . I (COMB>0)!(CCSV>0)!(LCSV>0) D
 . . S BN=$$EX1CSVBASE(BASE,FILE)
 . . I BN'="" D
 . . . S BC=BN_".csv",BCL=BN_"-Claims.csv",BL=BN_"-Lines.csv"
 . . . I COMB>0,$$EXIST(BC) D EQ(.FAIL,LAB_"[benchmark combined]",$$CSVROWS(BC),COMB)
 . . . I CCSV>0,$$EXIST(BCL) D EQ(.FAIL,LAB_"[benchmark claims]",$$CSVROWS(BCL),CCSV)
 . . . I LCSV>0,$$EXIST(BL) D EQ(.FAIL,LAB_"[benchmark lines]",$$CSVROWS(BL),LCSV)
 Q
 ;
T101(FAIL,BASE) ; Example 1 exact source discovery under resolved base
 D EQ(.FAIL,"[T101][ok]",$$EX1DIRCNT(BASE)=18,1)
 D EQ(.FAIL,"[T101][files]",$$EX1DIRCNT(BASE),18)
 D EQ(.FAIL,"[T101][first file ok]",$$EX1SRC(BASE,1)'="",1)
 Q
 ;
T102(FAIL,BASE) ; Example 1 filesystem count matches metadata table
 D EQ(.FAIL,"[T102][ex1 dir count]",$$EX1DIRCNT(BASE),$$COUNTDATA("EX1DATA"))
 Q
 ;
T200(FAIL,BASE) ; Example 2 raw-structure coverage suite
 N I,REC,SUB,FILE,KIND,GUIDE,CLAIMS,LINES,EX
 N PATH,RAW,LAB
 F I=1:1 S REC=$P($T(EX2DATA+I),";;",2,99) Q:REC=""  D
 . S SUB=$P(REC,"|",1),FILE=$P(REC,"|",2),KIND=$P(REC,"|",3),GUIDE=$P(REC,"|",4)
 . S CLAIMS=+$P(REC,"|",5),LINES=+$P(REC,"|",6)
 . S PATH=$$EX2SRCF(BASE,SUB,FILE),LAB="[T200]["_FILE_"]",EX=$$EXIST(PATH)
 . D EQ(.FAIL,LAB_"[source exists]",EX,1)
 . I 'EX Q
 . D RAWMETA(PATH,.RAW)
 . D EQ(.FAIL,LAB_"[raw ok]",+$G(RAW("ok")),1)
 . I '+$G(RAW("ok")) Q
 . D EQ(.FAIL,LAB_"[kind]",$G(RAW("kind")),KIND)
 . D EQ(.FAIL,LAB_"[guide]",$$GUIDEOK($G(RAW("guide")),GUIDE),1)
 . D EQ(.FAIL,LAB_"[claims]",+$G(RAW("claims")),CLAIMS)
 . D EQ(.FAIL,LAB_"[lines]",+$G(RAW("lines")),LINES)
 Q
 ;
T201(FAIL,BASE) ; Example 2 filesystem count matches metadata table
 D EQ(.FAIL,"[T201][ex2 dir count]",$$EX2DIRCNT(BASE),$$COUNTDATA("EX2DATA"))
 Q
 ;
RAWMETA(PATH,OUT) ; light-weight raw scanner coverage for external examples
 N TXT,ERR,SEP,SEGSEP,I,N,SEG,TOK,ID
 K OUT
 S OUT("ok")=0,OUT("claims")=0,OUT("lines")=0,OUT("transactions")=0
 S OUT("sv1")=0,OUT("sv2")=0,OUT("sv3")=0
 S TXT=$$READALL(PATH,.ERR)
 I +$G(ERR)!(TXT="") Q
 S SEP=$$RAWSEP(TXT)
 S SEGSEP=$S(TXT["~":"~",1:"~")
 S N=$L(TXT,SEGSEP)
 F I=1:1:N D
 . S SEG=$$TRSEG($P(TXT,SEGSEP,I))
 . I SEG="" Q
 . D TOKR(SEG,SEP,.TOK)
 . S ID=$G(TOK("id"))
 . I ID="ST",$G(TOK(1))="837" D
 . . S OUT("transactions")=+$G(OUT("transactions"))+1
 . . I $G(OUT("guide"))="" S OUT("guide")=$G(TOK(3))
 . I ID="GS",$G(OUT("guide"))="",$G(TOK(8))'="" S OUT("guide")=$G(TOK(8))
 . I ID="CLM" S OUT("claims")=+$G(OUT("claims"))+1
 . I ID="SV1" S OUT("sv1")=+$G(OUT("sv1"))+1,OUT("lines")=+$G(OUT("lines"))+1
 . I ID="SV2" S OUT("sv2")=+$G(OUT("sv2"))+1,OUT("lines")=+$G(OUT("lines"))+1
 . I ID="SV3" S OUT("sv3")=+$G(OUT("sv3"))+1,OUT("lines")=+$G(OUT("lines"))+1
 S OUT("kind")=$$RAWTXK(.OUT)
 S OUT("ok")=1
 Q
 ;
READALL(PATH,ERR) ; read external example file into one scalar for test-only raw scans
 N DEV,OLDIO,TXT,LINE,DONE,$ETRAP,$ESTACK
 S ERR=0,TXT=""
 I '$$EXIST($G(PATH)) S ERR=1 Q ""
 S DEV=PATH,OLDIO=$IO,DONE=0
 S $ETRAP="S ERR=1,DONE=1 C DEV U OLDIO S $ECODE="""""
 O DEV:(READONLY):1 E  S ERR=1 Q ""
 U DEV
 F  Q:DONE  D
 . S LINE=""
 . R LINE:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S DONE=1,ERR=1
 . S TXT=TXT_LINE_$C(10)
 . I $ZEOF S DONE=1
 C DEV
 U OLDIO
 Q TXT
 ;
RAWSEP(TXT) ; element separator from ISA/ST in raw text
 N S,SEP,P
 S S=$$TRSEG($G(TXT))
 I $E(S,1,3)="ISA" Q $E(S,4)
 I S["ISA" D
 . S P=$F(S,"ISA")
 . I P>0 S SEP=$E(S,P)
 I $G(SEP)'="" Q SEP
 I S["ST*" Q "*"
 I S["ST|" Q "|"
 Q "*"
 ;
TOKR(SEG,SEP,TOK) ; light tokenizer for RAWMETA
 N I,N,S
 K TOK
 S SEP=$S($G(SEP)'="":SEP,1:"*")
 S S=$$TRSEG($G(SEG))
 I S="" Q
 S TOK("id")=$P(S,SEP,1)
 S N=$L(S,SEP)
 F I=2:1:N S TOK(I-1)=$P(S,SEP,I)
 Q
 ;
TRSEG(X) ; trim leading/trailing CR/LF/TAB/SP from one raw segment
 N Y
 S Y=$G(X)
 F  Q:Y=""  Q:$A(Y)'=10  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$A(Y)'=13  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$A(Y)'=9  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$E(Y)'=" "  S Y=$E(Y,2,$L(Y))
 F  Q:Y=""  Q:$A(Y,$L(Y))'=10  S Y=$E(Y,1,$L(Y)-1)
 F  Q:Y=""  Q:$A(Y,$L(Y))'=13  S Y=$E(Y,1,$L(Y)-1)
 F  Q:Y=""  Q:$A(Y,$L(Y))'=9  S Y=$E(Y,1,$L(Y)-1)
 F  Q:Y=""  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1)
 Q Y
 ;
RAWTXK(OUT) ; infer 837 flavor from guide or observed service segments
 N G
 S G=$$UC^EFU837U($G(OUT("guide")))
 I G["X224" Q "837D"
 I G["X223" Q "837I"
 I G["X222" Q "837P"
 I G["X299" Q "837I"
 I G["X298" Q "837P"
 I +$G(OUT("sv3"))>0 Q "837D"
 I +$G(OUT("sv2"))>0 Q "837I"
 I +$G(OUT("sv1"))>0 Q "837P"
 Q "837"
 ;
GUIDEOK(ACT,EXP) ; expected guide is exact or prefix of actual guide
 N A,E
 S A=$$UC^EFU837U($G(ACT)),E=$$UC^EFU837U($G(EXP))
 I E="" Q 1
 I A=E Q 1
 I $E(A,1,$L(E))=E Q 1
 Q 0
 ;
SP2US(X) ; replace spaces with underscores
 N I,Y,C
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I),Y=Y_$S(C=" ":"_",1:C)
 Q Y
 ;
NOSPC(X) ; remove spaces
 N I,Y,C
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I) I C'=" " S Y=Y_C
 Q Y
 ;
EQ(FAIL,LAB,GOT,EXP) ; quiet-on-success equality helper
 I $G(GOT)'=$G(EXP) D
 . S FAIL=1
 . W !,"FAIL: ",LAB,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
HASDIAG(ROOT,SEV,CODE) ; whether diagnostic code exists for severity
 N I,OK
 S OK=0,I=0
 F  S I=$O(@ROOT@("diag",SEV,I)) Q:'I  I $G(@ROOT@("diag",SEV,I,"code"))=$G(CODE) S OK=1 Q
 Q OK
 ;
COUNTDATA(TAG) ; count data rows under a known table label
 I $G(TAG)="EX1DATA" Q $$COUNTEX1()
 I $G(TAG)="EX2DATA" Q $$COUNTEX2()
 Q 0
 ;
COUNTEX1() ; count EX1DATA rows
 N I,C,REC
 S C=0
 F I=1:1 S REC=$P($T(EX1DATA+I),";;",2,99) Q:REC=""  S C=C+1
 Q C
 ;
COUNTEX2() ; count EX2DATA rows
 N I,C,REC
 S C=0
 F I=1:1 S REC=$P($T(EX2DATA+I),";;",2,99) Q:REC=""  S C=C+1
 Q C
 ;
COUNTPAT(DIR,PAT) ; count files matching one pattern
 N FILE,C
 S C=0,FILE=$ZSEARCH(DIR_"/"_PAT)
 F  Q:FILE=""  S C=C+1,FILE=$ZSEARCH("")
 Q C
 ;
EX1DIRCNT(BASE) ; actual Example 1 837 source file count
 N ROOT
 S ROOT=$$EX1ROOT(BASE)
 I ROOT="" Q 0
 Q $$COUNTPAT(ROOT_"/edi_files/837","*.dat")
 ;
EX2DIRCNT(BASE) ; actual Example 2 source file count across all three subfolders
 N ROOT,C
 S ROOT=$$EX2ROOT(BASE)
 I ROOT="" Q 0
 S C=0
 S C=C+$$COUNTPAT($$EX2SUB(ROOT,"005010X222 Health Care Claim Professional"),"*.edi")
 S C=C+$$COUNTPAT($$EX2SUB(ROOT,"005010X223 Health Care Claim Institutional"),"*.edi")
 S C=C+$$COUNTPAT($$EX2SUB(ROOT,"005010X224 Health Care Claim Dental"),"*.edi")
 Q C
 ;
COUNTEX1FS(BASE) ; count Example 1 sources by exact metadata presence
 N I,C
 S C=0
 F I=1:1:$$COUNTDATA("EX1DATA") I $$EX1SRC(BASE,I)'="" S C=C+1
 Q C
 ;
EX1SRC(BASE,I) ; exact Example 1 source path from metadata row
 N REC,FILE
 S REC=$P($T(EX1DATA+I),";;",2,99)
 I REC="" Q ""
 S FILE=$P(REC,"|",1)
 Q $$EX1SRCF(BASE,FILE)
 ;
EX1SRCF(BASE,FILE) ; resolve one Example 1 837 source file
 N ROOT,PATH
 S ROOT=$$EX1ROOT(BASE)
 I ROOT="" Q ""
 S PATH=ROOT_"/edi_files/837/"_$G(FILE)
 I '$$EXIST(PATH) Q ""
 Q PATH
 ;
EX1CSVBASE(BASE,FILE) ; resolve Example 1 converted 837 basename without extension
 N ROOT,BN
 S ROOT=$$EX1ROOT(BASE)
 I ROOT="" Q ""
 S BN=ROOT_"/converted_files/837/"_$$NOEXT^EFU837U($G(FILE))
 I $$EXIST(BN_".csv") Q BN
 I $$EXIST(BN_"-Claims.csv") Q BN
 I $$EXIST(BN_"-Lines.csv") Q BN
 I $$EXIST(BN_".json") Q BN
 I $$EXIST(BN_".xlsx") Q BN
 I $$EXIST(BN_".jsonl") Q BN
 Q ""
 ;
COUNTEX2FS(BASE) ; count Example 2 sources by exact metadata presence
 N I,C
 S C=0
 F I=1:1:$$COUNTDATA("EX2DATA") I $$EX2SRC(BASE,I)'="" S C=C+1
 Q C
 ;
EX2SRC(BASE,I) ; exact Example 2 source path from metadata row
 N REC,SUB,FILE
 S REC=$P($T(EX2DATA+I),";;",2,99)
 I REC="" Q ""
 S SUB=$P(REC,"|",1),FILE=$P(REC,"|",2)
 Q $$EX2SRCF(BASE,SUB,FILE)
 ;
EX2SRCF(BASE,SUB,FILE) ; resolve one Example 2 source file across folder naming variants
 N ROOT,DIR,PATH
 S ROOT=$$EX2ROOT(BASE)
 I ROOT="" Q ""
 S DIR=$$EX2SUB(ROOT,$G(SUB))
 I DIR="" Q ""
 S PATH=DIR_"/"_$G(FILE)
 I '$$EXIST(PATH) Q ""
 Q PATH
 ;
EX2SUB(ROOT,SUB) ; Example 2 subfolder resolver
 N C1,C2,C3
 S C1=ROOT_"/"_$G(SUB)
 I $$EXIST(C1_"/"_$$EX2MARK($G(SUB))) Q C1
 S C2=ROOT_"/"_$$SP2US($G(SUB))
 I $$EXIST(C2_"/"_$$EX2MARK($G(SUB))) Q C2
 S C3=ROOT_"/"_$$NOSPC($G(SUB))
 I $$EXIST(C3_"/"_$$EX2MARK($G(SUB))) Q C3
 Q ""
 ;
EX2MARK(SUB) ; marker file for known Example 2 subfolder
 I $G(SUB)["X222" Q "X222-ambulance.edi"
 I $G(SUB)["X223" Q "X223-837-institutional-claim.edi"
 I $G(SUB)["X224" Q "X224-sales-tax.edi"
 Q ""
 ;
EX1ROOT(BASE) ; resolve Example 1 root under a candidate base
 N R
 S R=$G(BASE)_"/Examples_1"
 I $$EXIST(R_"/edi_files/837/837P-all-fields.dat") Q R
 S R=$G(BASE)_"/Examples 1"
 I $$EXIST(R_"/edi_files/837/837P-all-fields.dat") Q R
 S R=$G(BASE)_"/Examples1"
 I $$EXIST(R_"/edi_files/837/837P-all-fields.dat") Q R
 Q ""
 ;
EX2ROOT(BASE) ; resolve Example 2 root under a candidate base
 N R
 S R=$G(BASE)_"/Examples_2"
 I $$EXIST(R_"/"_$$SP2US("005010X222 Health Care Claim Professional")_"/X222-ambulance.edi") Q R
 I $$EXIST(R_"/005010X222 Health Care Claim Professional/X222-ambulance.edi") Q R
 S R=$G(BASE)_"/Examples 2"
 I $$EXIST(R_"/"_$$SP2US("005010X222 Health Care Claim Professional")_"/X222-ambulance.edi") Q R
 I $$EXIST(R_"/005010X222 Health Care Claim Professional/X222-ambulance.edi") Q R
 S R=$G(BASE)_"/Examples2"
 I $$EXIST(R_"/"_$$SP2US("005010X222 Health Care Claim Professional")_"/X222-ambulance.edi") Q R
 I $$EXIST(R_"/005010X222 Health Care Claim Professional/X222-ambulance.edi") Q R
 Q ""
 ;
AUTBASE() ; best-effort auto-detect extracted examples base
 I $$HASBASE("edi") Q "edi"
 I $$HASBASE("./edi") Q "./edi"
 I $$HASBASE("edi/files") Q "edi/files"
 I $$HASBASE("./edi/files") Q "./edi/files"
 I $$HASBASE("files") Q "files"
 I $$HASBASE("./files") Q "./files"
 I $$HASBASE("files_extract/files") Q "files_extract/files"
 I $$HASBASE("/mnt/data/files_extract/files") Q "/mnt/data/files_extract/files"
 I $$HASBASE(".") Q "."
 Q ""
 ;
RESBASE(BASE) ; resolve supplied or nearby example base
 I $G(BASE)="" Q ""
 I $$HASBASE(BASE) Q BASE
 I $$HASBASE("./"_BASE) Q "./"_BASE
 I $$HASBASE(BASE_"/files") Q BASE_"/files"
 I $$HASBASE("./"_BASE_"/files") Q "./"_BASE_"/files"
 I $$HASBASE(BASE_"/edi") Q BASE_"/edi"
 I $$HASBASE(BASE_"/edi/files") Q BASE_"/edi/files"
 I $$HASBASE(BASE_"/files_extract/files") Q BASE_"/files_extract/files"
 I $$HASBASE(".") Q "."
 I $$HASBASE("edi") Q "edi"
 I $$HASBASE("./edi") Q "./edi"
 I $$HASBASE("edi/files") Q "edi/files"
 I $$HASBASE("./edi/files") Q "./edi/files"
 I $$HASBASE("files") Q "files"
 I $$HASBASE("./files") Q "./files"
 I $$HASBASE("files_extract/files") Q "files_extract/files"
 I $$HASBASE("/mnt/data/files_extract/files") Q "/mnt/data/files_extract/files"
 Q ""
 ;
HASBASE(BASE) ; whether base contains a usable Example 1 + Example 2 tree
 Q ($$EX1ROOT($G(BASE))'="")&($$EX2ROOT($G(BASE))'="")
 ;
FAILBASE(FAIL,BASE) ; clear failure for unresolved example base
 S FAIL=1
 W !,"FAIL: [EXAMPLES][base]: could not locate full example tree under ",$G(BASE)
 Q
 ;
EXIST(PATH) ; exact file existence check without wildcard search side effects
 N DEV,OLDIO,OK,$ETRAP,$ESTACK
 I $G(PATH)="" Q 0
 S DEV=PATH,OLDIO=$IO,OK=0
 S $ETRAP="S OK=0 U OLDIO S $ECODE="""""
 O DEV:(READONLY):0 E  U OLDIO Q 0
 S OK=1
 C DEV
 U OLDIO
 Q OK
 ;
CSVROWS(PATH) ; count CSV data rows, excluding header and blank lines
 N DEV,LINE,CNT,HDR,DONE,OLDIO,$ETRAP,$ESTACK
 I '$$EXIST(PATH) Q -1
 S DEV=PATH,CNT=0,HDR=0,DONE=0,OLDIO=$IO
 O DEV:(READONLY:STREAM):1 E  Q -1
 U DEV
 S $ETRAP="S DONE=1,$ECODE="""""
 F  Q:DONE  D
 . S LINE=""
 . R LINE:1
 . I '$T,$ZEOF S DONE=1 Q
 . I $ZEOF,LINE="" S DONE=1 Q
 . I $E(LINE,$L(LINE))=$C(13) S LINE=$E(LINE,1,$L(LINE)-1)
 . I $$TRIM^EFU837U(LINE)="" Q
 . I 'HDR S HDR=1 Q
 . S CNT=CNT+1
 C DEV
 U OLDIO
 Q CNT
 ;
WRFILE(DATA) ; write temp file and return path
 N PATH,DEV,OLDIO
 S PATH="/tmp/efu837t-"_$J_"-"_$R(999999)_".edi"
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM):1
 I '$T Q ""
 U DEV W DATA
 C DEV
 U OLDIO
 Q PATH
 ;
RMFILE(PATH) ; no-op cleanup helper
 Q
 ;
REPL(X,OLD,NEW) ; replace first occurrence only
 N P
 S P=$F(X,OLD)
 I 'P Q X
 Q $E(X,1,P-$L(OLD)-1)_NEW_$E(X,P,$L(X))
 ;
CRLF(X) ; expand segment terminators to CRLF style
 N I,Y,C
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I) D
 . S Y=Y_C
 . I C="~" S Y=Y_$C(13,10)
 Q Y
 ;
SAMPLEK(DATA) ; helper: parse one sample and return tx kind
 N PATH,ROOT,RES,OPT,K
 S PATH=$$WRFILE(DATA)
 S ROOT=$NA(^TMP($J,"EFU837T","K"))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 S K=$G(@ROOT@("norm","claim",1,"tx_kind"))
 D RMFILE(PATH) K @ROOT
 Q K
 ;
SAMPLEI() ; canonical institutional sample from uploaded source
 N S
 S S="ISA*00*          *00*          *ZZ*123456789012345*ZZ*123456789012346*080503*1705*>*00501*000010216*0*T*:~"
 S S=S_"GS*HC*1234567890*9876543210*20080503*1705*20213*X*005010X223A2~"
 S S=S_"ST*837*987654*005010X223A2~"
 S S=S_"BHT*0019*00*0123*19960918*0932*CH~"
 S S=S_"NM1*41*2*JONES HOSPITAL*****46*12345~"
 S S=S_"PER*IC*JANE DOE*TE*9005555555~"
 S S=S_"NM1*40*2*MEDICARE*****46*00120~"
 S S=S_"HL*1**20*1~"
 S S=S_"PRV*BI*PXC*203BA0200N~"
 S S=S_"NM1*85*2*JONES HOSPITAL*****XX*9876540809~"
 S S=S_"N3*225 MAIN STREET BARKLEY BUILDING~"
 S S=S_"N4*CENTERVILLE*PA*17111~"
 S S=S_"REF*EI*567891234~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******MB~"
 S S=S_"NM1*IL*1*DOE*JOHN*T***MI*030005074A~"
 S S=S_"N3*125 CITY AVENUE~"
 S S=S_"N4*CENTERVILLE*PA*17111~"
 S S=S_"DMG*D8*19261111*M~"
 S S=S_"NM1*PR*2*MEDICARE B*****PI*00435~"
 S S=S_"REF*G2*330127~"
 S S=S_"CLM*756048Q*89.93***14:A:1**A*Y*Y~"
 S S=S_"DTP*434*RD8*19960911-19960911~"
 S S=S_"CL1*3**01~"
 S S=S_"HI*BK:3669~"
 S S=S_"HI*BF:4019*BF:79431~"
 S S=S_"HI*BH:A1:D8:19261111*BH:A2:D8:19911101*BH:B1:D8:19261111*BH:B2:D8:19870101~"
 S S=S_"HI*BE:A2:::15.31~"
 S S=S_"HI*BG:09~"
 S S=S_"NM1*71*1*JONES*JOHN*J~"
 S S=S_"REF*1G*B99937~"
 S S=S_"SBR*S*01*351630*STATE TEACHERS*****CI~"
 S S=S_"OI***Y***Y~"
 S S=S_"NM1*IL*1*DOE*JANE*S***MI*222004433~"
 S S=S_"N3*125 CITY AVENUE~"
 S S=S_"N4*CENTERVILLE*PA*17111~"
 S S=S_"NM1*PR*2*STATE TEACHERS*****PI*1135~"
 S S=S_"LX*1~"
 S S=S_"SV2*0305*HC:85025*13.39*UN*1~"
 S S=S_"DTP*472*D8*19960911~"
 S S=S_"LX*2~"
 S S=S_"SV2*0730*HC:93005*76.54*UN*3~"
 S S=S_"DTP*472*D8*19960911~"
 S S=S_"SE*42*987654~"
 S S=S_"GE*1*20213~"
 S S=S_"IEA*1*000010216~"
 Q S
 ;
SAMPLEP() ; minimal professional transaction-only sample
 N S
 S S="ST*837*1*005010X222A1~"
 S S=S_"BHT*0019*00*P1*20260115*1015*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*85*2*ACME CLINIC*****XX*1234567893~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*DOE*JANE*A***MI*MEMP1~"
 S S=S_"NM1*PR*2*PAYER A*****PI*PA001~"
 S S=S_"CLM*PCLM1*125***11:B:1**A*Y*Y~"
 S S=S_"DTP*434*D8*20260115~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:99213*125*UN*1~"
 S S=S_"DTP*472*D8*20260115~"
 S S=S_"SE*14*1~"
 Q S
 ;
SAMPLEP2() ; second professional transaction for multi-transaction tests
 N S
 S S="ST*837*2*005010X222A1~"
 S S=S_"BHT*0019*00*P2*20260116*1115*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*85*2*ACME CLINIC*****XX*1234567893~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*DOE*JOHN***MI*MEMP2~"
 S S=S_"NM1*PR*2*PAYER B*****PI*PB001~"
 S S=S_"CLM*PCLM2*80***11:B:1**A*Y*Y~"
 S S=S_"DTP*434*D8*20260116~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:99214*80*UN*1~"
 S S=S_"DTP*472*D8*20260116~"
 S S=S_"SE*14*2~"
 Q S
 ;
SAMPLED() ; minimal dental transaction-only sample
 N S
 S S="ST*837*1*005010X224A2~"
 S S=S_"BHT*0019*00*D1*20260120*0900*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*85*2*DENTAL CLINIC*****XX*1234567890~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*SMITH*JANE***MI*MEMD1~"
 S S=S_"NM1*PR*2*DENTAL PAYER*****PI*DP001~"
 S S=S_"CLM*DCLM1*50***11:B:1**A*Y*Y~"
 S S=S_"DTP*434*D8*20260120~"
 S S=S_"LX*1~"
 S S=S_"SV3*AD:D0120*50*UN*1~"
 S S=S_"DTP*472*D8*20260120~"
 S S=S_"SE*14*1~"
 Q S
 ;
SAMPLEPIPE() ; tx-only sample with pipe element separator
 N S
 S S="ST|837|1|005010X222A1~"
 S S=S_"BHT|0019|00|PIPE|20260115|1015|CH~"
 S S=S_"HL|1||20|1~"
 S S=S_"NM1|85|2|PIPE CLINIC|||||XX|1234567893~"
 S S=S_"HL|2|1|22|0~"
 S S=S_"SBR|P|18|||||||CI~"
 S S=S_"NM1|IL|1|DOE|PIPE||||MI|PIPEMEM~"
 S S=S_"NM1|PR|2|PIPE PAYER|||||PI|PP001~"
 S S=S_"CLM|PIPE1|10|||11:B:1||A|Y|Y~"
 S S=S_"DTP|434|D8|20260115~"
 S S=S_"LX|1~"
 S S=S_"SV1|HC:11111|10|UN|1~"
 S S=S_"DTP|472|D8|20260115~"
 S S=S_"SE|14|1~"
 Q S
 ;
EX1DATA ; file|kind|guide|claims|lines|combined_rows|claims_csv_rows|lines_csv_rows
 ;;837D-all-fields.dat|837D|005010X224|1|2|0|0|0
 ;;837I-X299-all-fields.dat|837I|005010X299|1|1|0|0|0
 ;;837I-all-fields.dat|837I|005010X223A2|1|2|2|1|2
 ;;837I-inst-claim.dat|837I|005010X223|1|2|2|0|0
 ;;837P-X298-all-fields.dat|837P|005010X298|1|1|0|0|0
 ;;837P-all-fields.dat|837P|005010X222A2|1|4|4|1|4
 ;;ambulance.dat|837P|005010X222|1|4|4|0|0
 ;;anesthesia.dat|837P|005010X222|1|2|2|0|0
 ;;chiro.dat|837P|005010X222|1|1|1|0|0
 ;;cob-payera-payerb.dat|837P|005010X222|1|3|3|0|0
 ;;cob-prov-payera.dat|837P|005010X222|1|3|3|0|0
 ;;commercial-replacement.dat|837P|005010X222|1|4|4|0|0
 ;;commercial.dat|837P|005010X222|1|3|3|0|0
 ;;home-infusion-ndc.dat|837P|005010X222|1|6|6|0|0
 ;;multi-tran.dat|837P|005010X222|3|7|7|0|0
 ;;ppo-repriced.dat|837P|005010X222|1|2|2|0|0
 ;;prof-encounter.dat|837P|005010X222|1|4|4|0|0
 ;;wheelchair.dat|837P|005010X222|1|1|1|0|0
 ;;
EX2DATA ; subfolder|file|kind|guide|claims|lines
 ;;005010X222 Health Care Claim Professional|X222-COB-claim-from-billing-provider-to-payer-a.edi|837P|005010X222A1|1|3
 ;;005010X222 Health Care Claim Professional|X222-COB-claim-from-billing-provider-to-payer-b.edi|837P|005010X222A1|1|3
 ;;005010X222 Health Care Claim Professional|X222-COB-claim-from-payer-a-to-payer-b-in-payer-to-payer.edi|837P|005010X222A1|1|3
 ;;005010X222 Health Care Claim Professional|X222-ambulance.edi|837P|005010X222A1|1|4
 ;;005010X222 Health Care Claim Professional|X222-anesthesia.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-chiropractic.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-commercial-health-insurance.edi|837P|005010X222A1|1|4
 ;;005010X222 Health Care Claim Professional|X222-drug-administered-in-the-physician-office.edi|837P|005010X222A1|1|2
 ;;005010X222 Health Care Claim Professional|X222-encounter.edi|837P|005010X222A1|1|4
 ;;005010X222 Health Care Claim Professional|X222-home-infusion-therapy-pharmacy-(adjudicated-with-HCPCS-in-loop-2400-or-NDC-in-loop-2410).edi|837P|005010X222A1|1|6
 ;;005010X222 Health Care Claim Professional|X222-home-infusion-therapy-pharmacy-(adjudicated-with-NDC-in-loop-2410).edi|837P|005010X222A1|1|6
 ;;005010X222 Health Care Claim Professional|X222-medicare-secondary-payer-COB.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-out-of-network-repriced-claim.edi|837P|005010X222A1|1|1
 ;;005010X222 Health Care Claim Professional|X222-oxygen.edi|837P|005010X222A1|1|2
 ;;005010X222 Health Care Claim Professional|X222-ppo-repriced-claim.edi|837P|005010X222A1|1|2
 ;;005010X222 Health Care Claim Professional|X222-wheelchair.edi|837P|005010X222A1|1|1
 ;;005010X223 Health Care Claim Institutional|X223-837-institutional-claim.edi|837I|005010X223A2|1|2
 ;;005010X223 Health Care Claim Institutional|X223-automobile-accident.edi|837I|005010X223A2|1|4
 ;;005010X223 Health Care Claim Institutional|X223-out-of-network-repriced-claim.edi|837I|005010X223A2|1|1
 ;;005010X223 Health Care Claim Institutional|X223-ppo-repriced-claim.edi|837I|005010X223A2|1|2
 ;;005010X223 Health Care Claim Institutional|X223-two-claims-for-the-same-provider.edi|837I|005010X223A2|2|3
 ;;005010X224 Health Care Claim Dental|X224-claim-from-billing-provider-to-payer-a.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-claim-from-billing-provider-to-payer-b.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-claim-multi-quantity-single-line.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-commercial-health-insurance.edi|837D|005010X224A2|1|2
 ;;005010X224 Health Care Claim Dental|X224-multiple-tooth-numbers.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-orthodontic-treatment-plan.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-predetermination-of-benefits.edi|837D|005010X224A2|1|1
 ;;005010X224 Health Care Claim Dental|X224-sales-tax.edi|837D|005010X224A2|1|3
 ;;
