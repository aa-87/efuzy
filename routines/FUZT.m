FUZT ; FUZ helper/view-model tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - FUZT"
 Q
 ;
ALL(FAIL)
 D T001(.FAIL)
 D T010(.FAIL)
 D T020(.FAIL)
 D T030(.FAIL)
 D T031(.FAIL)
 D T032(.FAIL)
 D T033(.FAIL)
 D T040(.FAIL)
 D T050(.FAIL)
 D T060(.FAIL)
 D T070(.FAIL)
 D T080(.FAIL)
 D T090(.FAIL)
 D T100(.FAIL)
 D T110(.FAIL)
 Q
 ;
BASECONF(CONF)
 K CONF,^MIO("FUZ")
 D CONFDEF^FUZUI(.CONF)
 Q
 ;
T001(FAIL) ; base context seeds nav and site data
 N CONF,TCTX
 D BASECONF(.CONF)
 D BASE^FUZUI(.CONF,.TCTX)
 D EQ(.FAIL,"[T001][brand]",$G(TCTX("app","name")),"efuzy")
 D EQ(.FAIL,"[T001][nav home]",$G(TCTX("nav",1,"href")),"/")
 D EQ(.FAIL,"[T001][ttl label]",$G(TCTX("site","demoArtifactTtlLabel")),"24 hours")
 D EQ(.FAIL,"[T001][guide nav]",$G(TCTX("nav",3,"href")),"/guide")
 Q
 ;
T010(FAIL) ; home builder sets SEO and preview context
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILDHOME^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T010][title]",$G(TCTX("page","title"))["EFUZY",1)
 D EQ(.FAIL,"[T010][canonical]",$G(TCTX("page","canonical")),"https://efuzy.com/")
 D EQ(.FAIL,"[T010][preview disclaimer]",$G(TCTX("preview","disclaimer"))["24 hours",1)
 D EQ(.FAIL,"[T010][jsonld]",$G(TCTX("page","jsonld"))["SoftwareApplication",1)
 D EQ(.FAIL,"[T010][docs card]",$G(TCTX("docs","cards",2,"href")),"/manual")
 Q
 ;
T020(FAIL) ; demo builder exposes disclaimer and open href
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 S CONF("fuz","demoHref")="/efuzy/demo"
 S CONF("fuz","demoArtifactTtlHours")=48
 S CONF("fuz","demoArtifactTtlLabel")=$$TTLLAB^FUZUI(48)
 D BUILDDEMO^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T020][open href]",$G(TCTX("demo","openHref")),"/efuzy/demo")
 D EQ(.FAIL,"[T020][callout]",$G(TCTX("demo","callout","body"))["2 days",1)
 Q
 ;
T030(FAIL) ; contact validate success path
 N CONF,POST,CLEAN,STATE
 D BASECONF(.CONF)
 S POST("name")="Ahmed"
 S POST("company")="Acme Billing"
 S POST("email")="ahmed@example.com"
 S POST("useCase")="Self-hosted"
 S POST("message")="We want a private workflow workspace."
 D VALIDCONTACT^FUZUI(.CONF,.POST,.CLEAN,.STATE)
 D EQ(.FAIL,"[T030][no errors]",+$G(STATE("form","hasErrors")),0)
 D EQ(.FAIL,"[T030][clean email]",$G(CLEAN("email")),"ahmed@example.com")
 Q
 ;
T031(FAIL) ; missing name fails
 N CONF,POST,CLEAN,STATE
 D BASECONF(.CONF)
 S POST("email")="ops@example.com",POST("message")="Need onboarding."
 D VALIDCONTACT^FUZUI(.CONF,.POST,.CLEAN,.STATE)
 D EQ(.FAIL,"[T031][error]",$G(STATE("form","errors","name")),"name_required")
 Q
 ;
T032(FAIL) ; bad email fails
 N CONF,POST,CLEAN,STATE
 D BASECONF(.CONF)
 S POST("name")="Ops",POST("email")="ops-at-example",POST("message")="Need deployment help."
 D VALIDCONTACT^FUZUI(.CONF,.POST,.CLEAN,.STATE)
 D EQ(.FAIL,"[T032][error]",$G(STATE("form","errors","email")),"email_invalid")
 Q
 ;
T033(FAIL) ; honeypot fails
 N CONF,POST,CLEAN,STATE
 D BASECONF(.CONF)
 S POST("name")="Ops",POST("email")="ops@example.com",POST("message")="Need deployment help.",POST("website")="spam"
 D VALIDCONTACT^FUZUI(.CONF,.POST,.CLEAN,.STATE)
 D EQ(.FAIL,"[T033][error]",$G(STATE("form","errors","website")),"invalid_submission")
 Q
 ;
T040(FAIL) ; submit saves a lead record
 N CONF,POST,STATE,ID
 D BASECONF(.CONF)
 S POST("name")="Ahmed",POST("company")="Acme Billing",POST("email")="ahmed@example.com",POST("message")="Please contact us.",POST("useCase")="Evaluation"
 D SUBMITCONTACT^FUZUI(.CONF,.POST,.STATE)
 S ID=+$G(STATE("contact","id"))
 D EQ(.FAIL,"[T040][saved]",ID>0,1)
 D EQ(.FAIL,"[T040][status]",$G(^MIO("FUZ","contact",ID,"status")),"new")
 D EQ(.FAIL,"[T040][email]",$G(^MIO("FUZ","contact",ID,"email")),"ahmed@example.com")
 Q
 ;
T050(FAIL) ; privacy page builder has legal sections
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILDLEGAL^FUZUI(.CONF,.REQ,.CTX,"privacy",.TCTX)
 D EQ(.FAIL,"[T050][kind]",$G(TCTX("legal","kind")),"privacy")
 D EQ(.FAIL,"[T050][section]",$D(TCTX("legal","sections",1))>0,1)
 Q
 ;
T060(FAIL) ; robots includes sitemap
 N CONF,OUT
 D BASECONF(.CONF)
 D ROBOTSX^FUZUI(.CONF,.OUT)
 D EQ(.FAIL,"[T060][allow]",OUT["Allow: /",1)
 D EQ(.FAIL,"[T060][sitemap]",OUT["sitemap.xml",1)
 Q
 ;
T070(FAIL) ; sitemap includes public pages
 N CONF,OUT
 D BASECONF(.CONF)
 D SITEMAPX^FUZUI(.CONF,.OUT)
 D EQ(.FAIL,"[T070][root]",OUT["https://efuzy.com/",1)
 D EQ(.FAIL,"[T070][guide]",OUT["https://efuzy.com/guide",1)
 D EQ(.FAIL,"[T070][services]",OUT["https://efuzy.com/services",1)
 D EQ(.FAIL,"[T070][terms]",OUT["https://efuzy.com/terms",1)
 Q
 ;
T080(FAIL) ; guide builder exposes operational sections
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILDGUIDE^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T080][title]",$G(TCTX("page","title"))["User Guide",1)
 D EQ(.FAIL,"[T080][section]",$G(TCTX("doc","sections",3,"title")),"Standard workflow")
 D EQ(.FAIL,"[T080][callout]",$G(TCTX("doc","callout","body"))["profile setup",1)
 Q
 ;
T090(FAIL) ; manual builder exposes technical scope
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILDMANUAL^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T090][manual title]",$G(TCTX("page","title"))["User Manual",1)
 D EQ(.FAIL,"[T090][tech section]",$G(TCTX("doc","sections",3,"title")),"Technical architecture")
 D EQ(.FAIL,"[T090][service note]",$G(TCTX("doc","sections",6,"items",3,"text"))["support",1)
 Q
 ;
T100(FAIL) ; services builder exposes fee-based support text
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILDSERVICES^FUZUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T100][lead]",$G(TCTX("page","lead"))["for a fee",1)
 D EQ(.FAIL,"[T100][offer]",$G(TCTX("services","offers",1,"title")),"Installation help")
 D EQ(.FAIL,"[T100][cta]",$G(TCTX("services","ctaPrimaryHref")),"/contact")
 Q
 ;
T110(FAIL) ; ttl helper keeps 24 hours label exact
 D EQ(.FAIL,"[T110][24 hours]",$$TTLLAB^FUZUI(24),"24 hours")
 D EQ(.FAIL,"[T110][48 hours]",$$TTLLAB^FUZUI(48),"2 days")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
