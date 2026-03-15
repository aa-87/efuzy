EFUZYLIC ; efuzy offline licensing and activation helpers
	;
	Q
	;
CFG(CONF) ; normalize licensing defaults into CONF
	N MODE,PROD,SEC,ALG
	S MODE=$$MODE($G(CONF("efuzy","license","mode")))
	S CONF("efuzy","license","mode")=MODE
	I $G(CONF("efuzy","license","edition"))="" S CONF("efuzy","license","edition")=$$EDITION("",MODE)
	I $G(CONF("efuzy","license","filePath"))="" S CONF("efuzy","license","filePath")="instance/license/efuzy.license"
	I $G(CONF("efuzy","license","installIdPath"))="" S CONF("efuzy","license","installIdPath")="instance/license/efuzy.install_id"
	S CONF("efuzy","license","hostStrategy")=$$HOSTSTGY($G(CONF("efuzy","license","hostStrategy")))
	S PROD=$G(CONF("efuzy","license","product")) I PROD="" S PROD="efuzy"
	S CONF("efuzy","license","product")=PROD
	I $G(CONF("efuzy","license","jwtIssuer"))="" S CONF("efuzy","license","jwtIssuer")="efuzy-license"
	I $G(CONF("efuzy","license","jwtAudience"))="" S CONF("efuzy","license","jwtAudience")=PROD
	S ALG=$$ALG($G(CONF("efuzy","license","jwtAlgorithm")))
	S CONF("efuzy","license","jwtAlgorithm")=ALG
	I $G(CONF("efuzy","license","rs256PublicKeyPath"))="" S CONF("efuzy","license","rs256PublicKeyPath")="instance/license/keys/efuzy_license_public.pem"
	I $G(CONF("efuzy","license","rs256PrivateKeyPath"))="" S CONF("efuzy","license","rs256PrivateKeyPath")=""
	I $G(CONF("efuzy","license","opensslBin"))="" S CONF("efuzy","license","opensslBin")="openssl"
	I $G(CONF("efuzy","license","allowHmacJwt"))="" S CONF("efuzy","license","allowHmacJwt")=0
	S SEC=$G(CONF("efuzy","license","jwtSecret"))
	I SEC="" S SEC=$G(CONF("auth","jwt","hmacSecret"))
	I SEC="" S SEC=$ZTRNLNM("EFUZY_LICENSE_SECRET")
	I SEC="" S SEC=$ZTRNLNM("MIO_LICENSE_SECRET")
	S CONF("efuzy","license","jwtSecret")=SEC
	I +$G(CONF("efuzy","license","jwtClockSkewSeconds"))<1 S CONF("efuzy","license","jwtClockSkewSeconds")=60
	I $G(CONF("efuzy","license","longLivedDays"))="" S CONF("efuzy","license","longLivedDays")=3650
	I $G(CONF("efuzy","license","requireValidOnStartup"))="" S CONF("efuzy","license","requireValidOnStartup")=$S(MODE="demo":0,1:1)
	Q
	;
CHECK(CONF,RES) ; alias for STATUS
	I $Q Q $$STATUS(.CONF,.RES)
	D STATUS(.CONF,.RES)
	Q
	;
STATUS(CONF,RES) ; inspect effective activation state
	N OK,MODE,LIC,ERR,IDRES,TODAY,TODAYK,EXP,EXPK,MAINT,MAINTK,LICED,HOST,HOSTCFG,INSTALLID,REQID,TOK,CTX,JERR
	K RES
	D CFG(.CONF)
	S MODE=$$MODE($G(CONF("efuzy","license","mode")))
	S OK=1
	S TODAY=$$TODAY()
	S TODAYK=$$DATEKEY(TODAY)
	S RES("routine")="EFUZYLIC"
	S RES("mode")=MODE
	S RES("edition")=$$EDITION($G(CONF("efuzy","license","edition")),MODE)
	S RES("product")=$G(CONF("efuzy","license","product"),"efuzy")
	S RES("licensePath")=$$LICPATH(.CONF)
	S RES("installIdPath")=$$IDPATH(.CONF)
	S RES("hostStrategy")=$$HOSTSTGY($G(CONF("efuzy","license","hostStrategy")))
	S RES("today")=TODAY
	S RES("jwtIssuer")=$G(CONF("efuzy","license","jwtIssuer"))
	S RES("jwtAudience")=$G(CONF("efuzy","license","jwtAudience"))
	S RES("jwtAlgorithm")=$G(CONF("efuzy","license","jwtAlgorithm"))
	S RES("rs256PublicKeyPath")=$$PUBKEY(.CONF)
	D READID(.CONF,.IDRES)
	M RES("install")=IDRES
	I MODE="demo" D  Q:$Q 1 Q
	. S RES("ok")=1
	. S RES("status")="demo"
	. S RES("licensed")=0
	. S RES("demo")=1
	. D STAMP(.RES)
	I $G(RES("licensePath"))="" D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="license_path_missing"
	. D STAMP(.RES)
	I '$$FEX($G(RES("licensePath"))) D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="missing"
	. S RES("error")="license_file_missing"
	. D STAMP(.RES)
	S TOK=""
	D READTOK($G(RES("licensePath")),.TOK)
	I TOK'="" D
	. I '$$VERIFYTOK(.CONF,TOK,.LIC,.CTX,.JERR) D  Q
	. . S OK=0
	. . S RES("status")=$S($G(JERR("error"))="license_expired":"expired",1:"invalid")
	. . S RES("error")=$G(JERR("error"),"license_invalid_token")
	. . M RES("verify")=JERR
	. . D STAMP(.RES)
	. S RES("format")="jwt"
	. M RES("license")=LIC
	. I $G(LIC("_alg"))'="" S RES("algorithm")=$G(LIC("_alg"))
	I TOK'="",'OK Q:$Q 0 Q
	I TOK'="" G STATUSX
	I '$$LOAD($G(RES("licensePath")),.LIC,.ERR) D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")=$G(ERR("error"),"license_read_failed")
	. D STAMP(.RES)
	S RES("format")="legacy"
	M RES("license")=LIC
STATUSX ; shared post-load validation
	I $$LC($G(LIC("product")))'=$$LC($G(RES("product"))) D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="license_product_mismatch"
	. D STAMP(.RES)
	S LICED=$$LC($G(LIC("edition")))
	I MODE="evaluation",LICED'="evaluation" D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="license_edition_invalid"
	. D STAMP(.RES)
	I MODE="paid",'$$ISPAIDED(LICED) D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="license_edition_invalid"
	. D STAMP(.RES)
	S EXP=$$DATE10($G(LIC("expires_at")))
	I EXP="",+$G(LIC("exp"))>0 S EXP=$$EPOCH2DATE(+$G(LIC("exp")))
	S EXPK=$$DATEKEY(EXP)
	I MODE="evaluation",EXP="",+$G(LIC("exp"))'>0 D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="evaluation_expiry_required"
	. D STAMP(.RES)
	I EXPK'="",TODAYK'="",EXPK<TODAYK D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="expired"
	. S RES("error")="license_expired"
	. D STAMP(.RES)
	S MAINT=$$DATE10($G(LIC("maintenance_until")))
	S MAINTK=$$DATEKEY(MAINT)
	S RES("supportActive")=$S(MAINTK="":1,(TODAYK'="")&(MAINTK<TODAYK):0,1:1)
	I 'RES("supportActive") S RES("warning")="maintenance_expired"
	S INSTALLID=$G(IDRES("installId"))
	S REQID=$G(LIC("install_id"))
	I REQID'="",INSTALLID'=REQID D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="install_id_mismatch"
	. D STAMP(.RES)
	S HOST=$$HOSTID(.CONF)
	S HOSTCFG=$$LC($G(LIC("host")))
	I $G(RES("hostStrategy"))'="none",HOSTCFG'="",HOSTCFG'="any",HOSTCFG'=$$LC(HOST) D  Q:$Q 0 Q
	. S RES("ok")=0
	. S RES("status")="invalid"
	. S RES("error")="license_host_mismatch"
	. D STAMP(.RES)
	S RES("ok")=OK
	S RES("licensed")=1
	S RES("demo")=0
	S RES("status")=$S(MODE="evaluation":"evaluation",1:"licensed")
	D STAMP(.RES)
	Q:$Q OK Q
	;
ISSUE(CONF,SPEC,RES) ; internal helper to issue a jwt-backed license
	N MODE,ED,PROD,LICE,INSTALLID,HOST,EXPDT,MAINTDT,NOW,TOK,PAYARR,PAYJSON,HJSON,FPATH,DIR,ERR,ALG
	K RES
	D CFG(.CONF)
	S RES("routine")="EFUZYLIC"
	S MODE=$$MODE($G(SPEC("mode"),$G(CONF("efuzy","license","mode"))))
	S ED=$$EDITION($G(SPEC("edition")),MODE)
	S PROD=$G(SPEC("product"),$G(CONF("efuzy","license","product"),"efuzy"))
	S LICE=$G(SPEC("licensee")) I LICE="" S LICE="EFUZY Customer"
	S INSTALLID=$G(SPEC("install_id"))
	S HOST=$G(SPEC("host"))
	S MAINTDT=$$DATE10($G(SPEC("maintenance_until"))) I MAINTDT="" S MAINTDT=$$DATEPLUS(365)
	S EXPDT=$$DATE10($G(SPEC("expires_at")))
	I MODE="evaluation",EXPDT="" S EXPDT=$$DATEPLUS(30)
	I MODE="paid",EXPDT="" S EXPDT=$$DATEPLUS(+$G(CONF("efuzy","license","longLivedDays"),3650))
	S ALG=$$ALG($G(SPEC("alg"),$G(CONF("efuzy","license","jwtAlgorithm"))))
	S NOW=$$NOWS^MIOAUTHJWT()
	K PAYARR
	S PAYARR("iss")=$G(CONF("efuzy","license","jwtIssuer"))
	S PAYARR("aud")=$G(CONF("efuzy","license","jwtAudience"))
	S PAYARR("sub")=$S($G(SPEC("sub"))'="":$G(SPEC("sub")),1:$$NEWID())
	S PAYARR("jti")=$$NEWID()
	S PAYARR("typ")="efuzy-license"
	S PAYARR("product")=PROD
	S PAYARR("edition")=ED
	S PAYARR("licensee")=LICE
	S PAYARR("mode")=MODE
	S PAYARR("issued_at_iso")=$$NOWISO^MIOUTIL()
	S PAYARR("maintenance_until")=MAINTDT
	S PAYARR("iat")=NOW
	S PAYARR("nbf")=NOW
	I EXPDT'="" S PAYARR("expires_at")=EXPDT,PAYARR("exp")=$$EPOCH10(EXPDT,1)
	I INSTALLID'="" S PAYARR("install_id")=INSTALLID
	I HOST'="" S PAYARR("host")=HOST
	I $G(SPEC("customer_id"))'="" S PAYARR("customer_id")=$G(SPEC("customer_id"))
	I $G(SPEC("notes"))'="" S PAYARR("notes")=$G(SPEC("notes"))
	I '$$ENCJSON(.PAYARR,.PAYJSON,.ERR) S RES("ok")=0,RES("error")=$G(ERR("error"),"license_json_encode_failed") Q:$Q 0 Q
	S HJSON="{""alg"":"""_ALG_""",""typ"":""JWT""}"
	I ALG="HS256" D  Q:$Q +$G(RES("ok")) Q
	. I $G(CONF("efuzy","license","jwtSecret"))="" S RES("ok")=0,RES("error")="license_secret_missing" Q
	. S TOK=$$SIGNJWTHS(HJSON,PAYJSON,$G(CONF("efuzy","license","jwtSecret")),.ERR)
	. I TOK="" S RES("ok")=0,RES("error")=$G(ERR("error"),"license_sign_failed") Q
	. D ISHWROTE(TOK,ALG,.CONF,.SPEC,.PAYARR,.RES)
	S TOK=$$SIGNJWTRS(HJSON,PAYJSON,.CONF,.ERR)
	I TOK="" S RES("ok")=0,RES("error")=$G(ERR("error"),"license_sign_failed") Q:$Q 0 Q
	D ISHWROTE(TOK,ALG,.CONF,.SPEC,.PAYARR,.RES)
	Q:$Q +$G(RES("ok")) Q
	;
ISHWROTE(TOK,ALG,CONF,SPEC,PAYARR,RES)
	N FPATH,DIR,ERR
	S RES("ok")=1
	S RES("token")=TOK
	S RES("edition")=$G(PAYARR("edition"))
	S RES("mode")=$G(PAYARR("mode"))
	S RES("licensee")=$G(PAYARR("licensee"))
	S RES("algorithm")=ALG
	M RES("claims")=PAYARR
	S FPATH=$$NORMPATH($G(SPEC("filePath")))
	I FPATH'="" D
	. S DIR=$$DIRNAME(FPATH)
	. I DIR'="",'$$ENSDIR(DIR,.ERR) S RES("ok")=0,RES("error")=$G(ERR("error"),"license_dir_probe_failed") Q
	. I '$$WRITE1(FPATH,TOK) S RES("ok")=0,RES("error")="license_write_failed" Q
	. S RES("licensePath")=FPATH
	. S RES("written")=1
	Q
	;
VERIFYTOK(CONF,TOK,LIC,CTX,ERR) ; verify license token via MIOAUTHJWT helpers
	N JCONF,REQ,JERR,OK,K,HDR
	K LIC,CTX,ERR
	D CFG(.CONF)
	M JCONF("efuzy","license")=CONF("efuzy","license")
	S JCONF("efuzy","rootDir")=$G(CONF("efuzy","rootDir"))
	S JCONF("auth","jwt","hmacSecret")=$G(CONF("efuzy","license","jwtSecret"))
	S JCONF("auth","jwt","issuer")=$G(CONF("efuzy","license","jwtIssuer"))
	S JCONF("auth","jwt","audience")=$G(CONF("efuzy","license","jwtAudience"))
	S JCONF("auth","jwt","clockSkewSeconds")=+$G(CONF("efuzy","license","jwtClockSkewSeconds"),60)
	S JCONF("auth","jwt","rs256Verify")="RSVFY^EFUZYLIC"
	S REQ("hdr","authorization")="Bearer "_$G(TOK)
	S OK=$$VERIFY^MIOAUTHJWT(.JCONF,.REQ,.CTX,.JERR)
	I 'OK D MAPJWTERR(.JERR,.ERR) Q:$Q 0 Q
	S K=""
	F  S K=$O(CTX("auth","claim",K)) Q:K=""  S LIC(K)=$G(CTX("auth","claim",K))
	D PARSEHDR(TOK,.HDR)
	I $G(HDR("alg"))'="" S LIC("_alg")=$G(HDR("alg"))
	I $G(LIC("product"))="" S LIC("product")=$G(CONF("efuzy","license","product"),"efuzy")
	Q:$Q 1 Q
	;
RSVFY(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR) ; RS256 verifier callback for MIOAUTHJWT
	N PUB,SSL,TMP,DFILE,SFILE,BFILE,CMD,RC,X,S64,B64
	K ERR
	S PUB=$$PUBKEY(.CONF)
	I PUB="" S ERR("routine")="EFUZYLIC",ERR("error")="license_public_key_missing" Q 0
	I '$$FEX(PUB) S ERR("routine")="EFUZYLIC",ERR("error")="license_public_key_missing" Q 0
	S SSL=$$OPENSSL(.CONF)
	I SSL="" S ERR("routine")="EFUZYLIC",ERR("error")="license_openssl_missing" Q 0
	S TMP=$$TMPDIR(.CONF)
	I '$$ENSDIR(TMP,.ERR) Q 0
	S DFILE=$$TMPFILE(TMP,"jwtv",".txt")
	S BFILE=$$TMPFILE(TMP,"jwts",".b64")
	S SFILE=$$TMPFILE(TMP,"jwts",".bin")
	S S64=$$B64EURL^MIOAUTHJWT($G(SIGBIN))
	S B64=$$URL2B64(S64)
	I '$$WRITEBIN(DFILE,$G(DATA),0) S ERR("routine")="EFUZYLIC",ERR("error")="license_tmp_write_failed" Q 0
	I '$$WRITEBIN(BFILE,B64,0) D  Q 0
	. S ERR("routine")="EFUZYLIC",ERR("error")="license_tmp_write_failed"
	. S X=$$RMFILE(DFILE)
	S CMD=$$QSH(SSL)_" base64 -d -A -in "_$$QSH(BFILE)_" -out "_$$QSH(SFILE)_" >/dev/null 2>&1"
	S RC=$$RUNCMD(CMD)
	I RC'=0 D  Q 0
	. S ERR("routine")="EFUZYLIC",ERR("error")="license_signature_decode_failed"
	. S X=$$RMFILE(DFILE),X=$$RMFILE(BFILE),X=$$RMFILE(SFILE)
	S CMD=$$QSH(SSL)_" dgst -sha256 -verify "_$$QSH(PUB)_" -signature "_$$QSH(SFILE)_" "_$$QSH(DFILE)_" >/dev/null 2>&1"
	S RC=$$RUNCMD(CMD)
	S X=$$RMFILE(DFILE),X=$$RMFILE(BFILE),X=$$RMFILE(SFILE)
	I RC'=0 S ERR("routine")="EFUZYLIC",ERR("error")="jwt_bad_signature" Q 0
	Q 1
	;
SIGNJWTRS(HJSON,PJSON,CONF,ERR) ; sign jwt with RS256 private key
	N H64,P64,DATA,PRIV,SSL,TMP,DFILE,SFILE,BFILE,CMD,RC,SIGB64,SIG64,X
	K ERR
	S H64=$$B64EURL^MIOAUTHJWT($G(HJSON))
	S P64=$$B64EURL^MIOAUTHJWT($G(PJSON))
	S DATA=H64_"."_P64
	S PRIV=$$PRIVKEY(.CONF)
	I PRIV="" S ERR("routine")="EFUZYLIC",ERR("error")="license_private_key_missing" Q ""
	I '$$FEX(PRIV) S ERR("routine")="EFUZYLIC",ERR("error")="license_private_key_missing" Q ""
	S SSL=$$OPENSSL(.CONF)
	I SSL="" S ERR("routine")="EFUZYLIC",ERR("error")="license_openssl_missing" Q ""
	S TMP=$$TMPDIR(.CONF)
	I '$$ENSDIR(TMP,.ERR) Q ""
	S DFILE=$$TMPFILE(TMP,"jwti",".txt")
	S SFILE=$$TMPFILE(TMP,"jwto",".bin")
	S BFILE=$$TMPFILE(TMP,"jwto",".b64")
	I '$$WRITEBIN(DFILE,DATA,0) S ERR("routine")="EFUZYLIC",ERR("error")="license_tmp_write_failed" Q ""
	S CMD=$$QSH(SSL)_" dgst -sha256 -sign "_$$QSH(PRIV)_" -out "_$$QSH(SFILE)_" "_$$QSH(DFILE)_" >/dev/null 2>&1"
	S RC=$$RUNCMD(CMD)
	I RC'=0 D  Q ""
	. S ERR("routine")="EFUZYLIC",ERR("error")="license_sign_failed"
	. S X=$$RMFILE(DFILE),X=$$RMFILE(SFILE),X=$$RMFILE(BFILE)
	S CMD=$$QSH(SSL)_" base64 -A -in "_$$QSH(SFILE)_" -out "_$$QSH(BFILE)_" >/dev/null 2>&1"
	S RC=$$RUNCMD(CMD)
	I RC'=0 D  Q ""
	. S ERR("routine")="EFUZYLIC",ERR("error")="license_signature_encode_failed"
	. S X=$$RMFILE(DFILE),X=$$RMFILE(SFILE),X=$$RMFILE(BFILE)
	I '$$READ1(BFILE,.SIGB64) D  Q ""
	. S ERR("routine")="EFUZYLIC",ERR("error")="license_signature_read_failed"
	. S X=$$RMFILE(DFILE),X=$$RMFILE(SFILE),X=$$RMFILE(BFILE)
	S SIG64=$$B642URL($$TRIM($G(SIGB64)))
	S X=$$RMFILE(DFILE),X=$$RMFILE(SFILE),X=$$RMFILE(BFILE)
	Q DATA_"."_SIG64
	;
ENSUREID(CONF,RES) ; create local install id if missing
	N PATH,ID,ERR,DIR
	K RES
	D CFG(.CONF)
	S PATH=$$IDPATH(.CONF)
	S RES("routine")="EFUZYLIC"
	S RES("installIdPath")=PATH
	I PATH="" S RES("ok")=0,RES("error")="install_id_path_missing" Q:$Q 0 Q
	S DIR=$$DIRNAME(PATH)
	I DIR'="",'$$ENSDIR(DIR,.ERR) S RES("ok")=0,RES("error")=$G(ERR("error"),"install_id_dir_failed") Q:$Q 0 Q
	I $$FEX(PATH) D  Q:$Q +$G(RES("ok")) Q
	. I '$$READ1(PATH,.ID) S RES("ok")=0,RES("error")="install_id_read_failed" Q
	. S ID=$$TRIM(ID)
	. I ID="" S RES("ok")=0,RES("error")="install_id_empty" Q
	. S RES("ok")=1
	. S RES("installId")=ID
	. S RES("status")="existing"
	S ID=$$NEWID()
	I '$$WRITE1(PATH,ID) S RES("ok")=0,RES("error")="install_id_write_failed" Q:$Q 0 Q
	S RES("ok")=1
	S RES("installId")=ID
	S RES("status")="created"
	Q:$Q 1 Q
	;
READID(CONF,RES) ; read install id without creating state
	N PATH,ID
	K RES
	D CFG(.CONF)
	S PATH=$$IDPATH(.CONF)
	S RES("routine")="EFUZYLIC"
	S RES("installIdPath")=PATH
	I PATH="" S RES("ok")=0,RES("error")="install_id_path_missing" Q:$Q 0 Q
	I '$$FEX(PATH) S RES("ok")=0,RES("status")="missing",RES("error")="install_id_missing" Q:$Q 0 Q
	I '$$READ1(PATH,.ID) S RES("ok")=0,RES("error")="install_id_read_failed" Q:$Q 0 Q
	S ID=$$TRIM(ID)
	I ID="" S RES("ok")=0,RES("error")="install_id_empty" Q:$Q 0 Q
	S RES("ok")=1
	S RES("installId")=ID
	S RES("status")="present"
	Q:$Q 1 Q
	;
READTOK(PATH,TOK) ; read raw jwt token or token=<jwt> format
	N DEV,OLDIO,DONE,LINE
	S TOK="",DEV=$G(PATH),OLDIO=$IO,DONE=0
	O DEV:(READONLY:STREAM):1 E  Q
	U DEV
	F  Q:DONE!(TOK'="")  D
	. D READROW(.LINE,.DONE)
	. I DONE Q
	. S LINE=$$TRIM($G(LINE))
	. I LINE="" Q
	. I $E(LINE)="#" Q
	. I $E(LINE)=";" Q
	. I $$LC($P(LINE,"=",1))="token" S TOK=$$TRIM($P(LINE,"=",2,999)) Q
	. I $$LC($P(LINE,"=",1))="jwt" S TOK=$$TRIM($P(LINE,"=",2,999)) Q
	. I LINE[".",$L(LINE,".")=3,LINE'["=" S TOK=LINE Q
	. S DONE=1
	C DEV U OLDIO
	Q
	;
LOAD(PATH,LIC,ERR) ; load simple key=value legacy license file
	N DEV,OLDIO,DONE,LINE,KEY,VAL,FOUND
	K LIC,ERR
	S DEV=$G(PATH),OLDIO=$IO,DONE=0,FOUND=0
	O DEV:(READONLY:STREAM):1 E  S ERR("error")="license_open_failed" Q:$Q 0 Q
	U DEV
	F  Q:DONE  D
	. D READROW(.LINE,.DONE,.ERR)
	. I DONE Q
	. I $D(ERR) Q
	. S LINE=$$TRIM($G(LINE))
	. I LINE="" Q
	. I $E(LINE)="#" Q
	. I $E(LINE)=";" Q
	. D PARSEKV(LINE,.KEY,.VAL)
	. I KEY="" Q
	. S FOUND=1
	. S LIC(KEY)=VAL
	C DEV U OLDIO
	I $D(ERR) Q:$Q 0 Q
	I 'FOUND S ERR("error")="license_empty" Q:$Q 0 Q
	S LIC("product")=$S($G(LIC("product"))'="":$G(LIC("product")),1:"efuzy")
	Q:$Q 1 Q
	;
PARSEKV(LINE,KEY,VAL)
	N P
	S KEY="",VAL=""
	S P=$F($G(LINE),"=")
	I P'>1 Q
	S KEY=$$LC($$TRIM($E(LINE,1,P-2)))
	S VAL=$$TRIM($E(LINE,P,$L(LINE)))
	Q
	;
READROW(LINE,DONE,ERR)
	N $ETRAP,$ESTACK
	S LINE=""
	S $ETRAP="D RDERR^EFUZYLIC"
	R LINE:1
	S $ETRAP=""
	I '$T D  Q
	. I $ZEOF S DONE=1 Q
	. I $D(ERR) S ERR("error")="license_read_timeout"
	I $ZEOF,LINE="" S DONE=1 Q
	I $E(LINE,$L(LINE))=$C(13) S LINE=$E(LINE,1,$L(LINE)-1)
	Q
	;
RDERR
	I $ZSTATUS["IOEOF" S DONE=1,$ECODE="" Q
	S ERR("error")="license_read_failed",$ECODE="" Q
	;
STAMP(RES)
	K ^MIO("EFUZY","license","last")
	M ^MIO("EFUZY","license","last")=RES
	S ^MIO("EFUZY","license","last","checkedAt")=$$NOWISO^MIOUTIL()
	Q
	;
MAPJWTERR(JERR,ERR)
	K ERR
	S ERR("routine")="EFUZYLIC"
	S ERR("jwtError")=$G(JERR("error"))
	I $E($G(JERR("error")),1,8)="license_" S ERR("error")=$G(JERR("error")) Q
	I $G(JERR("error"))="jwt_expired" S ERR("error")="license_expired" Q
	I $G(JERR("error"))="jwt_bad_signature" S ERR("error")="license_bad_signature" Q
	I $G(JERR("error"))="jwt_hmac_secret_missing" S ERR("error")="license_secret_missing" Q
	I $G(JERR("error"))="jwt_rs256_no_verifier" S ERR("error")="license_public_key_missing" Q
	I $G(JERR("error"))="jwt_rs256_verifier_exception" S ERR("error")="license_verifier_failed" Q
	I $G(JERR("error"))="jwt_issuer" S ERR("error")="license_issuer_invalid" Q
	I $G(JERR("error"))="jwt_audience" S ERR("error")="license_audience_invalid" Q
	I $G(JERR("error"))="jwt_format" S ERR("error")="license_format_invalid" Q
	I $G(JERR("error"))="jwt_missing" S ERR("error")="license_missing" Q
	S ERR("error")="license_invalid_token"
	Q
	;
SIGNJWTHS(HJSON,PJSON,SECRET,ERR)
	N H64,P64,DATA,SIGBIN
	K ERR
	S H64=$$B64EURL^MIOAUTHJWT($G(HJSON))
	S P64=$$B64EURL^MIOAUTHJWT($G(PJSON))
	S DATA=H64_"."_P64
	S SIGBIN=$$HMACSHA256^MIOAUTHJWT(DATA,$G(SECRET),.ERR)
	I $D(ERR) Q ""
	Q DATA_"."_$$B64EURL^MIOAUTHJWT(SIGBIN)
	;
PARSEHDR(TOK,HDR)
	N H64,HJSON,OK,ERR
	K HDR
	S H64=$P($G(TOK),".",1)
	I H64="" Q
	S HJSON=$$BIN2STR^MIOAUTHJWT($$B64DURL^MIOAUTHJWT(H64,.ERR))
	I $D(ERR) Q
	S OK=$$DECODE^MIOJSON(HJSON,.HDR,.ERR)
	Q
	;
ENCJSON(IN,OUT,ERR)
	N TMP,JSON,IDX
	K ERR
	K TMP,JSON
	M TMP=IN
	D ENCODE^MIOJSON2($NA(TMP),$NA(JSON),$NA(ERR))
	I $D(ERR(0)) D  Q 0
	. N MSG S MSG=$G(ERR(1))
	. K ERR S ERR("error")=$S(MSG'="":MSG,1:"license_json_encode_failed")
	S OUT="",IDX=0
	F  S IDX=$O(JSON(IDX)) Q:'IDX  S OUT=OUT_$G(JSON(IDX))
	Q 1
	;
LICPATH(CONF)
	D CFG(.CONF)
	Q $$NORMPATH($G(CONF("efuzy","license","filePath")))
	;
IDPATH(CONF)
	D CFG(.CONF)
	Q $$NORMPATH($G(CONF("efuzy","license","installIdPath")))
	;
MODE(X)
	N M
	S M=$$LC($G(X))
	I M="evaluation" Q M
	I M="paid" Q M
	Q "demo"
	;
ALG(X)
	N A
	S A=$$LC($G(X))
	I A="hs256" Q "HS256"
	Q "RS256"
	;
EDITION(X,MODE)
	N E,M
	S E=$$LC($G(X)),M=$$MODE($G(MODE))
	I E'="" Q E
	I M="evaluation" Q "evaluation"
	I M="paid" Q "standard"
	Q "demo"
	;
HOSTSTGY(X)
	N H
	S H=$$LC($G(X))
	I H="name" Q H
	I H="hostname" Q "name"
	Q "none"
	;
HOSTID(CONF)
	N H
	S H=$G(CONF("efuzy","license","hostId"))
	I H="" S H=$ZTRNLNM("EFUZY_HOST_ID")
	I H="" S H=$ZTRNLNM("HOSTNAME")
	I H="" S H="unknown"
	Q H
	;
PUBKEY(CONF)
	N P
	S P=$G(CONF("efuzy","license","rs256PublicKeyPath"))
	I P="" S P=$ZTRNLNM("EFUZY_LICENSE_PUBLIC_KEY")
	Q $$NORMPATH(P)
	;
PRIVKEY(CONF)
	N P
	S P=$G(CONF("efuzy","license","rs256PrivateKeyPath"))
	I P="" S P=$ZTRNLNM("EFUZY_LICENSE_PRIVATE_KEY")
	Q $$NORMPATH(P)
	;
OPENSSL(CONF)
	N X
	S X=$G(CONF("efuzy","license","opensslBin"))
	I X="" S X=$ZTRNLNM("EFUZY_OPENSSL_BIN")
	I X="" S X="openssl"
	Q X
	;
ISPAIDED(X)
	N E
	S E=$$LC($G(X))
	Q $S(E="standard":1,E="professional":1,E="enterprise":1,E="source":1,E="source_license":1,1:0)
	;
TODAY()
	Q $E($$NOWISO^MIOUTIL(),1,10)
	;
DATE10(X)
	N D
	S D=$E($G(X),1,10)
	I D?4N1"-"2N1"-"2N Q D
	Q ""
	;
DATECMP(A,B) ; compare yyyy-mm-dd values safely
	N AK,BK
	S AK=$$DATEKEY($G(A))
	S BK=$$DATEKEY($G(B))
	I AK="",BK="" Q 0
	I AK="" Q -1
	I BK="" Q 1
	I AK<BK Q -1
	I AK>BK Q 1
	Q 0
	;
DATEKEY(X)
	N D
	S D=$$DATE10($G(X))
	I D="" Q ""
	Q +($TR(D,"-",""))
	;
DATEPLUS(DAYS)
	Q $ZDATE(($P($H,",",1)+$G(DAYS)),"YYYY-MM-DD")
	;
EPOCH10(DATE,ENDDAY) ; yyyy-mm-dd -> MIOAUTHJWT-style epoch seconds ($H origin)
	N Y,M,D,A,Y2,M2,JD,HDAY,SEC
	S DATE=$$DATE10($G(DATE)) I DATE="" Q 0
	S Y=+$P(DATE,"-",1),M=+$P(DATE,"-",2),D=+$P(DATE,"-",3)
	S A=(14-M)\12
	S Y2=Y+4800-A
	S M2=M+(12*A)-3
	S JD=D+((153*M2+2)\5)+(365*Y2)+(Y2\4)-(Y2\100)+(Y2\400)-32045
	S HDAY=JD-2393471
	S SEC=HDAY*86400
	I +$G(ENDDAY) S SEC=SEC+86399
	Q SEC
	;
EPOCH2DATE(SEC) ; MIOAUTHJWT-style epoch seconds ($H origin) -> yyyy-mm-dd
	N DAYS,JD,L,N,I,J,D,M,Y
	S DAYS=(+$G(SEC)\86400)
	S JD=DAYS+2393471
	S L=JD+68569
	S N=(4*L)\146097
	S L=L-((146097*N+3)\4)
	S I=(4000*(L+1))\1461001
	S L=L-((1461*I)\4)+31
	S J=(80*L)\2447
	S D=L-((2447*J)\80)
	S L=J\11
	S M=J+2-(12*L)
	S Y=100*(N-49)+I+L
	Q $$PAD4(Y)_"-"_$$PAD2(M)_"-"_$$PAD2(D)
	;
PAD2(N)
	Q $S(+$G(N)<10:"0"_+$G(N),1:+$G(N))
	;
PAD4(N)
	N X
	S X=+$G(N)
	I X<10 Q "000"_X
	I X<100 Q "00"_X
	I X<1000 Q "0"_X
	Q X
	;
B642URL(X)
	N Y
	S Y=$TR($G(X),"+/","-_")
	F  Q:$E(Y,$L(Y))'="="  S Y=$E(Y,1,$L(Y)-1) Q:Y=""
	Q Y
	;
URL2B64(X)
	N Y,PAD
	S Y=$TR($G(X),"-_","+/")
	S PAD=$L(Y)#4
	I PAD=2 S Y=Y_"=="
	I PAD=3 S Y=Y_"="
	Q Y
	;
NEWID()
	N ID
	S ID=$$UUID^MIOUTIL()
	I ID="" S ID="efuzy-"_$J_"-"_$TR($$NOWISO^MIOUTIL(),"-:TZ","")
	Q ID
	;
READ1(PATH,OUT)
	N DEV,LINE
	S OUT="",DEV=$G(PATH)
	O DEV:(READONLY:STREAM):1 E  Q 0
	U DEV
	R LINE:1
	C DEV
	S OUT=$G(LINE)
	I $E(OUT,$L(OUT))=$C(13) S OUT=$E(OUT,1,$L(OUT)-1)
	Q 1
	;
READBIN(PATH,OUT)
	N DEV,CH,DONE
	S OUT="",DEV=$G(PATH),DONE=0
	O DEV:(READONLY:STREAM:NOWRAP):1 E  Q 0
	U DEV
	F  Q:DONE  D
	. R CH#4096:1
	. I '$T S DONE=1 Q
	. S OUT=OUT_$G(CH)
	. I $ZEOF S DONE=1
	C DEV
	Q 1
	;
WRITE1(PATH,TXT)
	N DEV
	S DEV=$G(PATH)
	O DEV:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1 E  Q 0
	U DEV W $G(TXT),!
	C DEV
	Q 1
	;
WRITEBIN(PATH,TXT,ADDNL)
	N DEV
	S DEV=$G(PATH)
	O DEV:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1 E  Q 0
	U DEV W $G(TXT)
	I +$G(ADDNL) W !
	C DEV
	Q 1
	;
ENSDIR(PATH,ERR)
	N CMD,PROBE
	K ERR
	I $G(PATH)="" Q 1
	S CMD="mkdir -p "_$$QSH($G(PATH))_" >/dev/null 2>&1"
	I $$RUNCMD(CMD)'=0 S ERR("error")="license_dir_probe_failed" Q 0
	S PROBE=$G(PATH)_"/.efuzy_lic_probe"
	O PROBE:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1 E  D  Q 0
	. S ERR("error")="license_dir_probe_failed"
	U PROBE W "ok" C PROBE
	D RMFILE(PROBE)
	Q 1
	;
TMPDIR(CONF)
	N R
	S R=$$NORMPATH($G(CONF("efuzy","rootDir")))
	I R="" S R="tmp/efuzy"
	Q R_"/tmp"
	;
TMPFILE(DIR,PFX,EXT)
	Q $$NORMPATH($G(DIR))_"/."_$G(PFX)_"_"_$J_"_"_$P($H,",",2)_"_"_$R(1000000)_$G(EXT)
	;
RMFILE(PATH)
	N $ETRAP,$ESTACK,CMD
	I $G(PATH)="" Q 1
	I '$$FEX($G(PATH)) Q 1
	S $ETRAP="SET $ECODE="""" QUIT:$Q 0  Q"
	O PATH:(readonly):1 E  G RMFILEZ
	C PATH:DELETE
	I '$$FEX($G(PATH)) Q:$Q 1  Q
RMFILEZ S CMD="rm -f "_$$QSH($G(PATH))_" >/dev/null 2>&1"
	S CMD=$$RUNCMD(CMD)
	Q:$Q $S($$FEX($G(PATH)):0,1:1)
	Q
	;
RUNCMD(CMD)
	ZSY $G(CMD)
	Q +$ZSYSTEM
	;
QSH(X)
	Q "'"_$TR($G(X),"'","'""'""'")_"'"
	;
FEX(PATH)
	Q $S($ZSEARCH($G(PATH))'="":1,1:0)
	;
DIRNAME(PATH)
	N I,P
	S P=$$NORMPATH($G(PATH))
	F I=$L(P):-1:1 I $E(P,I)="/" Q
	I I<1 Q ""
	Q $E(P,1,I-1)
	;
NORMPATH(PATH)
	N P
	S P=$G(PATH)
	I $E(P,1,2)="./" S P=$E(P,3,$L(P))
	F  Q:$E(P,$L(P))'="/"  S P=$E(P,1,$L(P)-1) Q:P=""
	Q P
	;
TRIM(X)
	Q $$TRIM^MIOUTIL($G(X))
	;
LC(X)
	Q $$LC^MIOUTIL($G(X))
	;
	;