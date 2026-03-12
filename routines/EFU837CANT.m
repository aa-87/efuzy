EFU837CANT ; efuzy canonical package version/manifest tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFU837CANT"
 Q
 ;
ALL(FAIL) ; full suite
 D T500(.FAIL)
 D T510(.FAIL)
 D T520(.FAIL)
 D T530(.FAIL)
 Q
 ;
T500(FAIL) ; export writes manifest and schema markers
 N PATH,ROOT,OPT,PRES,ERES,BASE,TXT
 S PATH=$$WRFILE($$SAMPLEP())
 S ROOT=$NA(^TMP($J,"EFU837CANT",500))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T500][parse ok]",+$G(PRES("ok")),1)
 S BASE="efu837cant_500_"_$J
 D EXPORT^EFU837CAN(ROOT,BASE,.ERES)
 D EQ(.FAIL,"[T500][export ok]",+$G(ERES("ok")),1)
 D EQ(.FAIL,"[T500][manifest path]",$G(ERES("manifest_path"))'="",1)
 D EQ(.FAIL,"[T500][schema name]",$G(ERES("schema_name")),"EFU837_CANONICAL")
 D EQ(.FAIL,"[T500][schema version]",+$G(ERES("schema_version")),1)
 S TXT=$$READALL($G(ERES("manifest_path")))
 D EQ(.FAIL,"[T500][manifest schema marker]",TXT["schema_name=EFU837_CANONICAL",1)
 D EQ(.FAIL,"[T500][manifest version marker]",TXT["schema_version=1",1)
 K @ROOT Q
 ;
T510(FAIL) ; load manifest-aware package and apply canon meta
 N PATH,SROOT,LROOT,OPT,PRES,ERES,LRES,BASE
 S PATH=$$WRFILE($$SAMPLEI())
 S SROOT=$NA(^TMP($J,"EFU837CANT",510,"SRC"))
 S LROOT=$NA(^TMP($J,"EFU837CANT",510,"LOAD"))
 D PARSE^EFU837P(PATH,SROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T510][parse ok]",+$G(PRES("ok")),1)
 S BASE="efu837cant_510_"_$J
 D EXPORT^EFU837CAN(SROOT,BASE,.ERES)
 D EQ(.FAIL,"[T510][export ok]",+$G(ERES("ok")),1)
 D LOAD^EFU837CAN(BASE,LROOT,.LRES)
 D EQ(.FAIL,"[T510][load ok]",+$G(LRES("ok")),1)
 D EQ(.FAIL,"[T510][manifest present]",+$G(LRES("manifest","present")),1)
 D EQ(.FAIL,"[T510][legacy no]",+$G(@LROOT@("canon","meta","legacy_package")),0)
 D EQ(.FAIL,"[T510][canon schema version]",+$G(@LROOT@("canon","meta","schema_version")),1)
 D EQ(.FAIL,"[T510][claims]",+$G(LRES("claims")),+$G(ERES("claims")))
 D EQ(.FAIL,"[T510][lines]",+$G(LRES("lines")),+$G(ERES("lines")))
 K @SROOT,@LROOT Q
 ;
T520(FAIL) ; legacy manifest-less package still loads
 N PATH,SROOT,LROOT,OPT,PRES,ERES,LRES,BASE1,BASE2,OK
 S PATH=$$WRFILE($$SAMPLED())
 S SROOT=$NA(^TMP($J,"EFU837CANT",520,"SRC"))
 S LROOT=$NA(^TMP($J,"EFU837CANT",520,"LOAD"))
 D PARSE^EFU837P(PATH,SROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T520][parse ok]",+$G(PRES("ok")),1)
 S BASE1="efu837cant_520a_"_$J,BASE2="efu837cant_520b_"_$J
 D EXPORT^EFU837CAN(SROOT,BASE1,.ERES)
 D EQ(.FAIL,"[T520][export ok]",+$G(ERES("ok")),1)
 S OK=$$COPY(BASE1_"-claims.csv",BASE2_"-claims.csv")
 D EQ(.FAIL,"[T520][copy claims]",OK,1)
 S OK=$$COPY(BASE1_"-lines.csv",BASE2_"-lines.csv")
 D EQ(.FAIL,"[T520][copy lines]",OK,1)
 D LOAD^EFU837CAN(BASE2,LROOT,.LRES)
 D EQ(.FAIL,"[T520][load ok]",+$G(LRES("ok")),1)
 D EQ(.FAIL,"[T520][manifest absent]",+$G(LRES("manifest","present")),0)
 D EQ(.FAIL,"[T520][legacy yes]",+$G(@LROOT@("canon","meta","legacy_package")),1)
 D EQ(.FAIL,"[T520][schema default]",+$G(@LROOT@("canon","meta","schema_version")),1)
 K @SROOT,@LROOT Q
 ;
T530(FAIL) ; unsupported manifest schema version is rejected
 N PATH,SROOT,LROOT,OPT,PRES,ERES,LRES,BASE,MPATH
 S PATH=$$WRFILE($$SAMPLEP())
 S SROOT=$NA(^TMP($J,"EFU837CANT",530,"SRC"))
 S LROOT=$NA(^TMP($J,"EFU837CANT",530,"LOAD"))
 D PARSE^EFU837P(PATH,SROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T530][parse ok]",+$G(PRES("ok")),1)
 S BASE="efu837cant_530_"_$J
 D EXPORT^EFU837CAN(SROOT,BASE,.ERES)
 D EQ(.FAIL,"[T530][export ok]",+$G(ERES("ok")),1)
 S MPATH=BASE_"-manifest.txt"
 D BADMAN(MPATH,BASE)
 D LOAD^EFU837CAN(BASE,LROOT,.LRES)
 D EQ(.FAIL,"[T530][load fails]",+$G(LRES("ok")),0)
 D EQ(.FAIL,"[T530][error]",$G(LRES("error")),"unsupported_schema_version")
 K @SROOT,@LROOT Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
WRFILE(DATA) ; write DATA to temp file and return path
 N PATH,OLDIO
 S PATH="efu837cant_"_$J_".tmp"
 S OLDIO=$IO
 O PATH:(NEWVERSION:STREAM:WRITEONLY):0
 I '$T Q PATH
 U PATH W DATA
 C PATH U OLDIO
 Q PATH
 ;
READALL(PATH) ; test-only full file read
 N DEV,OLDIO,TXT,X,DONE
 S DEV=PATH,OLDIO=$IO,TXT="",DONE=0
 O DEV:(READONLY:STREAM):1
 I '$T Q ""
 U DEV
 F  Q:DONE  D
 . S X=""
 . R X#4096:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S DONE=1
 . I X'="" S TXT=TXT_X
 . I $ZEOF S DONE=1
 C DEV U OLDIO
 Q TXT
 ;
COPY(IN,OUT) ; simple stream copy helper
 N I,O,OLDIO,X,DONE,OK
 S I=IN,O=OUT,OLDIO=$IO,OK=0,DONE=0
 O I:(READONLY:STREAM):1 I '$T Q 0
 O O:(NEWVERSION:STREAM:WRITEONLY):1 I '$T C I Q 0
 U I
 F  Q:DONE  D
 . S X=""
 . R X#4096:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S DONE=1
 . U O I X'="" W X
 . U I
 . I $ZEOF S DONE=1
 C I C O U OLDIO
 S OK=1
 Q OK
 ;
BADMAN(PATH,BASE) ; overwrite manifest with unsupported version
 N DEV,OLDIO
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q
 U DEV
 W "schema_name=EFU837_CANONICAL",!
 W "schema_version=99",!
 W "schema_semver=99.0.0",!
 W "claims_path=",BASE,"-claims.csv",!
 W "lines_path=",BASE,"-lines.csv",!
 C DEV U OLDIO
 Q
 ;
SAMPLEP() Q $$SAMPLEP^EFU837SPECT()
SAMPLEI() Q $$SAMPLEI^EFU837SPECT()
SAMPLED() Q $$SAMPLED^EFU837SPECT()
 ;
