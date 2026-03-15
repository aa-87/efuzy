EFUZYDLV ; efuzy delivery and fulfillment helpers
	;
	Q
	;
APP() ; product code
	Q "efuzy"
	;
VERSION() ; current version with safe fallback
	I $T(VERSION^EFUZYREL)'="" Q $$VERSION^EFUZYREL()
	Q "0.4.0"
	;
EDITION(CONF) ; edition with safe fallback
	I $T(EDITION^EFUZYREL)'="" Q $$EDITION^EFUZYREL(.CONF)
	N X
	S X=$$LC($G(CONF("efuzy","edition")))
	I X="" S X="standard"
	Q X
	;
SAFE(X) ; sanitize for file/bundle names
	N I,C,OUT,LAST
	S X=$$LC($G(X)),OUT="",LAST=""
	F I=1:1:$L(X) S C=$E(X,I) D
	. I C?1AN S OUT=OUT_C,LAST=C Q
	. I LAST'="-" S OUT=OUT_"-",LAST="-"
	F  Q:$E(OUT,1)'="-"  S OUT=$E(OUT,2,$L(OUT))
	F  Q:$E(OUT,$L(OUT))'="-"  S OUT=$E(OUT,1,$L(OUT)-1)
	I OUT="" S OUT="customer"
	Q OUT
	;
BUNDLENAME(VERSION,EDITION,CUSTOMER) ; delivery bundle directory/archive name
	N V,E,C
	S V=$G(VERSION) I V="" S V=$$VERSION()
	S E=$$SAFE($G(EDITION)) I E="" S E="standard"
	S C=$$SAFE($G(CUSTOMER)) I C="" S C="customer"
	Q $$APP()_"-delivery-"_V_"-"_E_"-"_C
	;
INFO(CONF,CUSTOMER,QUOTE,RES) ; delivery metadata
	K RES
	S RES("ok")=1
	S RES("app")=$$APP()
	S RES("version")=$$VERSION()
	S RES("edition")=$$EDITION(.CONF)
	S RES("customer")=$G(CUSTOMER)
	S RES("customer_safe")=$$SAFE($G(CUSTOMER))
	S RES("quote_id")=$G(QUOTE)
	S RES("bundle_name")=$$BUNDLENAME($G(RES("version")),$G(RES("edition")),$G(CUSTOMER))
	S RES("release_archive")=$$APP()_"-"_$G(RES("version"))_"-"_$G(RES("edition"))_".tar.gz"
	S RES("release_archive_zip")=$$APP()_"-"_$G(RES("version"))_"-"_$G(RES("edition"))_".zip"
	S RES("docs_package")=$$APP()_"-docs-"_$G(RES("version"))_"-"_$G(RES("edition"))_".tar.gz"
	S RES("installer_package")=$$APP()_"-installer-"_$G(RES("version"))_"-"_$G(RES("edition"))_".tar.gz"
	S RES("required",1)="START_HERE.txt"
	S RES("required",2)="DELIVERY_NOTICE.txt"
	S RES("required",3)="DELIVERY_MANIFEST.txt"
	S RES("required",4)="RELEASE/SHA256SUMS.txt"
	S RES("required",5)="DOCS/INSTALL_GUIDE.md"
	S RES("required",6)="INSTALLER/install_efuzy.sh"
	Q
	;
VERIFY(ROOT,RES) ; verify a prepared delivery bundle directory
	N N
	K RES
	S RES("ok")=1,N=0
	I '$$FILE($G(ROOT)_"/START_HERE.txt") S N=N+1,RES("missing",N)="START_HERE.txt"
	I '$$FILE($G(ROOT)_"/DELIVERY_NOTICE.txt") S N=N+1,RES("missing",N)="DELIVERY_NOTICE.txt"
	I '$$FILE($G(ROOT)_"/DELIVERY_MANIFEST.txt") S N=N+1,RES("missing",N)="DELIVERY_MANIFEST.txt"
	I '$$FILE($G(ROOT)_"/RELEASE/SHA256SUMS.txt") S N=N+1,RES("missing",N)="RELEASE/SHA256SUMS.txt"
	I '$$FILE($G(ROOT)_"/DOCS/INSTALL_GUIDE.md") S N=N+1,RES("missing",N)="DOCS/INSTALL_GUIDE.md"
	I '$$FILE($G(ROOT)_"/INSTALLER/install_efuzy.sh") S N=N+1,RES("missing",N)="INSTALLER/install_efuzy.sh"
	I N>0 S RES("ok")=0,RES("error")="delivery_bundle_incomplete"
	S RES("root")=$G(ROOT)
	Q +$G(RES("ok"))
	;
FILE(PATH) ; file exists
	O PATH:(readonly:stream:nowrap):0 E  Q 0
	C PATH
	Q 1
	;
LC(X)
	Q $ZCONVERT($G(X),"L")
	;
