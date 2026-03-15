EFUZYRELT ; efuzy release metadata tests
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 Q
 ;
T001 ; info returns stable release metadata
 N CONF,RES
 D RESET^EFUZYTESTU("")
 S CONF("efuzy","edition")="Professional"
 D INFO^EFUZYREL(.CONF,.RES)
 D EQ^MIOTASSERT($G(RES("ok")),1,"[T001][info ok]")
 D EQ^MIOTASSERT($G(RES("app")),"efuzy","[T001][app]")
 D EQ^MIOTASSERT($G(RES("edition")),"professional","[T001][edition]")
 D EQ^MIOTASSERT($G(RES("scheme")),"semver","[T001][scheme]")
 D EQ^MIOTASSERT($G(RES("release_id"))["efuzy-professional-",1,"[T001][release id]")
 Q
 ;
T002 ; write manifest produces expected keys
 N CONF,ROOT,PATH,TXT,RES
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("rel2")
 D MKDIR^EFUZYTESTU(ROOT)
 S PATH=ROOT_"/release_manifest.txt"
 D OK^MIOTASSERT($$WRITE^EFUZYREL(.CONF,PATH,.RES),"[T002][write ok]")
 D EQ^MIOTASSERT($G(RES("ok")),1,"[T002][res ok]")
 D OK^MIOTASSERT($$READFILE^EFUZYTESTU(PATH,.TXT),"[T002][read back]")
 D OK^MIOTASSERT($G(TXT)["version=0.4.0","[T002][version line]")
 D OK^MIOTASSERT($G(TXT)["artifact_3=checksums","[T002][checksums line]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
T003 ; verify checks required release inputs
 N RES,ROOT,OK
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("rel3")
 D MKDIR^EFUZYTESTU(ROOT)
 D MKDIR^EFUZYTESTU(ROOT_"/scripts")
 D MKDIR^EFUZYTESTU(ROOT_"/docs")
 D WRITEFILE^EFUZYTESTU(ROOT_"/README.md","readme",.OK)
 D WRITEFILE^EFUZYTESTU(ROOT_"/CHANGELOG.md","log",.OK)
 D WRITEFILE^EFUZYTESTU(ROOT_"/VERSION","0.4.0",.OK)
 D WRITEFILE^EFUZYTESTU(ROOT_"/scripts/install_efuzy.sh","#!/usr/bin/env bash",.OK)
 D WRITEFILE^EFUZYTESTU(ROOT_"/docs/RELEASE_ENGINEERING.md","release",.OK)
 D OK^MIOTASSERT($$VERIFY^EFUZYREL(ROOT,.RES),"[T003][verify ok]")
 D EQ^MIOTASSERT($G(RES("ok")),1,"[T003][verify flag]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
