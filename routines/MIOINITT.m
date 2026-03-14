MIOINITT ; Bootstrap/auth integration tests
	;
	; Run:
	;   YDB>ZL "MIOJSON.m","MIOJSON1.m","MIOJSON2.m","MIOCONF.m","MIOHTTP.m","MIOROUTE.m","MIOMW.m","MIOAUTH.m","MIOAUTHZ.m","MIOMET.m","MIOUTIL.m","MIOTASSERT.m","EFUZY.m","MIO.m","MIOINITT.m"
	;   YDB>D ^MIOINITT
	;
	NEW $ET SET $ET="DO STERR^MIOINITT"
	DO T001
	DO T002
	DO T003
	QUIT
	;
STERR
	USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	KILL ^MIO("CONF")
	QUIT
	;
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT
	;
SETUP(CONF)
	DO RESET
	DO BOOTCONF^MIO(.CONF)
	; Keep auth deterministic for the integration checks.
	SET CONF("auth","mode")="api_key"
	SET CONF("auth","apiKey","value")="secret"
	DO INIT^MIOROUTE
	DO REG^EFUZY(.CONF)
	DO COMPILE^MIOROUTE
	DO ENSURE^MIOMW(.CONF)
	QUIT
	;
T001 ; bootstrap preserves route auth mode from config
	NEW CONF
	DO RESET
	DO BOOTCONF^MIO(.CONF)
	DO EQ^MIOTASSERT($GET(CONF("auth","protectMode")),"route","[T001][local protectMode]")
	DO EQ^MIOTASSERT($GET(^MIO("CONF","auth","protectMode")),"route","[T001][global protectMode]")
	QUIT
	;
T002 ; efuzy shell route is denied without auth
	NEW CONF,REQ,CTX,DEV,OUT,OP
	DO SETUP(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/efuzy"
	SET CTX("request_id")="mioinit002"
	SET OP="tmp/mio_init_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($GET(CTX("status")),401,"[T002][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["api_key_missing":1,1:0),1,"[T002][reason]")
	QUIT
	;
T003 ; efuzy api route is denied without auth
	NEW CONF,REQ,CTX,DEV,OUT,OP
	DO SETUP(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/efuzy/api/jobs"
	SET CTX("request_id")="mioinit003"
	SET OP="tmp/mio_init_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($GET(CTX("status")),401,"[T003][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["api_key_missing":1,1:0),1,"[T003][reason]")
	QUIT
