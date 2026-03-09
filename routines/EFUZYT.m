EFUZYT ; efuzy smoke tests
 ;
 Q
 ;
START
 W !,"efuzy smoke checks",!
 D TESTMAPS
 D TESTDEFAULT
 W !,"done",!
 Q
 ;
TESTMAPS
 W "claim summary fields: ",$$DFLIST^EFU837MAP("claim_summary"),!
 W "service line fields: ",$$DFLIST^EFU837MAP("service_line"),!
 Q
 ;
TESTDEFAULT
 D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
 W "profiles loaded: ",$O(TCTX("profiles",""),-1),!
 Q
 ;
