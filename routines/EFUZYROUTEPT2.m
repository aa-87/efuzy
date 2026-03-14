EFUZYROUTEPT2 ; extra efuzy route/controller tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYROUTEPT2"
 Q
 ;
ALL(FAIL)
 D T830(.FAIL)
 D T840(.FAIL)
 D T850(.FAIL)
 Q
 ;
T830(FAIL) ; parseform supports 3-arg style too
 N CONF,REQ,OUT
 K CONF,REQ,OUT
 S REQ("body")="jobId=9&name=Service+Line&rule=%7B%7Bjob_id%7D%7D.csv"
 D PARSEFORM^EFUZY(.CONF,.REQ,.OUT)
 D EQ(.FAIL,"[T830][jobid]",$G(OUT("jobId")),"9")
 D EQ(.FAIL,"[T830][name]",$G(OUT("name")),"Service Line")
 D EQ(.FAIL,"[T830][rule]",$G(OUT("rule")),"{{job_id}}.csv")
 Q
 ;
T840(FAIL) ; blank parseform is harmless
 N REQ,OUT
 K REQ,OUT
 D PARSEFORM^EFUZY(.REQ,.OUT)
 D EQ(.FAIL,"[T840][raw blank or none]",($D(OUT)=0)!($G(OUT("raw"))=""),1)
 Q
 ;
T850(FAIL) ; delete/save routes retain auth metadata
 N CONF
 K ^MIO("ROUTE")
 D REG^EFUZY(.CONF)
 D EQ(.FAIL,"[T850][profile delete route]",$G(^MIO("ROUTE","RAW","POST","/efuzy/api/profile/delete")),"APIPROFD^EFUZY")
 D EQ(.FAIL,"[T850][auto save route]",$G(^MIO("ROUTE","RAW","POST","/efuzy/api/automation/save")),"APIAUTOS^EFUZY")
 D EQ(.FAIL,"[T850][profile delete auth]",+$G(^MIO("ROUTE","META","POST","/efuzy/api/profile/delete","authRequired")),1)
 D EQ(.FAIL,"[T850][auto save roles]",$G(^MIO("ROUTE","META","POST","/efuzy/api/automation/save","roles")),"operator,admin")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
