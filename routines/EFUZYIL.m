EFUZYIL
	;	
	;
	Q
ISSUE
	D BOOTCONF^MIO(.CONF)
	S CONF("efuzy","license","jwtSecret")="replace-this-with-your-license-secret"
	S SPEC("mode")="paid"
	S SPEC("edition")="professional"
	S SPEC("licensee")="Example Billing LLC"
	S SPEC("install_id")="customer-install-id"
	S SPEC("filePath")="instance/license/efuzy.license"
	D ISSUE^EFUZYLIC(.CONF,.SPEC,.RES)
	W RES("token")
	;W $$STATUS^EFUZYLIC(.CONF,.RES),!
	;	
	Q