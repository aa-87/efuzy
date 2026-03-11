EFUX12DIAG ; efuzy X12 structured diagnostic helpers
 ;
 ; Public:
 ;   ADD(ROOT,SEV,CODE,MSG,.CTX,.ID)
 ;   ERR(ROOT,CODE,MSG,.CTX,.ID)
 ;   WARN(ROOT,CODE,MSG,.CTX,.ID)
 ;   INFO(ROOT,CODE,MSG,.CTX,.ID)
 ;   FATAL(ROOT,CODE,MSG,.CTX,.ID)
 ;   HASERR(ROOT)
 ;   COUNT(ROOT,SEV)
 ;   SUMMARY(ROOT,.OUT)
 ;
 Q
 ;
ADD(ROOT,SEV,CODE,MSG,CTX,ID) ; append one validator diagnostic
 N IDX,S
 S S=$$LC($G(SEV)) I S="" S S="error"
 S IDX=+$G(@ROOT@("vdiag","last"))+1
 S @ROOT@("vdiag","last")=IDX
 S @ROOT@("vdiag","count")=+$G(@ROOT@("vdiag","count"))+1
 S @ROOT@("vdiag","by_sev",S)=+$G(@ROOT@("vdiag","by_sev",S))+1
 S @ROOT@("vdiag","item",IDX,"severity")=S
 S @ROOT@("vdiag","item",IDX,"code")=$G(CODE)
 S @ROOT@("vdiag","item",IDX,"message")=$G(MSG)
 I $D(CTX) M @ROOT@("vdiag","item",IDX,"ctx")=CTX
 S ID=IDX
 Q
 ;
ERR(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"error",$G(CODE),$G(MSG),.CTX,.ID) Q
WARN(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"warn",$G(CODE),$G(MSG),.CTX,.ID) Q
INFO(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"info",$G(CODE),$G(MSG),.CTX,.ID) Q
FATAL(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"fatal",$G(CODE),$G(MSG),.CTX,.ID) Q
 ;
HASERR(ROOT) ; whether validator diagnostics contain fatal/error
 Q $S(($$COUNT(ROOT,"fatal")+$$COUNT(ROOT,"error"))>0:1,1:0)
 ;
COUNT(ROOT,SEV) ; count diagnostics by severity
 Q +$G(@ROOT@("vdiag","by_sev",$$LC($G(SEV))))
 ;
SUMMARY(ROOT,OUT) ; summarize counts into OUT
 K OUT
 S OUT("total")=+$G(@ROOT@("vdiag","count"))
 S OUT("fatal")=$$COUNT(ROOT,"fatal")
 S OUT("error")=$$COUNT(ROOT,"error")
 S OUT("warn")=$$COUNT(ROOT,"warn")
 S OUT("info")=$$COUNT(ROOT,"info")
 S OUT("ok")=$S((OUT("fatal")+OUT("error"))>0:0,1:1)
 Q
 ;
LC(X) ; lowercase alpha only
 N Y,I,C,A
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I) D
 . S A=$A(C)
 . I A'<65,A'>90 S C=$C(A+32)
 . S Y=Y_C
 Q Y
 ;
