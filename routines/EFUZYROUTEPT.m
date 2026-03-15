EFUZYROUTEPT ; efuzy route/controller helper tests
	; Quiet on success.;
	;
	D START Q
	;
START ; default entry
	N FAIL
	S FAIL=0
	D ALL(.FAIL)
	I 'FAIL W !,"OK - EFUZYROUTEPT"
	Q
	;
ALL(FAIL)
	D T800(.FAIL)
	D T810(.FAIL)
	D T820(.FAIL)
	Q
	;
T800(FAIL) ; route registration wires expected handlers and auth metadata
	N CONF
	K ^MIO("ROUTE")
	D REG^EFUZY(.CONF)
	D EQ(.FAIL,"[T800][workspace route]",$G(^MIO("ROUTE","RAW","GET","/efuzy/workspace")),"WORKSPACE^EFUZY")
	D EQ(.FAIL,"[T800][preview route]",$G(^MIO("ROUTE","RAW","GET","/efuzy/preview/:jobId")),"PREVIEW^EFUZY")
	D EQ(.FAIL,"[T800][upload route]",$G(^MIO("ROUTE","RAW","POST","/efuzy/api/upload")),"APIUPLOAD^EFUZY")
	D EQ(.FAIL,"[T800][retry route]",$G(^MIO("ROUTE","RAW","POST","/efuzy/api/job/retry")),"APIRETRY^EFUZY")
	D EQ(.FAIL,"[T800][auth required]",+$G(^MIO("ROUTE","META","GET","/efuzy/workspace","authRequired")),0)
	D EQ(.FAIL,"[T800][roles]",$G(^MIO("ROUTE","META","GET","/efuzy/workspace","roles")),"operator,admin")
	Q
	;
T810(FAIL) ; parseform decodes urlencoded fields
	N REQ,OUT
	K REQ,OUT
	S REQ("body")="jobId=7&profileId=2&name=Claim+Summary&rule=%7B%7Bsource_base%7D%7D-test.csv"
	D PARSEFORM^EFUZY(.REQ,.OUT)
	D EQ(.FAIL,"[T810][jobid]",$G(OUT("jobId")),"7")
	D EQ(.FAIL,"[T810][profileid]",$G(OUT("profileId")),"2")
	D EQ(.FAIL,"[T810][plus decode]",$G(OUT("name")),"Claim Summary")
	D EQ(.FAIL,"[T810][percent decode]",$G(OUT("rule")),"{{source_base}}-test.csv")
	Q
	;
T820(FAIL) ; parseform preserves raw body fallback at minimum
	N REQ,OUT
	K REQ,OUT
	S REQ("body")="id=9"
	D PARSEFORM^EFUZY(.REQ,.OUT)
	D EQ(.FAIL,"[T820][raw or decoded]",($G(OUT("id"))="9")!($G(OUT("raw"))="id=9"),1)
	Q
	;
EQ(FAIL,LABEL,GOT,EXP)
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
	; S REQ("body")="jobId=7&profileId=2&name=Claim+Summary&rule=%7B%7Bsource_base%7D%7D-test.csv"
	; D PARSEFORM^EFUZY(.REQ,.OUT)
	; ZWR OUT 