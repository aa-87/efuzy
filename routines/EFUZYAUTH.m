EFUZYAUTH ; efuzy demo auth/session helpers
	;
	Q
	;
COOKIE() Q "efuzy_demo"
	;
NEXTUSER()
	N ID
	L +^MIO("EFUZY","SEQ","USER"):2 E  Q 0
	S ID=$I(^MIO("EFUZY","SEQ","USER"))
	L -^MIO("EFUZY","SEQ","USER")
	Q ID
	;
NORMUSER(X)
	N I,C,O
	S X=$ZCONVERT($$TRIM^MIOUTIL($G(X)),"L"),O=""
	F I=1:1:$L(X) S C=$E(X,I) D
	. I C?1AN S O=O_C Q
	. I ".-_"[C S O=O_C
	Q O
	;
VALIDPW(PW,ERR)
	I $L($G(PW))<8 S ERR("error")="password_too_short" Q 0
	Q 1
	;
HASHPW(SALT,PW)
	Q $$SHA256^MIOSHA256($G(SALT)_":"_$G(PW))
	;
SIGNUP(LOGIN,PW,CONF,USERID,ERR)
	N UN,SALT,HASH,NOW
	K ERR S USERID=0
	S UN=$$NORMUSER($G(LOGIN))
	I $L(UN)<3 S ERR("error")="login_invalid" Q:$Q 0 Q
	I '$$VALIDPW($G(PW),.ERR) Q:$Q 0 Q
	I $D(^MIO("EFUZY","auth","userByName",UN)) S ERR("error")="login_taken" Q:$Q 0 Q
	S USERID=$$NEXTUSER()
	I 'USERID S ERR("error")="user_seq_busy" Q:$Q 0 Q
	S SALT=$TR($$UUID^MIOUTIL(),"-","")
	S HASH=$$HASHPW(SALT,$G(PW))
	S NOW=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","auth","user",USERID,"id")=USERID
	S ^MIO("EFUZY","auth","user",USERID,"login")=UN
	S ^MIO("EFUZY","auth","user",USERID,"passwordSalt")=SALT
	S ^MIO("EFUZY","auth","user",USERID,"passwordHash")=HASH
	S ^MIO("EFUZY","auth","user",USERID,"createdAt")=NOW
	S ^MIO("EFUZY","auth","user",USERID,"updatedAt")=NOW
	S ^MIO("EFUZY","auth","userByName",UN)=USERID
	Q:$Q 1 Q
	;
LOGIN(LOGIN,PW,CONF,USERID,SID,ERR)
	N UN,EXPECT,NOW
	K ERR S (USERID,SID)=0
	S UN=$$NORMUSER($G(LOGIN))
	I UN="" S ERR("error")="login_required" Q:$Q 0 Q
	S USERID=+$G(^MIO("EFUZY","auth","userByName",UN))
	I 'USERID S ERR("error")="invalid_credentials" Q:$Q 0 Q
	S EXPECT=$$HASHPW($G(^MIO("EFUZY","auth","user",USERID,"passwordSalt")),$G(PW))
	I EXPECT'=$G(^MIO("EFUZY","auth","user",USERID,"passwordHash")) S ERR("error")="invalid_credentials" Q:$Q 0 Q
	S NOW=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","auth","user",USERID,"lastLoginAt")=NOW
	S ^MIO("EFUZY","auth","user",USERID,"updatedAt")=NOW
	S SID=$$NEWSESS(USERID)
	I SID="" S ERR("error")="session_create_failed" Q:$Q 0 Q
	Q:$Q 1 Q
	;
NEWSESS(USERID)
	N SID,NOW
	S SID=$TR($$UUID^MIOUTIL(),"-","")
	I SID="" Q ""
	S NOW=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","auth","session",SID,"id")=SID
	S ^MIO("EFUZY","auth","session",SID,"userId")=+USERID
	S ^MIO("EFUZY","auth","session",SID,"createdAt")=NOW
	S ^MIO("EFUZY","auth","session",SID,"lastSeenAt")=NOW
	S ^MIO("EFUZY","auth","user",+USERID,"lastSessionId")=SID
	Q SID
	;
GETCOOKIE(REQ,NAME)
	N RAW,I,PAIR,K,V
	S RAW=$G(REQ("hdr","cookie"))
	F I=1:1:$L(RAW,";") S PAIR=$P(RAW,";",I) D  Q:$G(V)'=""
	. S K=$$NORMUSER($P($$TRIM^MIOUTIL(PAIR),"=",1))
	. I K'=$$NORMUSER($G(NAME)) Q
	. S V=$P(PAIR,"=",2,999)
	Q $G(V)
	;
CURUSER(REQ,USER)
	N SID,UID,NOW
	K USER
	S SID=$$GETCOOKIE(.REQ,$$COOKIE())
	I SID="" Q 0
	S UID=+$G(^MIO("EFUZY","auth","session",SID,"userId"))
	I 'UID Q 0
	I '$D(^MIO("EFUZY","auth","user",UID)) Q 0
	S NOW=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","auth","session",SID,"lastSeenAt")=NOW
	S USER("sessionId")=SID
	S USER("userId")=UID
	S USER("login")=$G(^MIO("EFUZY","auth","user",UID,"login"))
	Q 1
	;
SETCTX(REQ,CTX,USER)
	S REQ("efuzy","userId")=+$G(USER("userId"))
	S REQ("efuzy","login")=$G(USER("login"))
	S CTX("efuzy","userId")=+$G(USER("userId"))
	S CTX("efuzy","login")=$G(USER("login"))
	Q
	;
AUTHREQ(REQ,CTX)
	N USER
	I '$$CURUSER(.REQ,.USER) Q 0
	D SETCTX(.REQ,.CTX,.USER)
	Q 1
	;
OWNS(USERID,KIND,ID)
	I +$G(USERID)<1 Q 0
	I +$G(ID)<1 Q 0
	Q $S($G(^MIO("EFUZY",KIND,+ID,"ownerId"))=+USERID:1,1:0)
	;
OWNSFILE(USERID,ID) Q $$OWNS(+$G(USERID),"file",+$G(ID))
OWNSJOB(USERID,ID) Q $$OWNS(+$G(USERID),"job",+$G(ID))
OWNSPROF(USERID,ID) Q $S(+$G(ID)<1:0,$G(^MIO("EFUZY","cfg","profile",+ID,"ownerId"))=+USERID:1,1:0)
OWNSAUTO(USERID,ID) Q $S(+$G(ID)<1:0,$G(^MIO("EFUZY","cfg","auto",+ID,"ownerId"))=+USERID:1,1:0)
	;
STAMPFILE(FILEID,USERID)
	N UN
	S UN=$G(^MIO("EFUZY","auth","user",+USERID,"login"))
	S ^MIO("EFUZY","file",+FILEID,"ownerId")=+USERID
	S ^MIO("EFUZY","file",+FILEID,"ownerLogin")=UN
	S ^MIO("EFUZY","idx","owner","file",+USERID,+FILEID)=""
	Q
	;
STAMPJOB(JOBID,USERID)
	N UN,ST
	S UN=$G(^MIO("EFUZY","auth","user",+USERID,"login"))
	S ^MIO("EFUZY","job",+JOBID,"ownerId")=+USERID
	S ^MIO("EFUZY","job",+JOBID,"ownerLogin")=UN
	S ^MIO("EFUZY","idx","owner","job",+USERID,+JOBID)=""
	S ST=$G(^MIO("EFUZY","job",+JOBID,"status"))
	I ST'="" S ^MIO("EFUZY","idx","job","ownerStatus",+USERID,ST,+JOBID)=""
	Q
	;
STAMPPROF(ID,USERID)
	N UN
	S UN=$G(^MIO("EFUZY","auth","user",+USERID,"login"))
	S ^MIO("EFUZY","cfg","profile",+ID,"ownerId")=+USERID
	S ^MIO("EFUZY","cfg","profile",+ID,"ownerLogin")=UN
	S ^MIO("EFUZY","idx","owner","profile",+USERID,+ID)=""
	Q
	;
STAMPAUTO(ID,USERID)
	N UN
	S UN=$G(^MIO("EFUZY","auth","user",+USERID,"login"))
	S ^MIO("EFUZY","cfg","auto",+ID,"ownerId")=+USERID
	S ^MIO("EFUZY","cfg","auto",+ID,"ownerLogin")=UN
	S ^MIO("EFUZY","idx","owner","auto",+USERID,+ID)=""
	Q
	;
UNSTAMP(KIND,USERID,ID)
	K ^MIO("EFUZY","idx","owner",KIND,+USERID,+ID)
	I KIND="job" D
	. N ST S ST=$G(^MIO("EFUZY","job",+ID,"status"))
	. I ST'="" K ^MIO("EFUZY","idx","job","ownerStatus",+USERID,ST,+ID)
	Q
	;
SESSCOOKIE(SID)
	Q $$COOKIE()_"="_$G(SID)_"; Path=/; HttpOnly; SameSite=Lax"
	;
CLEARCOOKIE()
	Q $$COOKIE()_"=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0"
	;
REDIRHTML(TARGET)
	Q "<!doctype html><html><head><meta http-equiv=""refresh"" content=""0; url="""_$G(TARGET)_"""></head><body><script>window.location="""_$G(TARGET)_""";</script><a href="""_$G(TARGET)_""">Continue</a></body></html>"
	;
BUILDPAGE(CONF,REQ,CTX,STATE,TCTX)
	D BASE^EFUZYUI(.TCTX)
	S TCTX("page","title")="Demo Access"
	S TCTX("page","heading")="Create evaluation access"
	S TCTX("page","lead")="Create a demo login and password to open the evaluation workspace. Data is isolated by demo user and intended for evaluation only."
	S TCTX("page","eyebrow")="Evaluation access"
	S TCTX("auth","signupAction")="/efuzy/demo/signup"
	S TCTX("auth","loginAction")="/efuzy/demo/login"
	S TCTX("auth","login")=$G(STATE("login"))
	S TCTX("auth","loginHelp")="Use a short login such as your initials or team name."
	S TCTX("auth","passwordHelp")="Use at least 8 characters."
	S TCTX("auth","note",1,"title")="Evaluation only"
	S TCTX("auth","note",1,"body")="Do not upload production PHI. The public demo is for product evaluation only."
	S TCTX("auth","note",2,"title")="User isolation"
	S TCTX("auth","note",2,"body")="Uploaded files, jobs, profiles, and automation settings are scoped to the signed-in demo user."
	S TCTX("auth","note",3,"title")="What happens next"
	S TCTX("auth","note",3,"body")="After sign-in, the workspace opens and saves your demo activity under your account."
	I $G(STATE("error"))'="" S TCTX("state","errorAny")=1,TCTX("state","error")=$G(STATE("error"))
	Q
	;
ERRTEXT(CODE)
	I $G(CODE)="login_invalid" Q "Choose a login with at least 3 letters or numbers."
	I $G(CODE)="password_too_short" Q "Choose a password with at least 8 characters."
	I $G(CODE)="login_taken" Q "That login already exists. Sign in instead or choose another login."
	I $G(CODE)="invalid_credentials" Q "The login or password did not match."
	I $G(CODE)="login_required" Q "Enter your login."
	Q "Unable to continue."
	;
LOGOUT(REQ)
	N SID
	S SID=$$GETCOOKIE(.REQ,$$COOKIE())
	I SID'="" K ^MIO("EFUZY","auth","session",SID)
	Q
	;
	;