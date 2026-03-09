EFUZYWAT ; efuzy watched-folder automation runner
 ;
 ; Phase 2 baseline:
 ; - polling-based
 ; - profile-bound
 ; - self-hosted
 ; - intentionally simple
 ;
 Q
 ;
RUNONCE(CONF,AUTOID,ERR)
 ; Stub entry point for later polling watcher integration.
 ; Suggested flow:
 ;   1) read automation config
 ;   2) scan input folder
 ;   3) stage candidate files into EFUZY file records
 ;   4) create queued jobs bound to selected profile
 ;   5) run EFUWFRUN
 ;   6) archive or move failures
 K ERR
 I +$G(AUTOID)<1 S ERR("error")="automation_id_required" Q 0
 S ERR("error")="not_implemented_yet"
 Q 0
 ;
