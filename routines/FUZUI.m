FUZUI ; public efuzy site view models and helpers
	;
	Q
	;
CONFDEF(CONF)
	I $G(CONF("fuz","siteUrl"))="" S CONF("fuz","siteUrl")="https://efuzy.com"
	I $G(CONF("fuz","brand"))="" S CONF("fuz","brand")="efuzy"
	I $G(CONF("fuz","tagline"))="" S CONF("fuz","tagline")="Self-hosted file-processing workflow workspace"
	I $G(CONF("fuz","shell"))="" S CONF("fuz","shell")="efuzy / MUMPS.IO"
	I $G(CONF("fuz","demoHref"))="" S CONF("fuz","demoHref")="/efuzy/demo"
	I +$G(CONF("fuz","demoArtifactTtlHours"))<1 S CONF("fuz","demoArtifactTtlHours")=24
	I $G(CONF("fuz","demoArtifactTtlLabel"))="" S CONF("fuz","demoArtifactTtlLabel")=$$TTLLAB(+CONF("fuz","demoArtifactTtlHours"))
	I $G(CONF("fuz","contactEmail"))="" S CONF("fuz","contactEmail")="hello@efuzy.com"
	I +$G(CONF("fuz","contactMaxMessageChars"))<1 S CONF("fuz","contactMaxMessageChars")=2000
	I $G(CONF("server","templateDir"))="" S CONF("server","templateDir")="templates"
	Q
	;
BASE(CONF,TCTX)
	D CONFDEF(.CONF)
	K TCTX
	S TCTX("app","name")=$G(CONF("fuz","brand"))
	S TCTX("app","tagline")=$G(CONF("fuz","tagline"))
	S TCTX("app","version")="Public site"
	S TCTX("theme","mode")="dark"
	S TCTX("theme","toggleLabel")="Toggle theme"
	S TCTX("shell","eyebrow")=$G(CONF("fuz","shell"))
	S TCTX("site","url")=$G(CONF("fuz","siteUrl"))
	S TCTX("site","year")=$$YEAR^MIOUTIL()
	S TCTX("site","contactEmail")=$G(CONF("fuz","contactEmail"))
	S TCTX("site","demoHref")=$G(CONF("fuz","demoHref"))
	S TCTX("site","demoArtifactTtlLabel")=$G(CONF("fuz","demoArtifactTtlLabel"))
	S TCTX("badges",1,"label")="Self-hosted"
	S TCTX("badges",1,"tone")="badge-sky"
	S TCTX("badges",2,"label")="Traceable"
	S TCTX("badges",2,"tone")="badge-violet"
	S TCTX("badges",3,"label")="SSR-first"
	S TCTX("badges",3,"tone")="badge-emerald"
	S TCTX("badges",4,"label")="Source-ready"
	S TCTX("badges",4,"tone")="badge-amber"
	D NAV(.TCTX)
	D FOOT(.TCTX)
	Q
	;
NAV(TCTX)
	S TCTX("nav",1,"key")="home"
	S TCTX("nav",1,"label")="Overview"
	S TCTX("nav",1,"href")="/"
	S TCTX("nav",2,"key")="features"
	S TCTX("nav",2,"label")="Workflow"
	S TCTX("nav",2,"href")="/features"
	S TCTX("nav",3,"key")="guide"
	S TCTX("nav",3,"label")="Guide"
	S TCTX("nav",3,"href")="/guide"
	S TCTX("nav",4,"key")="demo"
	S TCTX("nav",4,"label")="Demo"
	S TCTX("nav",4,"href")="/demo"
	S TCTX("nav",5,"key")="contact"
	S TCTX("nav",5,"label")="Contact"
	S TCTX("nav",5,"href")="/contact"
	Q
	;
FOOT(TCTX)
	S TCTX("footer","links",1,"label")="Overview"
	S TCTX("footer","links",1,"href")="/"
	S TCTX("footer","links",2,"label")="Workflow"
	S TCTX("footer","links",2,"href")="/features"
	S TCTX("footer","links",3,"label")="User guide"
	S TCTX("footer","links",3,"href")="/guide"
	S TCTX("footer","links",4,"label")="User manual"
	S TCTX("footer","links",4,"href")="/manual"
	S TCTX("footer","links",5,"label")="Services"
	S TCTX("footer","links",5,"href")="/services"
	S TCTX("footer","links",6,"label")="Demo"
	S TCTX("footer","links",6,"href")="/demo"
	S TCTX("footer","links",7,"label")="Contact"
	S TCTX("footer","links",7,"href")="/contact"
	S TCTX("footer","links",8,"label")="Privacy"
	S TCTX("footer","links",8,"href")="/privacy"
	S TCTX("footer","links",9,"label")="Terms"
	S TCTX("footer","links",9,"href")="/terms"
	Q
	;
ACT(TCTX,KEY)
	N I
	S I=0
	F  S I=$O(TCTX("nav",I)) Q:'I  S TCTX("nav",I,"isActive")=$S($G(TCTX("nav",I,"key"))=$G(KEY):1,1:0)
	Q
	;
SETPAGE(CONF,TCTX,KEY,TITLE,DESC,PATH,HEADING,LEAD)
	N CAN
	D ACT(.TCTX,$G(KEY))
	S CAN=$$ABSURL(.CONF,$G(PATH))
	S TCTX("page","title")=$G(TITLE)
	S TCTX("page","description")=$G(DESC)
	S TCTX("page","canonical")=CAN
	S TCTX("page","heading")=$G(HEADING)
	S TCTX("page","lead")=$G(LEAD)
	S TCTX("page","ogTitle")=$G(TITLE)
	S TCTX("page","ogDescription")=$G(DESC)
	S TCTX("page","ogUrl")=CAN
	S TCTX("page","ogType")="website"
	Q
	;
BUILDHOME(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"home","EFUZY | Self-hosted file-processing workflow workspace","Self-hosted file-processing workflow workspace for configurable X12 exports, traceable jobs, installation guidance, and private operational review.","/","Self-hosted file-processing workflow workspace","Private workflows. Clear outputs. Traceable results.")
	S TCTX("hero","eyebrow")="Operational software"
	S TCTX("hero","copy",1)="Keep file processing private."
	S TCTX("hero","copy",2)="Review claims before export."
	S TCTX("hero","copy",3)="Keep trace, diagnostics, and artifacts in one place."
	S TCTX("hero","primaryLabel")="Contact us"
	S TCTX("hero","primaryHref")="/contact"
	S TCTX("hero","secondaryLabel")="Preview the app"
	S TCTX("hero","secondaryHref")="/demo"
	S TCTX("hero","panel","title")="Current workflow"
	S TCTX("hero","panel","kicker")="Live product scope"
	S TCTX("hero","panel","line1")="X12 837 to configurable CSV"
	S TCTX("hero","panel","line2")="Preview. Publish. Download."
	S TCTX("hero","panel","line3")="SSR-first. Minimal JavaScript."
	D PILLARS(.TCTX)
	D STEPS(.TCTX)
	D DOCS(.TCTX)
	D TRUST(.TCTX)
	D PREVIEW(.CONF,.TCTX)
	D FAQ(.TCTX)
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/")_$$ORGJSON(.CONF)
	Q
	;
BUILDFEAT(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"features","EFUZY Workflow | Configurable export and traceable jobs","See how EFUZY stages files, previews claims, applies export profiles, and keeps traceable job artifacts.","/features","Workflow details","Short steps. Clear controls. Deterministic outputs.")
	D PILLARS(.TCTX)
	D STEPS(.TCTX)
	D DETAIL(.TCTX)
	D TRUST(.TCTX)
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/features")
	Q
	;
BUILDDEMO(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"demo","EFUZY Demo | Evaluation workflow preview","Preview the EFUZY application and evaluation flow. Demo uploads and generated artifacts expire automatically.","/demo","Preview the application","Use sample data first. Uploaded demo artifacts expire automatically.")
	D PREVIEW(.CONF,.TCTX)
	S TCTX("demo","callout","title")="Evaluation disclaimer"
	S TCTX("demo","callout","body")="Use evaluation data only. Uploaded files and generated artifacts expire within "_$G(CONF("fuz","demoArtifactTtlLabel"))_". Do not upload production PHI."
	S TCTX("demo","openLabel")="Create evaluation login"
	S TCTX("demo","openHref")=$G(CONF("fuz","demoHref"))
	S TCTX("demo","notes",1,"title")="What you can review"
	S TCTX("demo","notes",1,"desc")="Workspace flow. Preview samples. Profile-aware export."
	S TCTX("demo","notes",2,"title")="What you should avoid"
	S TCTX("demo","notes",2,"desc")="Sensitive production data. Long-term storage assumptions."
	S TCTX("demo","notes",3,"title")="What paid delivery adds"
	S TCTX("demo","notes",3,"desc")="Source delivery. Installer. Startup scripts. Admin guidance."
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/demo")
	Q
	;
BUILDGUIDE(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"guide","EFUZY User Guide | Workflow guide for operators","Read the EFUZY user guide for staging files, preview review, profiles, diagnostics, trace, and repeatable daily workflows.","/guide","User guide","Short steps. Clear habits. Better review before publish.")
	S TCTX("doc","eyebrow")="User guide"
	S TCTX("doc","intro")="This guide is for operators, billers, analysts, and admins who use the EFUZY workspace."
	S TCTX("doc","highlights",1,"text")="Stage files with confidence"
	S TCTX("doc","highlights",2,"text")="Review claims, lines, and diagnostics"
	S TCTX("doc","highlights",3,"text")="Publish deterministic artifacts"
	S TCTX("doc","sections",1,"title")="What EFUZY does"
	S TCTX("doc","sections",1,"body")="EFUZY is a browser-based workspace for file processing. In the current MVP, it converts X12 837 files into CSV outputs that can be reviewed, downloaded, and repeated."
	S TCTX("doc","sections",1,"items",1,"text")="Bring files in"
	S TCTX("doc","sections",1,"items",2,"text")="Review what was parsed"
	S TCTX("doc","sections",1,"items",3,"text")="Choose output behavior"
	S TCTX("doc","sections",1,"items",4,"text")="Inspect history later"
	S TCTX("doc","sections",2,"title")="Main pages"
	S TCTX("doc","sections",2,"body")="Use the workspace for uploads, the preview page for review, profiles for export rules, automation for repeat runs, and jobs for artifact history."
	S TCTX("doc","sections",2,"items",1,"text")="Workspace for upload and staging"
	S TCTX("doc","sections",2,"items",2,"text")="Preview for counts, warnings, and sample rows"
	S TCTX("doc","sections",2,"items",3,"text")="Profiles for fields, delimiter, headers, and naming"
	S TCTX("doc","sections",2,"items",4,"text")="Jobs for downloads, trace, and manifests"
	S TCTX("doc","sections",3,"title")="Standard workflow"
	S TCTX("doc","sections",3,"body")="A good daily pattern is simple. Stage a file. Review the preview. Choose export behavior. Publish. Download the artifacts you need."
	S TCTX("doc","sections",3,"items",1,"text")="Check claim and line counts"
	S TCTX("doc","sections",3,"items",2,"text")="Read warnings before publish"
	S TCTX("doc","sections",3,"items",3,"text")="Use a saved profile when the output shape matters"
	S TCTX("doc","sections",3,"items",4,"text")="Open Job Detail after publish"
	S TCTX("doc","sections",4,"title")="Profiles and naming"
	S TCTX("doc","sections",4,"body")="Profiles shape operator-facing CSV output. Use one profile per business use case. Keep names short. Put important identifiers first. Use output names that make sense later."
	S TCTX("doc","sections",4,"items",1,"text")="Claim summary for one row per claim"
	S TCTX("doc","sections",4,"items",2,"text")="Service line detail for one row per billed line"
	S TCTX("doc","sections",4,"items",3,"text")="Use tokens like {{source_base}} and {{timestamp}}"
	S TCTX("doc","sections",5,"title")="Diagnostics and trace"
	S TCTX("doc","sections",5,"body")="Warnings do not always make the result unusable. Errors usually mean the job needs more review. Trace helps explain where exported values came from."
	S TCTX("doc","sections",5,"items",1,"text")="Read the summary first"
	S TCTX("doc","sections",5,"items",2,"text")="Open detailed messages next"
	S TCTX("doc","sections",5,"items",3,"text")="Use trace for review, not for quick downloads"
	S TCTX("doc","sections",6,"title")="Common operating patterns"
	S TCTX("doc","sections",6,"body")="EFUZY supports quick daily processing, validation-heavy review, and repeat customer workflows built around saved profiles."
	S TCTX("doc","sections",6,"items",1,"text")="Fast daily processing"
	S TCTX("doc","sections",6,"items",2,"text")="Validation-heavy review"
	S TCTX("doc","sections",6,"items",3,"text")="Repeat customer workflow"
	D DOCCALL(.TCTX,"Need a guided rollout?","Talk to us about onboarding, installation, or profile setup.","/services","View services","/contact","Contact us")
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/guide")_$$ARTJSON(.CONF,"/guide","EFUZY User Guide","Workflow guide for operators who stage files, review diagnostics, and publish artifacts.")
	Q
	;
BUILDMANUAL(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"","EFUZY User Manual | Product, architecture, and operating model","Read the EFUZY user manual for product scope, application areas, filesystem model, validation, and operational expectations.","/manual","User manual","Product scope. Operating model. Technical confidence.")
	S TCTX("doc","eyebrow")="User manual"
	S TCTX("doc","intro")="This manual summarizes how EFUZY is structured today and why the product is designed for private, traceable, self-hosted operation."
	S TCTX("doc","highlights",1,"text")="SSR-first on MUMPS.IO"
	S TCTX("doc","highlights",2,"text")="Local tmp runtime model"
	S TCTX("doc","highlights",3,"text")="Deterministic artifacts and trace"
	S TCTX("doc","sections",1,"title")="What EFUZY is"
	S TCTX("doc","sections",1,"body")="EFUZY is a production-minded workspace for structured file processing. The current MVP is X12 837 to configurable CSV. The long-term direction includes more X12 families, more file types, and more output shapes."
	S TCTX("doc","sections",2,"title")="Main application areas"
	S TCTX("doc","sections",2,"body")="The current application includes workspace, preview, profiles, automation, jobs, diagnostics, trace, and artifact downloads."
	S TCTX("doc","sections",2,"items",1,"text")="Workspace for staging and recent jobs"
	S TCTX("doc","sections",2,"items",2,"text")="Preview for claim rows, service lines, and export plan"
	S TCTX("doc","sections",2,"items",3,"text")="Profiles and automation for repeatable exports"
	S TCTX("doc","sections",2,"items",4,"text")="Jobs for manifests, rebuilt X12, trace, and reports"
	S TCTX("doc","sections",3,"title")="Technical architecture"
	S TCTX("doc","sections",3,"body")="The web layer builds on MIOHTTP, MIOROUTE, MIOMW, MIOAUTH, MIOAUTHJWT, MIOAUTHZ, MIOTPL, Tailwind CSS, and YottaDB or GT.M compatible M code."
	S TCTX("doc","sections",3,"items",1,"text")="SSR-first pages"
	S TCTX("doc","sections",3,"items",2,"text")="Minimal JavaScript"
	S TCTX("doc","sections",3,"items",3,"text")="Additive routines and tests"
	S TCTX("doc","sections",4,"title")="Filesystem model"
	S TCTX("doc","sections",4,"body")="The project keeps working files under local project directories, not /tmp. Runtime layout stays under tmp/efuzy for uploads, jobs, exports, reports, log, run, cache, and temporary files."
	S TCTX("doc","sections",4,"items",1,"text")="Portable install path"
	S TCTX("doc","sections",4,"items",2,"text")="Controlled runtime directories"
	S TCTX("doc","sections",4,"items",3,"text")="Safer retention and cleanup"
	S TCTX("doc","sections",5,"title")="Validation and trust"
	S TCTX("doc","sections",5,"body")="The product emphasizes diagnostics, deterministic export, round-trip visibility, and additive test coverage. External example suites validate real files and benchmark row counts when that comparison is safe."
	S TCTX("doc","sections",5,"items",1,"text")="Diagnostics and trace explain results"
	S TCTX("doc","sections",5,"items",2,"text")="Health and readiness checks support deployment"
	S TCTX("doc","sections",5,"items",3,"text")="Licensing and delivery flows are test-backed"
	S TCTX("doc","sections",6,"title")="Commercial delivery model"
	S TCTX("doc","sections",6,"body")="Paid delivery is self-hosted. It can include source delivery, installer scripts, startup scripts, admin guidance, release notes, and onboarding help."
	S TCTX("doc","sections",6,"items",1,"text")="Public demo for evaluation only"
	S TCTX("doc","sections",6,"items",2,"text")="Paid self-hosted commercial delivery"
	S TCTX("doc","sections",6,"items",3,"text")="Optional installation, development, and support services"
	D DOCCALL(.TCTX,"Need help with implementation?","We provide installation, development, and support services for a fee.","/services","See services","/contact","Contact us")
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/manual")_$$ARTJSON(.CONF,"/manual","EFUZY User Manual","Product, architecture, and operating model for EFUZY.")
	Q
	;
BUILDSERVICES(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"","EFUZY Services | Installation, development, and support","Talk to EFUZY about self-hosted installation, onboarding, custom development, profile setup, and support services.","/services","Implementation and support services","Installation, development, and support are available for a fee.")
	S TCTX("services","eyebrow")="Services"
	S TCTX("services","intro")="We support EFUZY buyers who want help with rollout, profile design, workflow expansion, and ongoing support."
	S TCTX("services","offers",1,"title")="Installation help"
	S TCTX("services","offers",1,"body")="We can help you stand up the self-hosted product, validate directories, confirm environment setup, and walk through first startup."
	S TCTX("services","offers",2,"title")="Profile and workflow setup"
	S TCTX("services","offers",2,"body")="We can help define export profiles, naming rules, sample validation steps, and demo-to-production rollout habits."
	S TCTX("services","offers",3,"title")="Custom development"
	S TCTX("services","offers",3,"body")="We can scope additive workflow expansion, new file-processing routes, reporting, and operational improvements."
	S TCTX("services","offers",4,"title")="Support"
	S TCTX("services","offers",4,"body")="We can provide onboarding, troubleshooting, upgrade guidance, and support bundles for field issues."
	S TCTX("services","engagement",1,"step")="01"
	S TCTX("services","engagement",1,"title")="Initial review"
	S TCTX("services","engagement",1,"desc")="You tell us about your workflow, environment, and desired output."
	S TCTX("services","engagement",2,"step")="02"
	S TCTX("services","engagement",2,"title")="Practical plan"
	S TCTX("services","engagement",2,"desc")="We outline the next step, whether that is evaluation help, installation help, or scoped development."
	S TCTX("services","engagement",3,"step")="03"
	S TCTX("services","engagement",3,"title")="Delivery"
	S TCTX("services","engagement",3,"desc")="We provide the agreed service directly, with clear boundaries and clean handoff."
	S TCTX("services","assurance",1,"title")="No public pricing page"
	S TCTX("services","assurance",1,"body")="Scope varies by environment and workflow. Contact us so we can keep the conversation practical."
	S TCTX("services","assurance",2,"title")="Built around the real product"
	S TCTX("services","assurance",2,"body")="The same SSR-first application, route stack, licensing, health checks, and docs inform our service work."
	S TCTX("services","assurance",3,"title")="Clean next step"
	S TCTX("services","assurance",3,"body")="We can start with evaluation guidance, installation help, development planning, or support."
	S TCTX("services","ctaTitle")="Tell us what you need"
	S TCTX("services","ctaBody")="Use the contact form to ask about installation, development, or support services."
	S TCTX("services","ctaPrimaryHref")="/contact"
	S TCTX("services","ctaPrimaryLabel")="Contact us"
	S TCTX("services","ctaSecondaryHref")="/guide"
	S TCTX("services","ctaSecondaryLabel")="Read the guide"
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/services")_$$SERVJSON(.CONF,"/services","EFUZY Services","Installation, development, and support services for the EFUZY product.")
	Q
	;
BUILDCONTACT(CONF,REQ,CTX,STATE,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"contact","Contact EFUZY | Self-hosted workflow software","Contact EFUZY about self-hosted deployment, evaluation access, implementation guidance, and commercial licensing.","/contact","Contact us","Tell us about your workflow, your environment, and your timeline.")
	S TCTX("contact","action")="/contact"
	S TCTX("contact","method")="post"
	S TCTX("contact","intro")="We reply with the right next step."
	S TCTX("contact","help",1)="Self-hosted deployment"
	S TCTX("contact","help",2)="Evaluation access"
	S TCTX("contact","help",3)="Installation services"
	S TCTX("contact","help",4)="Custom development"
	S TCTX("contact","help",5)="Support agreements"
	I $G(STATE("success"))=1 D
	. S TCTX("contact","success")=1
	. S TCTX("contact","successTitle")="Message received"
	. S TCTX("contact","successBody")="Thank you. We will review your request and follow up."
	I $G(STATE("form","hasErrors"))=1 D
	. S TCTX("contact","error")=1
	. S TCTX("contact","errorTitle")="Please review the form"
	. S TCTX("contact","errorBody")="Some fields need attention."
	I $D(STATE("form","values")) M TCTX("contact","form")=STATE("form","values")
	I $D(STATE("form","errors")) M TCTX("contact","errors")=STATE("form","errors")
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/contact")
	Q
	;
BUILDLEGAL(CONF,REQ,CTX,KIND,TCTX)
	D BASE(.CONF,.TCTX)
	I $G(KIND)="privacy" D  Q
	. D SETPAGE(.CONF,.TCTX,"","EFUZY Privacy | Public site notice","Read the public-site privacy notice for EFUZY contact submissions and evaluation activity.","/privacy","Privacy notice","Keep submissions minimal. Use evaluation data only.")
	. S TCTX("legal","kind")="privacy"
	. S TCTX("legal","sections",1,"title")="Contact submissions"
	. S TCTX("legal","sections",1,"body")="We store the details you submit so we can respond. Keep the message focused on your business workflow."
	. S TCTX("legal","sections",2,"title")="Evaluation use"
	. S TCTX("legal","sections",2,"body")="Public evaluation environments are for sample or non-sensitive data only. Uploaded artifacts expire automatically."
	. S TCTX("legal","sections",3,"title")="Operational logs"
	. S TCTX("legal","sections",3,"body")="Server logs may record request metadata for security, stability, and support."
	. S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/privacy")
	D SETPAGE(.CONF,.TCTX,"","EFUZY Terms | Public site terms","Read the public-site terms for evaluation use, contact requests, and self-hosted delivery discussions.","/terms","Terms of use","Use the public site for evaluation and business contact.")
	S TCTX("legal","kind")="terms"
	S TCTX("legal","sections",1,"title")="Evaluation scope"
	S TCTX("legal","sections",1,"body")="Public previews are for product evaluation. They are not a production service."
	S TCTX("legal","sections",2,"title")="Data expectations"
	S TCTX("legal","sections",2,"body")="Do not upload sensitive production data to shared evaluation environments."
	S TCTX("legal","sections",3,"title")="Commercial delivery"
	S TCTX("legal","sections",3,"body")="Commercial delivery terms, support scope, and licensing are handled directly during the sales process."
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/terms")
	Q
	;
PILLARS(TCTX)
	S TCTX("pillars",1,"title")="Self-hosted by design"
	S TCTX("pillars",1,"desc")="Keep operations close to your team and your infrastructure."
	S TCTX("pillars",1,"tone")="tone-sky"
	S TCTX("pillars",2,"title")="Configurable exports"
	S TCTX("pillars",2,"desc")="Save profile rules for columns, naming, and repeatable output."
	S TCTX("pillars",2,"tone")="tone-violet"
	S TCTX("pillars",3,"title")="Traceable jobs"
	S TCTX("pillars",3,"desc")="Review diagnostics, preview rows, and artifact history before delivery."
	S TCTX("pillars",3,"tone")="tone-emerald"
	S TCTX("pillars",4,"title")="SSR-first workflow"
	S TCTX("pillars",4,"desc")="Fast pages. Simple operations. Minimal JavaScript."
	S TCTX("pillars",4,"tone")="tone-amber"
	Q
	;
STEPS(TCTX)
	S TCTX("steps",1,"step")="01"
	S TCTX("steps",1,"title")="Stage the file"
	S TCTX("steps",1,"desc")="Upload an input file and create a job record."
	S TCTX("steps",2,"step")="02"
	S TCTX("steps",2,"title")="Preview the result"
	S TCTX("steps",2,"desc")="Review claims, service lines, diagnostics, and trace."
	S TCTX("steps",3,"step")="03"
	S TCTX("steps",3,"title")="Apply the profile"
	S TCTX("steps",3,"desc")="Use saved CSV rules for output naming and fields."
	S TCTX("steps",4,"step")="04"
	S TCTX("steps",4,"title")="Publish artifacts"
	S TCTX("steps",4,"desc")="Download deterministic output and keep the job history."
	Q
	;
DETAIL(TCTX)
	S TCTX("detail",1,"title")="Workspace"
	S TCTX("detail",1,"body")="A dense operator workspace. Clear queues. Clear next actions."
	S TCTX("detail",2,"title")="Profiles"
	S TCTX("detail",2,"body")="Save export rules once. Reuse them across jobs and watched-folder runs."
	S TCTX("detail",3,"title")="Artifacts"
	S TCTX("detail",3,"body")="Keep exports, reports, manifests, trace, and preview context together."
	S TCTX("detail",4,"title")="Deployment"
	S TCTX("detail",4,"body")="Run self-hosted. Keep local control. Expand workflows over time."
	Q
	;
DOCS(TCTX)
	S TCTX("docs","cards",1,"title")="User guide"
	S TCTX("docs","cards",1,"body")="Operational guidance for staging, preview review, profiles, diagnostics, and daily workflow habits."
	S TCTX("docs","cards",1,"href")="/guide"
	S TCTX("docs","cards",1,"cta")="Read the guide"
	S TCTX("docs","cards",2,"title")="User manual"
	S TCTX("docs","cards",2,"body")="Product scope, application areas, filesystem model, validation notes, and delivery model."
	S TCTX("docs","cards",2,"href")="/manual"
	S TCTX("docs","cards",2,"cta")="Read the manual"
	S TCTX("docs","cards",3,"title")="Services"
	S TCTX("docs","cards",3,"body")="Installation, development, and support services are available for a fee."
	S TCTX("docs","cards",3,"href")="/services"
	S TCTX("docs","cards",3,"cta")="View services"
	Q
	;
TRUST(TCTX)
	S TCTX("trust",1,"title")="Built from the real product"
	S TCTX("trust",1,"body")="The public site uses the same SSR-first visual language as the application."
	S TCTX("trust",2,"title")="Additive test coverage"
	S TCTX("trust",2,"body")="The codebase leans on passing additive tests for workflows, licensing, release packaging, and public routes."
	S TCTX("trust",3,"title")="Deterministic review"
	S TCTX("trust",3,"body")="Diagnostics, trace, round-trip visibility, and artifact manifests support confident review."
	S TCTX("trust",4,"title")="Self-hosted delivery"
	S TCTX("trust",4,"body")="Paid delivery can include source, installer scripts, startup flow, and operational guidance."
	Q
	;
PREVIEW(CONF,TCTX)
	N TTL
	S TTL=$G(CONF("fuz","demoArtifactTtlLabel"))
	S TCTX("preview","eyebrow")="Application preview"
	S TCTX("preview","title")="A close look at the workflow"
	S TCTX("preview","lead")="The live product keeps the same visual language. Dense cards. Clear status. Quick paths to preview and artifacts."
	S TCTX("preview","disclaimer")="Evaluation uploads and generated artifacts expire within "_TTL_"."
	S TCTX("preview","ctaLabel")="Create evaluation login"
	S TCTX("preview","ctaHref")=$G(CONF("fuz","demoHref"))
	S TCTX("preview","cards",1,"title")="Workspace"
	S TCTX("preview","cards",1,"meta")="Uploads, profiles, recent jobs"
	S TCTX("preview","cards",1,"rows",1,"label")="Queued jobs"
	S TCTX("preview","cards",1,"rows",1,"value")="04"
	S TCTX("preview","cards",1,"rows",2,"label")="Profiles"
	S TCTX("preview","cards",1,"rows",2,"value")="06"
	S TCTX("preview","cards",2,"title")="Preview"
	S TCTX("preview","cards",2,"meta")="Claims, lines, diagnostics"
	S TCTX("preview","cards",2,"rows",1,"label")="Claim sample"
	S TCTX("preview","cards",2,"rows",1,"value")="Ready"
	S TCTX("preview","cards",2,"rows",2,"label")="Trace rows"
	S TCTX("preview","cards",2,"rows",2,"value")="Available"
	S TCTX("preview","cards",3,"title")="Artifacts"
	S TCTX("preview","cards",3,"meta")="CSV, reports, manifest"
	S TCTX("preview","cards",3,"rows",1,"label")="Export"
	S TCTX("preview","cards",3,"rows",1,"value")="Deterministic"
	S TCTX("preview","cards",3,"rows",2,"label")="Retention"
	S TCTX("preview","cards",3,"rows",2,"value")=TTL
	Q
	;
FAQ(TCTX)
	S TCTX("faq",1,"title")="What is EFUZY today?"
	S TCTX("faq",1,"body")="A self-hosted file-processing workspace with an X12 837 to configurable CSV workflow."
	S TCTX("faq",2,"title")="What does the public demo do?"
	S TCTX("faq",2,"body")="It shows the workflow, the UI, and the evaluation path. Uploaded demo artifacts expire automatically."
	S TCTX("faq",3,"title")="How do paid deployments work?"
	S TCTX("faq",3,"body")="Paid delivery is self-hosted. It can include source delivery, installer scripts, and onboarding guidance."
	S TCTX("faq",4,"title")="Can we get help with rollout?"
	S TCTX("faq",4,"body")="Yes. Installation, development, and support services are available for a fee."
	Q
	;
DOCCALL(TCTX,TITLE,BODY,PHREF,PLABEL,SHREF,SLABEL)
	S TCTX("doc","callout","title")=$G(TITLE)
	S TCTX("doc","callout","body")=$G(BODY)
	S TCTX("doc","callout","primaryHref")=$G(PHREF)
	S TCTX("doc","callout","primaryLabel")=$G(PLABEL)
	S TCTX("doc","callout","secondaryHref")=$G(SHREF)
	S TCTX("doc","callout","secondaryLabel")=$G(SLABEL)
	Q
	;
SUBMITCONTACT(CONF,POST,STATE)
	N CLEAN
	K STATE
	D VALIDCONTACT(.CONF,.POST,.CLEAN,.STATE)
	I +$G(STATE("form","hasErrors")) Q:$Q 0  Q
	D SAVECONTACT(.CONF,.CLEAN,.STATE)
	S STATE("success")=1
	K STATE("form","values")
	Q:$Q 1
	Q
VALIDCONTACT(CONF,POST,CLEAN,STATE)
	N MAX
	K CLEAN
	S MAX=+$G(CONF("fuz","contactMaxMessageChars")) I MAX<1 S MAX=2000
	S CLEAN("name")=$$TRIM^MIOUTIL($G(POST("name")))
	S CLEAN("company")=$$TRIM^MIOUTIL($G(POST("company")))
	S CLEAN("email")=$$TRIM^MIOUTIL($$LC($G(POST("email"))))
	S CLEAN("useCase")=$$TRIM^MIOUTIL($G(POST("useCase")))
	S CLEAN("message")=$$TRIM^MIOUTIL($G(POST("message")))
	S CLEAN("website")=$$TRIM^MIOUTIL($G(POST("website")))
	M STATE("form","values")=CLEAN
	I CLEAN("website")'="" S STATE("form","errors","website")="invalid_submission",STATE("form","hasErrors")=1
	I CLEAN("name")="" S STATE("form","errors","name")="name_required",STATE("form","hasErrors")=1
	I CLEAN("email")="" S STATE("form","errors","email")="email_required",STATE("form","hasErrors")=1
	I CLEAN("email")'="",'$$EMAILOK(CLEAN("email")) S STATE("form","errors","email")="email_invalid",STATE("form","hasErrors")=1
	I CLEAN("message")="" S STATE("form","errors","message")="message_required",STATE("form","hasErrors")=1
	I CLEAN("message")'="",$L(CLEAN("message"))>MAX S STATE("form","errors","message")="message_too_long",STATE("form","hasErrors")=1
	Q
	;
EMAILOK(X)
	N P1,P2
	S X=$G(X)
	I X[" " Q 0
	I X'?.E1"@".E Q 0
	S P1=$P(X,"@",1),P2=$P(X,"@",2,999)
	I P1=""!(P2="") Q 0
	I P2'["." Q 0
	I $E(P2,1)="."!($E(P2,$L(P2))=".") Q 0
	Q 1
	;
SAVECONTACT(CONF,CLEAN,STATE)
	N ID,NOW
	S ID=$INCREMENT(^MIO("FUZ","contact","seq"))
	S NOW=$$NOWISO^MIOUTIL()
	S ^MIO("FUZ","contact",ID,"id")=ID
	S ^MIO("FUZ","contact",ID,"createdAt")=NOW
	S ^MIO("FUZ","contact",ID,"status")="new"
	S ^MIO("FUZ","contact",ID,"source")="public_site"
	S ^MIO("FUZ","contact",ID,"name")=$G(CLEAN("name"))
	S ^MIO("FUZ","contact",ID,"company")=$G(CLEAN("company"))
	S ^MIO("FUZ","contact",ID,"email")=$G(CLEAN("email"))
	S ^MIO("FUZ","contact",ID,"useCase")=$G(CLEAN("useCase"))
	S ^MIO("FUZ","contact",ID,"message")=$G(CLEAN("message"))
	S ^MIO("FUZ","contact","idx","status","new",ID)=""
	S STATE("contact","id")=ID
	S STATE("contact","status")="created"
	Q
	;
ABSURL(CONF,PATH)
	N BASE
	S BASE=$G(CONF("fuz","siteUrl"))
	I BASE="" S BASE="https://efuzy.com"
	I $E(BASE,$L(BASE))="/" S BASE=$E(BASE,1,$L(BASE)-1)
	I $G(PATH)="" Q BASE_"/"
	I $E(PATH,1)'="/" S PATH="/"_PATH
	Q BASE_PATH
	;
ROBOTSX(CONF,OUT)
	N URL
	S URL=$$ABSURL(.CONF,"/sitemap.xml")
	S OUT="User-agent: *"_$C(10)_"Allow: /"_$C(10)_""_$C(10)_"Sitemap: "_URL_$C(10)
	Q
	;
SITEMAPX(CONF,OUT)
	N URL,I,PATH
	S OUT="<?xml version=""1.0"" encoding=""UTF-8""?>"_$C(10)
	S OUT=OUT_"<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">"_$C(10)
	S PATH(1)="/",PATH(2)="/features",PATH(3)="/guide",PATH(4)="/manual",PATH(5)="/services",PATH(6)="/demo",PATH(7)="/contact",PATH(8)="/privacy",PATH(9)="/terms"
	F I=1:1:9 D
	. S URL=$$ABSURL(.CONF,PATH(I))
	. S OUT=OUT_"  <url><loc>"_URL_"</loc></url>"_$C(10)
	S OUT=OUT_"</urlset>"_$C(10)
	Q
	;
SOFTJSON(CONF,PATH)
	N URL,NAME,TAG
	S URL=$$ABSURL(.CONF,$G(PATH))
	S NAME=$$JESC($G(CONF("fuz","brand"),"efuzy"))
	S TAG=$$JESC($G(CONF("fuz","tagline"),"Self-hosted file-processing workflow workspace"))
	Q "<script type=""application/ld+json"">{""@context"":""https://schema.org"",""@type"":""SoftwareApplication"",""name"":"""_NAME_""",""applicationCategory"":""BusinessApplication"",""operatingSystem"":""Self-hosted"",""description"":"""_TAG_""",""url"":"""_$$JESC(URL)_"""}</script>"
	;
ARTJSON(CONF,PATH,TITLE,DESC)
	N URL
	S URL=$$ABSURL(.CONF,$G(PATH))
	Q "<script type=""application/ld+json"">{""@context"":""https://schema.org"",""@type"":""TechArticle"",""headline"":"""_$$JESC($G(TITLE))_""",""description"":"""_$$JESC($G(DESC))_""",""url"":"""_$$JESC(URL)_"""}</script>"
	;
SERVJSON(CONF,PATH,TITLE,DESC)
	N URL
	S URL=$$ABSURL(.CONF,$G(PATH))
	Q "<script type=""application/ld+json"">{""@context"":""https://schema.org"",""@type"":""Service"",""name"":"""_$$JESC($G(TITLE))_""",""description"":"""_$$JESC($G(DESC))_""",""url"":"""_$$JESC(URL)_"""}</script>"
	;
ORGJSON(CONF)
	N URL,NAME,EMAIL
	S URL=$$ABSURL(.CONF,"/")
	S NAME=$$JESC($G(CONF("fuz","brand"),"efuzy"))
	S EMAIL=$$JESC($G(CONF("fuz","contactEmail"),"hello@efuzy.com"))
	Q "<script type=""application/ld+json"">{""@context"":""https://schema.org"",""@type"":""Organization"",""name"":"""_NAME_""",""url"":"""_$$JESC(URL)_""",""email"":"""_EMAIL_"""}</script>"
	;
JESC(X)
	N Y
	S Y=$TR($G(X),"\","")
	S Y=$TR(Y,$C(34),"'")
	Q Y
	;
TTLLAB(H)
	I +$G(H)<1 Q "24 hours"
	I H=24 Q "24 hours"
	I H#24=0 Q (H\24)_" days"
	I H=1 Q "1 hour"
	Q H_" hours"
	;
LC(X) Q $ZCONVERT(X,"L")