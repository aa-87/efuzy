EFU837P2T ; tests for EFU837P2
	;
	;
START
	D T001
	D T002
	D T003
	Q
	;
T001 ; detect separators and isa values
	N ROOT,PATH,OK,EL,SEG,COMP,REP,VER,SND,RCV,ERR
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("837-detect")
	D MKDIR^EFUZYTESTU(ROOT)
	S PATH=ROOT_"/sample.837"
	D SAMPLE837^EFUZYTESTU(PATH,.OK)
	D OK^MIOTASSERT(OK,"[T001][sample written]")
	D OK^MIOTASSERT($$DETECT^EFU837P2(PATH,.EL,.SEG,.COMP,.REP,.VER,.SND,.RCV,.ERR),"[T001][detect ok]")
	D EQ^MIOTASSERT(EL,"*","[T001][element sep]")
	D EQ^MIOTASSERT(SEG,"~","[T001][segment sep]")
	D EQ^MIOTASSERT(COMP,":","[T001][component sep]")
	D EQ^MIOTASSERT(VER,"00501","[T001][version]")
	D EQ^MIOTASSERT(SND,"SENDERID","[T001][sender]")
	D EQ^MIOTASSERT(RCV,"RECEIVERID","[T001][receiver]")
	D RMDIR^EFUZYTESTU(ROOT)
	Q
	;
T002 ; parse sample 837 into work rows and stats
	N ROOT,PATH,OK,CFG,OUT,ERR,JOBID
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("837-parse")
	D MKDIR^EFUZYTESTU(ROOT)
	S PATH=ROOT_"/sample.837"
	D SAMPLE837^EFUZYTESTU(PATH,.OK)
	S JOBID=31,CFG("jobId")=JOBID
	D OK^MIOTASSERT($$PARSE^EFU837P2(PATH,.CFG,.OUT,.ERR),"[T002][parse ok]")
	D EQ^MIOTASSERT($G(OUT("claimCount")),1,"[T002][claim count]")
	D EQ^MIOTASSERT($G(OUT("serviceLineCount")),1,"[T002][line count]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")),"CLM0001","[T002][claim id]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"wrk","claim",1,"subscriber_id")),"ABC123","[T002][subscriber id]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_last")),"DOE","[T002][patient last]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")),"99213","[T002][procedure code]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_charge")),"75","[T002][line charge]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"stats","senderId")),"SENDERID","[T002][sender stat]")
	D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"stats","receiverId")),"RECEIVERID","[T002][receiver stat]")
	D RMDIR^EFUZYTESTU(ROOT)
	Q
	;
T003 ; detect rejects non-isa file
	N ROOT,PATH,OK,EL,SEG,COMP,REP,VER,SND,RCV,ERR
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("837-invalid")
	D MKDIR^EFUZYTESTU(ROOT)
	S PATH=ROOT_"/bad.txt"
	D WRITEFILE^EFUZYTESTU(PATH,"NOTX12",.OK)
	D EQ^MIOTASSERT($$DETECT^EFU837P2(PATH,.EL,.SEG,.COMP,.REP,.VER,.SND,.RCV,.ERR),0,"[T003][detect fail]")
	D EQ^MIOTASSERT($G(ERR("error")),"not_x12_isa","[T003][error]")
	D RMDIR^EFUZYTESTU(ROOT)
	Q
	;
	;