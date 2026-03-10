EFUZYUI ; efuzy page context builders
	;
	Q
	;
BUILDWS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"workspace")
	S TCTX("page","title")="Workspace"
	S TCTX("page","heading")="Workspace"
	S TCTX("page","lead")="Stage files, run workflows, review jobs, and manage export profiles."
	D COUNTS(.CONF,.TCTX)
	D LOADRECENT^EFUWFHIST(.CONF,10,.TCTX)
	D LOADFILES^EFUZYFS(.CONF,8,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
	Q
	;
BUILDPREV(CONF,REQ,CTX,JOBID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"workspace")
	S TCTX("page","title")="Preview"
	S TCTX("page","heading")="Preview"
	S TCTX("page","lead")="Review parsed metadata, counts, warnings, and sample rows before export."
	S TCTX("job","id")=$G(JOBID)
	D LOADJOB^EFUWFHIST(.CONF,JOBID,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	D LOADPREVIEW^EFU837(.CONF,JOBID,.TCTX)
	Q
	;
BUILDPROFS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"profiles")
	S TCTX("page","title")="Profiles"
	S TCTX("page","heading")="Export Profiles"
	S TCTX("page","lead")="Save field sets, column order, delimiter settings, and output naming rules."
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	D LOADMAPS^EFU837EXPMP(.TCTX)
	Q
	;
BUILDPROF(CONF,REQ,CTX,ID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"profiles")
	S TCTX("page","title")="Profile"
	S TCTX("page","heading")="Profile Editor"
	S TCTX("page","lead")="Configure export mode, selected fields, headers, quoting, and file naming."
	D LOADPROF^EFUZYCFG(.CONF,ID,.TCTX)
	D LOADMAPS^EFU837EXPMP(.TCTX)
	Q
	;
BUILDAUTO(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"automation")
	S TCTX("page","title")="Automation"
	S TCTX("page","heading")="Automation"
	S TCTX("page","lead")="Bind folders, choose a profile, and define success/failure file movement rules."
	D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	Q
	;
BUILDJOB(CONF,REQ,CTX,ID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"workspace")
	S TCTX("page","title")="Job Detail"
	S TCTX("page","heading")="Job Detail"
	S TCTX("page","lead")="Inspect the stored job record, diagnostics, statistics, and output path."
	S TCTX("job","id")=$G(ID)
	D LOADJOB^EFUWFHIST(.CONF,ID,.TCTX)
	D LOADPREVIEW^EFU837(.CONF,ID,.TCTX)
	Q
	;
BASE(TCTX)
	K TCTX
	S TCTX("app","name")="efuzy"
	S TCTX("app","tagline")="Self-hosted file-processing workflow workspace"
	S TCTX("theme","mode")="dark"
	S TCTX("nav",1,"key")="workspace"
	S TCTX("nav",1,"label")="Workspace"
	S TCTX("nav",1,"href")="/efuzy/workspace"
	S TCTX("nav",2,"key")="profiles"
	S TCTX("nav",2,"label")="Profiles"
	S TCTX("nav",2,"href")="/efuzy/profiles"
	S TCTX("nav",3,"key")="automation"
	S TCTX("nav",3,"label")="Automation"
	S TCTX("nav",3,"href")="/efuzy/automation"
	S TCTX("badges","mvp")="837 → CSV"
	Q
	;
ACT(TCTX,KEY)
	N I
	S I=0
	F  S I=$O(TCTX("nav",I)) Q:'I  S TCTX("nav",I,"isActive")=$S($G(TCTX("nav",I,"key"))=$G(KEY):1,1:0)
	Q
	;
COUNTS(CONF,TCTX)
	S TCTX("summary",1,"label")="Queued Jobs"
	S TCTX("summary",1,"value")=$$COUNTIDX("queued")
	S TCTX("summary",2,"label")="Running Jobs"
	S TCTX("summary",2,"value")=$$COUNTIDX("running")
	S TCTX("summary",3,"label")="Completed Jobs"
	S TCTX("summary",3,"value")=$$COUNTIDX("completed")
	S TCTX("summary",4,"label")="Staged Files"
	S TCTX("summary",4,"value")=$$FILECOUNT()
	Q
	;
COUNTIDX(STATUS)
	N C,ID
	S C=0,ID=0
	F  S ID=$O(^MIO("EFUZY","idx","job","status",STATUS,ID)) Q:'ID  S C=C+1
	Q C
	;
FILECOUNT()
	N C,ID
	S C=0,ID=0
	F  S ID=$O(^MIO("EFUZY","file",ID)) Q:'ID  S C=C+1
	Q C
	;
	;