EFUZYREL ; efuzy release metadata and packaging helpers
	;
	Q
	;
APP() ; product code
	Q "efuzy"
	;
NAME() ; display name
	Q "EFUZY"
	;
VERSION() ; current app version
	Q "0.4.0"
	;
SCHEME() ; versioning scheme
	Q "semver"
	;
SERIES() ; major.minor series
	N V,P1,P2
	S V=$$VERSION(),P1=$P(V,".",1),P2=$P(V,".",2)
	Q P1_"."_P2
	;
CHANNEL() ; release channel
	Q "commercial-self-hosted"
	;
EDITION(CONF) ; edition from config with safe default
	N X
	S X=$$LC($G(CONF("efuzy","edition")))
	I X="" S X="standard"
	Q X
	;
RELEASEID(CONF) ; release identifier
	Q $$APP()_"-"_$$EDITION(.CONF)_"-"_$$VERSION()
	;
INFO(CONF,RES) ; populate release metadata
	K RES
	S RES("ok")=1
	S RES("app")=$$APP()
	S RES("name")=$$NAME()
	S RES("version")=$$VERSION()
	S RES("series")=$$SERIES()
	S RES("scheme")=$$SCHEME()
	S RES("channel")=$$CHANNEL()
	S RES("edition")=$$EDITION(.CONF)
	S RES("release_id")=$$RELEASEID(.CONF)
	S RES("built_at")=$$NOWISO^MIOUTIL()
	S RES("artifacts",1)="source_archive"
	S RES("artifacts",2)="release_manifest"
	S RES("artifacts",3)="checksums"
	S RES("artifacts",4)="release_notes"
	Q
	;
WRITE(CONF,PATH,RES) ; write plain-text release manifest
	N META
	K RES
	D INFO(.CONF,.META)
	O PATH:(newversion:stream:nowrap:writeonly):1 E  S RES("ok")=0,RES("error")="manifest_open_failed",RES("path")=PATH Q 0
	U PATH
	W "app="_$G(META("app")),!
	W "name="_$G(META("name")),!
	W "version="_$G(META("version")),!
	W "series="_$G(META("series")),!
	W "scheme="_$G(META("scheme")),!
	W "channel="_$G(META("channel")),!
	W "edition="_$G(META("edition")),!
	W "release_id="_$G(META("release_id")),!
	W "built_at="_$G(META("built_at")),!
	W "artifact_1="_$G(META("artifacts",1)),!
	W "artifact_2="_$G(META("artifacts",2)),!
	W "artifact_3="_$G(META("artifacts",3)),!
	W "artifact_4="_$G(META("artifacts",4)),!
	C PATH
	S RES("ok")=1,RES("path")=PATH M RES("meta")=META
	Q 1
	;
REQFILE(PATH) ; simple file existence check
	O PATH:(readonly:stream:nowrap):1 E  Q 0
	C PATH
	Q 1
	;
VERIFY(ROOT,RES) ; verify minimum release inputs under repo root
	N MISS,N
	K RES
	S RES("ok")=1,N=0
	I '$$REQFILE($G(ROOT)_"/README.md") S N=N+1,RES("missing",N)="README.md"
	I '$$REQFILE($G(ROOT)_"/CHANGELOG.md") S N=N+1,RES("missing",N)="CHANGELOG.md"
	I '$$REQFILE($G(ROOT)_"/VERSION") S N=N+1,RES("missing",N)="VERSION"
	I '$$REQFILE($G(ROOT)_"/scripts/install_efuzy.sh") S N=N+1,RES("missing",N)="scripts/install_efuzy.sh"
	I '$$REQFILE($G(ROOT)_"/docs/RELEASE_ENGINEERING.md") S N=N+1,RES("missing",N)="docs/RELEASE_ENGINEERING.md"
	I N>0 S RES("ok")=0,RES("error")="release_inputs_missing"
	S RES("root")=$G(ROOT)
	Q +$G(RES("ok"))
	;
LC(X)
	Q $ZCONVERT($G(X),"L")
	;
