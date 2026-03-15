EFUZYDLVT ; efuzy delivery tests
	;
	Q
	;
START
	D T001
	D T002
	D T003
	Q
	;
T001 ; bundle name is sanitized and stable
	N X
	S X=$$BUNDLENAME^EFUZYDLV("0.4.0","Professional","Acme Billing, LLC")
	D EQ^MIOTASSERT(X,"efuzy-delivery-0.4.0-professional-acme-billing-llc","[T001][bundle name]")
	Q
	;
T002 ; info returns expected fulfillment metadata
	N CONF,RES
	D RESET^EFUZYTESTU("")
	S CONF("efuzy","edition")="Professional"
	D INFO^EFUZYDLV(.CONF,"Acme Billing","Q-1001",.RES)
	D EQ^MIOTASSERT($G(RES("ok")),1,"[T002][info ok]")
	D EQ^MIOTASSERT($G(RES("edition")),"professional","[T002][edition]")
	D EQ^MIOTASSERT($G(RES("customer_safe")),"acme-billing","[T002][customer safe]")
	D EQ^MIOTASSERT($G(RES("docs_package")),"efuzy-docs-0.4.0-professional.tar.gz","[T002][docs package]")
	Q
	;
T003 ; verify accepts a minimum buyer delivery structure
	N ROOT,OK,RES
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("dlv3")
	D MKDIR^EFUZYTESTU(ROOT)
	D MKDIR^EFUZYTESTU(ROOT_"/RELEASE")
	D MKDIR^EFUZYTESTU(ROOT_"/DOCS")
	D MKDIR^EFUZYTESTU(ROOT_"/INSTALLER")
	D WRITEFILE^EFUZYTESTU(ROOT_"/START_HERE.txt","start",.OK)
	D WRITEFILE^EFUZYTESTU(ROOT_"/DELIVERY_NOTICE.txt","notice",.OK)
	D WRITEFILE^EFUZYTESTU(ROOT_"/DELIVERY_MANIFEST.txt","manifest",.OK)
	D WRITEFILE^EFUZYTESTU(ROOT_"/RELEASE/SHA256SUMS.txt","sum",.OK)
	D WRITEFILE^EFUZYTESTU(ROOT_"/DOCS/INSTALL_GUIDE.md","install",.OK)
	D WRITEFILE^EFUZYTESTU(ROOT_"/INSTALLER/install_efuzy.sh","#!/usr/bin/env bash",.OK)
	D OK^MIOTASSERT($$VERIFY^EFUZYDLV(ROOT,.RES),"[T003][verify ok]")
	D EQ^MIOTASSERT($G(RES("ok")),1,"[T003][verify flag]")
	D RMDIR^EFUZYTESTU(ROOT)
	Q
	;
