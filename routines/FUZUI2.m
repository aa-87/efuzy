FUZUI ; public efuzy site view models and helpers
	;
	Q
	;
CONFDEF(CONF)
	I $G(CONF("fuz","siteUrl"))="" S CONF("fuz","siteUrl")="https://efuzy.com"
	I $G(CONF("fuz","brand"))="" S CONF("fuz","brand")="efuzy"
	I $G(CONF("fuz","tagline"))="" S CONF("fuz","tagline")="Self-hosted file-processing workflow workspace"
	I $G(CONF("fuz","shell"))="" S CONF("fuz","shell")="efuzy / MUMPS.IO"
	I $G(CONF("fuz","demoHref"))="" S CONF("fuz","demoHref")="/efuzy/workspace"
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
	S TCTX("nav",3,"key")="demo"
	S TCTX("nav",3,"label")="Demo"
	S TCTX("nav",3,"href")="/demo"
	S TCTX("nav",4,"key")="contact"
	S TCTX("nav",4,"label")="Contact"
	S TCTX("nav",4,"href")="/contact"
	Q
	;
FOOT(TCTX)
	S TCTX("footer","links",1,"label")="Overview"
	S TCTX("footer","links",1,"href")="/"
	S TCTX("footer","links",2,"label")="Workflow"
	S TCTX("footer","links",2,"href")="/features"
	S TCTX("footer","links",3,"label")="Demo"
	S TCTX("footer","links",3,"href")="/demo"
	S TCTX("footer","links",4,"label")="Contact"
	S TCTX("footer","links",4,"href")="/contact"
	S TCTX("footer","links",5,"label")="Privacy"
	S TCTX("footer","links",5,"href")="/privacy"
	S TCTX("footer","links",6,"label")="Terms"
	S TCTX("footer","links",6,"href")="/terms"
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
	D SETPAGE(.CONF,.TCTX,"home","EFUZY | Self-hosted file-processing workflow workspace","Self-hosted file-processing workflow workspace for configurable X12 exports, traceable jobs, and private operational review.","/","Self-hosted file-processing workflow workspace","Private workflows. Clear outputs. Traceable results.")
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
	D PREVIEW(.CONF,.TCTX)
	D FAQ(.TCTX)
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/")
	Q
	;
BUILDFEAT(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"features","EFUZY Workflow | Configurable export and traceable jobs","See how EFUZY stages files, previews claims, applies export profiles, and keeps traceable job artifacts.","/features","Workflow details","Short steps. Clear controls. Deterministic outputs.")
	D PILLARS(.TCTX)
	D STEPS(.TCTX)
	D DETAIL(.TCTX)
	S TCTX("page","jsonld")=$$SOFTJSON(.CONF,"/features")
	Q
	;
BUILDDEMO(CONF,REQ,CTX,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"demo","EFUZY Demo | Evaluation workflow preview","Preview the EFUZY application and evaluation flow. Demo uploads and generated artifacts expire automatically.","/demo","Preview the application","Use sample data first. Uploaded demo artifacts expire automatically.")
	D PREVIEW(.CONF,.TCTX)
	S TCTX("demo","callout","title")="Evaluation disclaimer"
	S TCTX("demo","callout","body")="Use evaluation data only. Uploaded files and generated artifacts expire within "_$G(CONF("fuz","demoArtifactTtlLabel"))_". Do not upload production PHI."
	S TCTX("demo","openLabel")="Open evaluation workspace"
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
BUILDCONTACT(CONF,REQ,CTX,STATE,TCTX)
	D BASE(.CONF,.TCTX)
	D SETPAGE(.CONF,.TCTX,"contact","Contact EFUZY | Self-hosted workflow software","Contact EFUZY about self-hosted deployment, evaluation access, implementation guidance, and commercial licensing.","/contact","Contact us","Tell us about your workflow, your environment, and your timeline.")
	S TCTX("contact","action")="/contact"
	S TCTX("contact","method")="post"
	S TCTX("contact","intro")="We reply with the right next step."
	S TCTX("contact","help",1)="Self-hosted deployment"
	S TCTX("contact","help",2)="Evaluation access"
	S TCTX("contact","help",3)="Commercial licensing"
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
PREVIEW(CONF,TCTX)
	N TTL
	S TTL=$G(CONF("fuz","demoArtifactTtlLabel"))
	S TCTX("preview","eyebrow")="Application preview"
	S TCTX("preview","title")="A close look at the workflow"
	S TCTX("preview","lead")="The live product keeps the same visual language. Dense cards. Clear status. Quick paths to preview and artifacts."
	S TCTX("preview","disclaimer")="Evaluation uploads and generated artifacts expire within "_TTL_"."
	S TCTX("preview","ctaLabel")="Open evaluation workspace"
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
	;
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
	S PATH(1)="/",PATH(2)="/features",PATH(3)="/demo",PATH(4)="/contact",PATH(5)="/privacy",PATH(6)="/terms"
	F I=1:1:6 D
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