EFU837P ; streaming 837 parser
 ;
 ; Baseline parser scope
 ; --------------------
 ; - Detects ISA element / component / segment separators.
 ; - Streams the file in chunks.
 ; - Extracts common 837P-style claim and service-line fields.
 ; - Stores normalized working rows under:
 ;     ^MIO("EFUZY","job",jobId,"wrk",...)
 ; - Keeps only compact preview/stat fields in job stats.
 ;
 ; Coverage notes
 ; --------------
 ; This is a pragmatic MVP baseline.
 ; It is not a full X12 grammar engine.
 ; It targets common 837 usage patterns well enough to power
 ; a trustworthy first export workspace while leaving room for
 ; later loop-accurate parsing and companion-guide tuning.
 ;
 Q
 ;
PARSE(PATH,CFG,OUT,ERR)
 N JOBID,EL,SEG,COMP,REP,CHSZ,BUF,DONE,CH,LINEC
 N SEGCT,CLMCT,LINCT,CURCLM,CURLINE,LX
 N SUBL,SUBF,SUBID,PATL,PATF,BILN,BILID,PAYN,PAYID,SUBMIT,RCVR
 N CLAIMDATE,LINEVDT,VERSION,SENDER,RECVR
 K OUT,ERR
 S JOBID=+$G(CFG("jobId"))
 I $G(PATH)="" S ERR("error")="path_required" Q 0
 I '$$DETECT(PATH,.EL,.SEG,.COMP,.REP,.VERSION,.SENDER,.RECVR,.ERR) Q 0
 I JOBID D
 . K ^MIO("EFUZY","job",JOBID,"wrk")
 . D SETSTAT^EFUZYJOB(JOBID,"version",VERSION)
 . D SETSTAT^EFUZYJOB(JOBID,"senderId",SENDER)
 . D SETSTAT^EFUZYJOB(JOBID,"receiverId",RECVR)
 S CHSZ=8192,BUF="",DONE=0
 S (LINEC,SEGCT,CLMCT,LINCT,CURCLM,CURLINE,LX)=0
 S (SUBL,SUBF,SUBID,PATL,PATF,BILN,BILID,PAYN,PAYID,SUBMIT,RCVR,CLAIMDATE,LINEVDT)=""
 O PATH:(readonly:stream:nowrap):1 E  S ERR("error")="open_failed" Q 0
 U PATH
 F  D  Q:DONE
 . R CH#CHSZ
 . I $ZEOF S DONE=1
 . S BUF=BUF_CH
 . D CONSUME(.BUF,SEG,EL,COMP,JOBID,.SEGCT,.CLMCT,.LINCT,.CURCLM,.CURLINE,.LX,.SUBL,.SUBF,.SUBID,.PATL,.PATF,.BILN,.BILID,.PAYN,.PAYID,.SUBMIT,.RCVR,.CLAIMDATE,.LINEVDT)
 C PATH
 S OUT("ok")=1
 S OUT("segmentCount")=SEGCT
 S OUT("claimCount")=CLMCT
 S OUT("serviceLineCount")=LINCT
 S OUT("lineCount")=LINEC
 I JOBID D
 . D SETSTAT^EFUZYJOB(JOBID,"segmentCount",SEGCT)
 . D SETSTAT^EFUZYJOB(JOBID,"claimCount",CLMCT)
 . D SETSTAT^EFUZYJOB(JOBID,"serviceLineCount",LINCT)
 Q 1
 ;
DETECT(PATH,EL,SEG,COMP,REP,VERSION,SENDER,RECVR,ERR)
 N X
 K ERR
 S (EL,SEG,COMP,REP,VERSION,SENDER,RECVR)=""
 O PATH:(readonly:stream:nowrap):1 E  S ERR("error")="open_failed" Q 0
 U PATH R X#106 C PATH
 I $E(X,1,3)'="ISA" S ERR("error")="not_x12_isa" Q 0
 S EL=$E(X,4)
 S REP=$E(X,83)
 S COMP=$E(X,105)
 S SEG=$E(X,106)
 S VERSION=$$TR($P(X,EL,13))
 S SENDER=$$TR($P(X,EL,7))
 S RECVR=$$TR($P(X,EL,9))
 I SEG="" S SEG="~"
 I EL="" S EL="*"
 I COMP="" S COMP=":"
 I REP="" S REP="^"
 Q 1
 ;
CONSUME(BUF,SEG,EL,COMP,JOBID,SEGCT,CLMCT,LINCT,CURCLM,CURLINE,LX,SUBL,SUBF,SUBID,PATL,PATF,BILN,BILID,PAYN,PAYID,SUBMIT,RCVR,CLAIMDATE,LINEVDT)
 N P,S
 F  D  Q:'P
 . S P=$F(BUF,SEG)
 . Q:'P
 . S S=$E(BUF,1,P-2)
 . S BUF=$E(BUF,P,$L(BUF))
 . S S=$$STRIP(S)
 . I S="" Q
 . S SEGCT=SEGCT+1
 . D HANDLE(S,EL,COMP,JOBID,.CLMCT,.LINCT,.CURCLM,.CURLINE,.LX,.SUBL,.SUBF,.SUBID,.PATL,.PATF,.BILN,.BILID,.PAYN,.PAYID,.SUBMIT,.RCVR,.CLAIMDATE,.LINEVDT)
 Q
 ;
HANDLE(S,EL,COMP,JOBID,CLMCT,LINCT,CURCLM,CURLINE,LX,SUBL,SUBF,SUBID,PATL,PATF,BILN,BILID,PAYN,PAYID,SUBMIT,RCVR,CLAIMDATE,LINEVDT)
 N TAG,ENT,ID,QUAL,VAL,C1,C2,C3,C4,C5
 S TAG=$P(S,EL,1)
 I TAG="NM1" D  Q
 . S ENT=$P(S,EL,2)
 . I ENT=41 S SUBMIT=$$NAME($P(S,EL,4),$P(S,EL,5)) Q
 . I ENT=40 S RCVR=$$NAME($P(S,EL,4),$P(S,EL,5)) Q
 . I ENT=85 S BILN=$$NAME($P(S,EL,4),$P(S,EL,5)),BILID=$P(S,EL,10) Q
 . I ENT="PR" S PAYN=$$NAME($P(S,EL,4),$P(S,EL,5)),PAYID=$P(S,EL,10) Q
 . I ENT="IL" S SUBL=$P(S,EL,4),SUBF=$P(S,EL,5),SUBID=$P(S,EL,10) Q
 . I ENT="QC" S PATL=$P(S,EL,4),PATF=$P(S,EL,5) Q
 I TAG="CLM" D  Q
 . S CLMCT=CLMCT+1,CURCLM=CLMCT,CURLINE=0,LX=""
 . S CLAIMDATE=""
 . D CSET(JOBID,CURCLM,"claim_index",CURCLM)
 . D CSET(JOBID,CURCLM,"claim_id",$P(S,EL,2))
 . D CSET(JOBID,CURCLM,"total_charge",$P(S,EL,3))
 . D CSET(JOBID,CURCLM,"subscriber_id",SUBID)
 . D CSET(JOBID,CURCLM,"subscriber_last",SUBL)
 . D CSET(JOBID,CURCLM,"subscriber_first",SUBF)
 . I PATL="" S PATL=SUBL
 . I PATF="" S PATF=SUBF
 . D CSET(JOBID,CURCLM,"patient_last",PATL)
 . D CSET(JOBID,CURCLM,"patient_first",PATF)
 . D CSET(JOBID,CURCLM,"billing_provider_name",BILN)
 . D CSET(JOBID,CURCLM,"billing_provider_id",BILID)
 . D CSET(JOBID,CURCLM,"payer_name",PAYN)
 . D CSET(JOBID,CURCLM,"payer_id",PAYID)
 . D CSET(JOBID,CURCLM,"submitter_name",SUBMIT)
 . D CSET(JOBID,CURCLM,"receiver_name",RCVR)
 . D CSET(JOBID,CURCLM,"service_line_count",0)
 I TAG="DTP",CURCLM>0 D  Q
 . S QUAL=$P(S,EL,2),VAL=$P(S,EL,4)
 . I QUAL=434!(QUAL=472) D
 . . I CLAIMDATE="" S CLAIMDATE=VAL D CSET(JOBID,CURCLM,"claim_date",VAL)
 . . I CURLINE>0 D LSET(JOBID,CURLINE,"line_service_date",VAL)
 I TAG="REF",CURCLM>0 D  Q
 . S QUAL=$P(S,EL,2),VAL=$P(S,EL,3)
 . I QUAL="D9" D CSET(JOBID,CURCLM,"claim_reference",VAL) Q
 . I QUAL="1K" D CSET(JOBID,CURCLM,"payer_claim_control_number",VAL) Q
 I TAG="LX",CURCLM>0 D  Q
 . S LX=$P(S,EL,2)
 I TAG="SV1",CURCLM>0 D  Q
 . S LINCT=LINCT+1,CURLINE=LINCT
 . S C1=$P($P(S,EL,2),COMP,1)
 . S C2=$P($P(S,EL,2),COMP,2)
 . S C3=$P($P(S,EL,2),COMP,3)
 . S C4=$P($P(S,EL,2),COMP,4)
 . S C5=$P($P(S,EL,2),COMP,5)
 . D LSET(JOBID,CURLINE,"line_index",CURLINE)
 . D LSET(JOBID,CURLINE,"claim_index",CURCLM)
 . D LSET(JOBID,CURLINE,"claim_id",$G(^MIO("EFUZY","job",JOBID,"wrk","claim",CURCLM,"claim_id")))
 . D LSET(JOBID,CURLINE,"line_number",$S(LX'="":LX,1:CURLINE))
 . D LSET(JOBID,CURLINE,"procedure_qualifier",C1)
 . D LSET(JOBID,CURLINE,"procedure_code",C2)
 . D LSET(JOBID,CURLINE,"modifier_1",C3)
 . D LSET(JOBID,CURLINE,"modifier_2",C4)
 . D LSET(JOBID,CURLINE,"modifier_3",C5)
 . D LSET(JOBID,CURLINE,"line_charge",$P(S,EL,3))
 . D LSET(JOBID,CURLINE,"units",$P(S,EL,5))
 . D LSET(JOBID,CURLINE,"subscriber_id",SUBID)
 . D LSET(JOBID,CURLINE,"patient_last",$G(^MIO("EFUZY","job",JOBID,"wrk","claim",CURCLM,"patient_last")))
 . D LSET(JOBID,CURLINE,"patient_first",$G(^MIO("EFUZY","job",JOBID,"wrk","claim",CURCLM,"patient_first")))
 . D CSET(JOBID,CURCLM,"service_line_count",+$G(^MIO("EFUZY","job",JOBID,"wrk","claim",CURCLM,"service_line_count"))+1)
 Q
 ;
CSET(JOBID,IDX,KEY,VAL)
 I +$G(JOBID)<1 Q
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",IDX,KEY)=$G(VAL)
 Q
 ;
LSET(JOBID,IDX,KEY,VAL)
 I +$G(JOBID)<1 Q
 S ^MIO("EFUZY","job",JOBID,"wrk","line",IDX,KEY)=$G(VAL)
 Q
 ;
NAME(L,F)
 Q $$TR(L)_$S(L'=""&(F'=""):", ",1:"")_$$TR(F)
 ;
TR(X)
 Q $$TRIM^MIOUTIL($TR($G(X),"""",""))
 ;
STRIP(X)
 N Y
 S Y=$G(X)
 I $E(Y,1)=$C(13) S Y=$E(Y,2,$L(Y))
 I $E(Y,$L(Y))=$C(13) S Y=$E(Y,1,$L(Y)-1)
 I $E(Y,1)=$C(10) S Y=$E(Y,2,$L(Y))
 I $E(Y,$L(Y))=$C(10) S Y=$E(Y,1,$L(Y)-1)
 Q Y
 ;
