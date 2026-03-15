FUZROUTET ; FUZ route and controller helper tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - FUZROUTET"
 Q
 ;
ALL(FAIL)
 D T200(.FAIL)
 D T210(.FAIL)
 D T220(.FAIL)
 Q
 ;
T200(FAIL) ; route registration covers public site pages
 N CONF
 K ^MIO("ROUTE")
 D REG^FUZ(.CONF)
 D EQ(.FAIL,"[T200][home]",$G(^MIO("ROUTE","RAW","GET","/")),"HOME^FUZ")
 D EQ(.FAIL,"[T200][guide]",$G(^MIO("ROUTE","RAW","GET","/guide")),"GUIDE^FUZ")
 D EQ(.FAIL,"[T200][manual]",$G(^MIO("ROUTE","RAW","GET","/manual")),"MANUAL^FUZ")
 D EQ(.FAIL,"[T200][services]",$G(^MIO("ROUTE","RAW","GET","/services")),"SERVICES^FUZ")
 D EQ(.FAIL,"[T200][contact post]",$G(^MIO("ROUTE","RAW","POST","/contact")),"CONTACTPOST^FUZ")
 D EQ(.FAIL,"[T200][robots]",$G(^MIO("ROUTE","RAW","GET","/robots.txt")),"ROBOTS^FUZ")
 D EQ(.FAIL,"[T200][sitemap]",$G(^MIO("ROUTE","RAW","GET","/sitemap.xml")),"SITEMAP^FUZ")
 Q
 ;
T210(FAIL) ; public routes stay unauthenticated
 N CONF
 K ^MIO("ROUTE")
 D REG^FUZ(.CONF)
 D EQ(.FAIL,"[T210][home auth]",+$G(^MIO("ROUTE","META","GET","/","authRequired")),0)
 D EQ(.FAIL,"[T210][guide auth]",+$G(^MIO("ROUTE","META","GET","/guide","authRequired")),0)
 D EQ(.FAIL,"[T210][contact auth]",+$G(^MIO("ROUTE","META","POST","/contact","authRequired")),0)
 Q
 ;
T220(FAIL) ; parseform decodes contact bodies
 N REQ,OUT
 S REQ("body")="name=Ahmed&email=ahmed%40example.com&message=Need+demo"
 D PARSEFORM^FUZ(.REQ,.OUT)
 D EQ(.FAIL,"[T220][name]",$G(OUT("name")),"Ahmed")
 D EQ(.FAIL,"[T220][email]",$G(OUT("email")),"ahmed@example.com")
 D EQ(.FAIL,"[T220][message]",$G(OUT("message")),"Need demo")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
