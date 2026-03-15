EFUZYTESTU ; efuzy test helpers
	;
	Q
	;
RESET(ROOT)
	K ^MIO("EFUZY")
	I $G(ROOT)'="" D RMDIR(ROOT)
	Q
	;
TMPROOT(NAME)
	Q "tmp/efuzy-test-"_$J_"-"_$TR($G(NAME)," /","--")
	;
SETCONF(CONF,ROOT)
	N KROOT,OK
	K CONF
	S CONF("efuzy","rootDir")=$G(ROOT)
	S CONF("efuzy","license","jwtAlgorithm")="RS256"
	S CONF("efuzy","license","jwtIssuer")="efuzy-license"
	S CONF("efuzy","license","jwtAudience")="efuzy"
	S CONF("efuzy","license","opensslBin")="openssl"
	S KROOT=$G(ROOT)_"/license/keys"
	D MKDIR(KROOT)
	D WRITEFILE(KROOT_"/efuzy_license_private.pem",$$TESTPRIV(),.OK)
	D WRITEFILE(KROOT_"/efuzy_license_public.pem",$$TESTPUB(),.OK)
	S CONF("efuzy","license","rs256PrivateKeyPath")=KROOT_"/efuzy_license_private.pem"
	S CONF("efuzy","license","rs256PublicKeyPath")=KROOT_"/efuzy_license_public.pem"
	Q
	;
MKDIR(PATH) ; mkdir -p PATH (best-effort)
	N CMD
	S CMD="mkdir -p "_$G(PATH)
	ZSY CMD
	Q
	;
RMDIR(PATH) ; rm -rf PATH (best-effort)
	N CMD
	S CMD="rm -rf "_$G(PATH)
	ZSY CMD
	Q
	;
WRITEFILE(PATH,TXT,OK)
	K OK
	S OK=0
	O PATH:(newversion:stream:nowrap):1 E  Q
	U PATH W $G(TXT)
	C PATH
	S OK=1
	Q
	;
READFILE(PATH,OUT)
	N CH
	K OUT
	O PATH:(readonly:stream:nowrap):1 E  Q:$Q 0  Q
	U PATH
	F  R CH#4096 S OUT=$G(OUT)_CH Q:$ZEOF
	C PATH
	Q:$Q 1
	Q
	;
EXISTS(PATH)
	Q $S($ZSEARCH($G(PATH))'="":1,1:0)
	;
SAMPLE837(PATH,OK)
	N X
	S X="ISA*00*          *00*          *ZZ*SENDERID       *ZZ*RECEIVERID     *060101*1253*^*00501*000000905*0*T*:~"
	S X=X_"GS*HC*SENDER*RECEIVER*20060101*1253*1*X*005010X222A1~"
	S X=X_"ST*837*0001*005010X222A1~"
	S X=X_"BHT*0019*00*0123*20060301*1023*CH~"
	S X=X_"NM1*41*2*SUBMITTER*****46*12345~"
	S X=X_"NM1*40*2*RECEIVER*****46*54321~"
	S X=X_"HL*1**20*1~"
	S X=X_"NM1*85*2*BILLINGPROV*****XX*9876543210~"
	S X=X_"NM1*IL*1*DOE*JOHN****MI*ABC123~"
	S X=X_"NM1*QC*1*DOE*JANE~"
	S X=X_"CLM*CLM0001*100***11:B:1*Y*A*Y*Y~"
	S X=X_"DTP*434*D8*20260301~"
	S X=X_"REF*D9*REF0001~"
	S X=X_"LX*1~"
	S X=X_"SV1*HC:99213*75*UN*1***1~"
	S X=X_"DTP*472*D8*20260301~"
	S X=X_"SE*13*0001~"
	S X=X_"GE*1*1~"
	S X=X_"IEA*1*000000905~"
	D WRITEFILE($G(PATH),X,.OK)
	Q
	;
WRLIC(PATH,EDITION,INSTALLID,HOST,EXPIRES,OK) ; legacy compatibility helper
	N TXT,MAINT
	S MAINT=$$DATEPLUS(365)
	S TXT="product=efuzy"_$C(10)
	S TXT=TXT_"edition="_$S($G(EDITION)'="":$G(EDITION),1:"standard")_$C(10)
	S TXT=TXT_"licensee=EFUZY Test"_$C(10)
	I $G(INSTALLID)'="" S TXT=TXT_"install_id="_$G(INSTALLID)_$C(10)
	I $G(HOST)'="" S TXT=TXT_"host="_$G(HOST)_$C(10)
	I $G(EXPIRES)'="" S TXT=TXT_"expires_at="_$G(EXPIRES)_$C(10)
	S TXT=TXT_"maintenance_until="_MAINT_$C(10)
	D WRITEFILE(PATH,TXT,.OK)
	Q
	;
WRJWTLIC(CONF,PATH,MODE,EDITION,INSTALLID,HOST,EXPIRES,OK)
	N SPEC,RES
	K OK,SPEC,RES
	S SPEC("mode")=$S($G(MODE)'="":$G(MODE),1:"paid")
	S SPEC("edition")=$S($G(EDITION)'="":$G(EDITION),1:"standard")
	S SPEC("licensee")="EFUZY Test"
	S SPEC("filePath")=$G(PATH)
	I $G(INSTALLID)'="" S SPEC("install_id")=$G(INSTALLID)
	I $G(HOST)'="" S SPEC("host")=$G(HOST)
	I $G(EXPIRES)'="" S SPEC("expires_at")=$G(EXPIRES)
	S OK=$$ISSUE^EFUZYLIC(.CONF,.SPEC,.RES)
	Q
	;
TAMPERJWT(PATH,OK)
	N TOK,H,P,S,L,POS,C
	S OK=0
	I '$$READFILE(PATH,.TOK) Q
	S TOK=$$TRIM^MIOUTIL($G(TOK))
	S H=$P(TOK,".",1),P=$P(TOK,".",2),S=$P(TOK,".",3)
	I H=""!(P="")!(S="") Q
	S L=$L(S),POS=$S(L>8:8,L>1:1,1:0)
	I POS'>0 Q
	S C=$E(S,POS)
	S C=$S(C="A":"B",C="B":"C",C="C":"D",C="D":"E",C="a":"b",C="b":"c",C="c":"d",C="d":"e",1:"A")
	S S=$E(S,1,POS-1)_C_$E(S,POS+1,L)
	D WRITEFILE(PATH,H_"."_P_"."_S,.OK)
	Q
	;
DATEPLUS(DAYS)
	Q $ZDATE(($P($H,",",1)+$G(DAYS)),"YYYY-MM-DD")
	;
TESTPRIV()
	Q "-----BEGIN PRIVATE KEY-----"_$C(10)_"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAOeZBa9QWBW0FUCU"_$C(10)_"VMamM4pBxsiyDeGQGjkx3uBvoiFrpINe27ajIANGRkopRVrUkcYybZvTt1xM4h3E"_$C(10)_"AF+ukHEcTKacbT1Coyai6CLRDHI3B4SrBd0/EZOxhuq7mZk8q5HgCHGPYHsKPqQG"_$C(10)_"U9Sai3A3mbkDoIbhBYiEnXV2JagNAgMBAAECgYEAmvvjOwPoPnXptvLMnLdCTGZi"_$C(10)_"MZI+CdGWSuodvVHXTMgtKqDDJcCaPra7eQuPVw5jkx/SC/KthP4KX2L34Q//pfwW"_$C(10)_"Z8WTCb0V/KGEsr/T/jiIqGoqdyqITkFEV5LnoBj3s1ZTdSg6/DuN/o9r8eH8jKQH"_$C(10)_"GV2BHeRspCx/4kxZNwECQQD4TP5mTpsGRGCeJ06MGvif3htgDr3EdJ1TxapXiGbR"_$C(10)_"IqrZnrTMhxVA+9c/beXWWY7hs1DeCihnBT02gB+rYpnNAkEA7sdwtj2NIkAkTBxK"_$C(10)_"OrBa+7ObLxr0jvJv4Xd9BRtybUOFMDnLQy8bjstw7slMtzvdKhl8RpCBmHZOZGUI"_$C(10)_"t4gHQQJBALVZtq0OWFeZdV/NoabexBwvYpsj6SIlcgsPYbyQ2VeCFHrhWXfQaYuO"_$C(10)_"5MVlBOsrehoKl9O0Y5Hq16yIo5jPaTkCQDkjyuohcpumo8j+4BiJSUyAX3t3RNzM"_$C(10)_"UU+wK1/EgK57AO1Ydza9mCeksYLC8zPKBJPlg2LTg9+7N+k4cEyTJcECQQCbv2dv"_$C(10)_"vqFwH1V1gPofuyjQFebP31q4EH9qC50b9H+hHubY58vOE18WTqbhEdBQySXXFn2Q"_$C(10)_"2kvsnlOnVFQU8yo/"_$C(10)_"-----END PRIVATE KEY-----"_$C(10)_""
	;
TESTPUB()
	Q "-----BEGIN PUBLIC KEY-----"_$C(10)_"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDnmQWvUFgVtBVAlFTGpjOKQcbI"_$C(10)_"sg3hkBo5Md7gb6Iha6SDXtu2oyADRkZKKUVa1JHGMm2b07dcTOIdxABfrpBxHEym"_$C(10)_"nG09QqMmougi0QxyNweEqwXdPxGTsYbqu5mZPKuR4Ahxj2B7Cj6kBlPUmotwN5m5"_$C(10)_"A6CG4QWIhJ11diWoDQIDAQAB"_$C(10)_"-----END PUBLIC KEY-----"_$C(10)_""
	;
	;