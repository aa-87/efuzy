EFU837GOLD ; efuzy 837 golden fixture catalog
 ;
 ; Public:
 ;   IDS(.OUT)
 ;   META(ID,.OUT)
 ;   COUNT()
 ;   DATA(ID)
 ;
 ; Notes:
 ;   - controlled embedded fixtures for additive regression coverage
 ;   - focused on production-minded parser/export shapes
 ;   - does not replace external Example_1 / Example_2 coverage
 ;
 Q
 ;
IDS(OUT) ; enumerate fixture ids -> description
 N I,REC,ID
 K OUT
 F I=1:1 S REC=$P($T(METATAB+I),";;",2,99) Q:REC=""  D
 . I REC'["|" Q
 . S ID=$P(REC,"|",1)
 . S OUT(ID)=$P(REC,"|",2)
 Q
 ;
META(ID,OUT) ; fetch fixture metadata by id
 N I,REC
 K OUT
 S ID=$G(ID)
 F I=1:1 S REC=$P($T(METATAB+I),";;",2,99) Q:REC=""  D  Q:$D(OUT)
 . I REC'["|" Q
 . I $P(REC,"|",1)'=ID Q
 . S OUT("id")=$P(REC,"|",1)
 . S OUT("desc")=$P(REC,"|",2)
 . S OUT("kind")=$P(REC,"|",3)
 . S OUT("guide")=$P(REC,"|",4)
 . S OUT("claims")=+$P(REC,"|",5)
 . S OUT("lines")=+$P(REC,"|",6)
 . S OUT("svc")=$P(REC,"|",7)
 . S OUT("valid")=+$P(REC,"|",8)
 . S OUT("roundtrip")=+$P(REC,"|",9)
 Q
 ;
COUNT() ; fixture count
 N I,C,REC
 S C=0
 F I=1:1 S REC=$P($T(METATAB+I),";;",2,99) Q:REC=""  I REC["|" S C=C+1
 Q C
 ;
DATA(ID) ; fixture payload by id
 I $G(ID)="GP001" Q $$GP001()
 I $G(ID)="GI001" Q $$GI001()
 I $G(ID)="GD001" Q $$GD001()
 I $G(ID)="GP010" Q $$GP010()
 I $G(ID)="GP020" Q $$GP020()
 I $G(ID)="GP030" Q $$GP030()
 I $G(ID)="GP040" Q $$GP040()
 I $G(ID)="GB900" Q $$GB900()
 Q ""
 ;
GP001() ; minimal valid professional claim
 Q $$SAMPLEP^EFU837SPECT()
 ;
GI001() ; minimal valid institutional claim
 Q $$SAMPLEI^EFU837SPECT()
 ;
GD001() ; minimal valid dental claim
 Q $$SAMPLED^EFU837SPECT()
 ;
GP010() ; professional single claim with two service lines
 N S
 S S="ST*837*10*005010X222A1~"
 S S=S_"BHT*0019*00*GP010*20260311*1200*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*41*2*SUBMITTER*****46*123~"
 S S=S_"NM1*40*2*RECEIVER*****46*999~"
 S S=S_"NM1*85*2*ACME CLINIC*****XX*1234567893~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*DOE*JANE****MI*MGP010~"
 S S=S_"NM1*PR*2*PAYER A*****PI*PA001~"
 S S=S_"CLM*GP010C1*225***11:B:1*Y*A*Y*Y~"
 S S=S_"DTP*434*D8*20260311~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:99213*100*UN*1***1~"
 S S=S_"DTP*472*D8*20260311~"
 S S=S_"LX*2~"
 S S=S_"SV1*HC:87070*125*UN*1***1~"
 S S=S_"DTP*472*D8*20260311~"
 S S=S_"SE*19*10~"
 Q S
 ;
GP020() ; professional distinct patient under subscriber
 N S
 S S="ST*837*20*005010X222A1~"
 S S=S_"BHT*0019*00*GP020*20260311*1200*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*41*2*SUBMITTER*****46*123~"
 S S=S_"NM1*40*2*RECEIVER*****46*999~"
 S S=S_"HL*2*1*22*1~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*SUBSCRIBER*SAM****MI*SUB123~"
 S S=S_"DMG*D8*19800101*M~"
 S S=S_"HL*3*2*23*0~"
 S S=S_"PAT*19~"
 S S=S_"NM1*IL*1*PATIENT*JILL****MI*PAT123~"
 S S=S_"DMG*D8*20100101*F~"
 S S=S_"CLM*GP020C1*75***11:B:1*Y*A*Y*Y~"
 S S=S_"DTP*434*D8*20260311~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:99212*75*UN*1***1~"
 S S=S_"DTP*472*D8*20260311~"
 S S=S_"SE*19*20~"
 Q S
 ;
GP030() ; professional transaction with two claims
 N S
 S S="ST*837*30*005010X222A1~"
 S S=S_"BHT*0019*00*GP030*20260311*1200*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*41*2*SUBMITTER*****46*123~"
 S S=S_"NM1*40*2*RECEIVER*****46*999~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*DOE*JANE****MI*MGP030~"
 S S=S_"NM1*PR*2*PAYER A*****PI*PA001~"
 S S=S_"CLM*GP030C1*100***11:B:1*Y*A*Y*Y~"
 S S=S_"DTP*434*D8*20260311~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:99213*100*UN*1***1~"
 S S=S_"DTP*472*D8*20260311~"
 S S=S_"CLM*GP030C2*80***11:B:1*Y*A*Y*Y~"
 S S=S_"DTP*434*D8*20260312~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:87070*80*UN*1***1~"
 S S=S_"DTP*472*D8*20260312~"
 S S=S_"SE*20*30~"
 Q S
 ;
GP040() ; professional ranged claim with diagnosis and attending provider
 N S
 S S="ST*837*40*005010X222A1~"
 S S=S_"BHT*0019*00*GP040*20260310*1200*CH~"
 S S=S_"HL*1**20*1~"
 S S=S_"NM1*41*2*SUBMITTER*****46*123~"
 S S=S_"NM1*40*2*RECEIVER*****46*999~"
 S S=S_"HL*2*1*22*0~"
 S S=S_"SBR*P*18*******CI~"
 S S=S_"NM1*IL*1*DOE*JANE****MI*MGP040~"
 S S=S_"CLM*GP040C1*300***11:B:1*Y*A*Y*Y~"
 S S=S_"DTP*434*RD8*20260310-20260312~"
 S S=S_"HI*BK:A123*BF:B456~"
 S S=S_"NM1*71*1*HOUSE*GREGORY****XX*9999999993~"
 S S=S_"LX*1~"
 S S=S_"SV1*HC:99214*300*UN*1***1~"
 S S=S_"DTP*472*D8*20260311~"
 S S=S_"SE*16*40~"
 Q S
 ;
GB900() ; malformed transaction with service content but no CLM
 Q $$SAMPLENOCLM^EFU837SPECT()
 ;
METATAB ; id|desc|kind|guide|claims|lines|svc|valid|roundtrip
 ;;GP001|minimal professional|837P|005010X222A1|1|1|SV1|1|1
 ;;GI001|minimal institutional|837I|005010X223A2|1|1|SV2|1|1
 ;;GD001|minimal dental|837D|005010X224A2|1|1|SV3|1|1
 ;;GP010|professional two lines|837P|005010X222A1|1|2|SV1|1|1
 ;;GP020|professional distinct patient|837P|005010X222A1|1|1|SV1|1|1
 ;;GP030|professional multi-claim transaction|837P|005010X222A1|2|2|SV1|1|1
 ;;GP040|professional ranged dates diagnosis attending|837P|005010X222A1|1|1|SV1|1|1
 ;;GB900|missing CLM malformed|837P|005010X222A1|0|0|SV1|0|0
 ;;
