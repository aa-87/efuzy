MIO ; Routine for the MIO web server package.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Routine for the MIO web server package.;
;
; Responsibilities
; - Provide routine functionality.;
;
; Entry Points
; - start
; - stop
; - version
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
start ; start^MIO
	NEW CONF
	DO INIT(.CONF)
	DO START^MIOD(.CONF)
	QUIT
	;
BOOTCONF(CONF)
	NEW PATH
	KILL CONF
	SET PATH=$$GETCONF^MIOCONF()
	DO LOAD^MIOCONF(PATH,.CONF)
	;
	; Apply defaults only when missing.
	IF $GET(CONF("auth","enabled"))="" SET CONF("auth","enabled")=1
	IF $GET(CONF("auth","protectMode"))="" SET CONF("auth","protectMode")="prefix"
	IF '$DATA(CONF("auth","protect","prefix")) DO
	. SET CONF("auth","protect","prefix",1)="/api/"
	. SET CONF("auth","protect","prefix",2)="/admin/"
	. SET CONF("auth","protect","prefix",3)="/metrics"
	. SET CONF("auth","protect","prefix",4)="/debug/"
	IF $GET(CONF("server","errors","enabled"))="" SET CONF("server","errors","enabled")=1
	IF $GET(CONF("server","errors","maxEntries"))="" SET CONF("server","errors","maxEntries")=2000
	IF $GET(CONF("server","errors","capture4xx"))="" SET CONF("server","errors","capture4xx")=1
	IF $GET(CONF("server","errors","capture404"))="" SET CONF("server","errors","capture404")=1
	DO SYNCCONF(.CONF)
	QUIT
	;
SYNCCONF(CONF)
	KILL ^MIO("CONF")
	MERGE ^MIO("CONF")=CONF
	QUIT
	;
INIT(CONF)
	DO BOOTCONF(.CONF)
	DO INIT^MIOROUTE
	DO START^MIOTPL(.CONF)
	DO REG^MIODEMO(.CONF)
	DO REG^MIOMIO(.CONF)
	DO REG^MIORP(.CONF)
	DO REG^MIOPUBAPI(.CONF)
	DO REG^MIOPUBADM(.CONF)
	DO REG^MIOREGAPI(.CONF)	
	DO REG^MIOREGADM(.CONF)
	;DO REG^MIOWOW(.CONF)
	;DO REG^MIOAPP(.CONF)
	DO REG^MIOPLGD(.CONF)
	DO REG^MIOSTATIC(.CONF)
	DO REG^MIOHEALTH(.CONF)
	DO REG^MIOERRC(.CONF)
	DO REG^EFUZY(.CONF)
	DO COMPILE^MIOROUTE
	DO SYNCCONF(.CONF)
	DO START^MIOCLEAN(.CONF)
	QUIT
	;
; Entry point
; See docs/routines for details.;
stop ; stop^MIO
	D STOP^MIOD
	SET ^MIO("CTL","STOP")=1
	WRITE "stop requested",!
	QUIT
; Entry point
; See docs/routines for details.;
version ; version^MIO
	WRITE "mws 0.1.0",!
	QUIT
	;
GetRoutineList(routine,result)
	N %ZR K result,%ZR
	do SILENT^%RSEL(routine,"CALL")
	M result=%ZR
	K %ZR
	Q
	;
link
	N R,RTN
	D GetRoutineList("MIO*",.R)
	N A S A="" F  S A=$O(R(A)) Q:A=""  D
	. S RTN=A
	. I $E(RTN)="%" S $E(RTN)="_"
	. W !,"ZL " ZL RTN_".m" W RTN_".m"
	Q	