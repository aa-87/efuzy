EFUWFOUT ; output send/download helpers
 ;
 Q
 ;
SEND(DEV,CONF,JOBID,CTX,ERR)
 N PATH,NAME,HEAD
 K ERR
 S PATH=$G(^MIO("EFUZY","job",+JOBID,"outputPath"))
 I PATH="" S ERR("error")="output_path_missing" Q 0
 S NAME=$G(^MIO("EFUZY","job",+JOBID,"outputName"))
 I NAME="" S NAME="efuzy-export-"_JOBID_".csv"
 S HEAD("Content-Type")="text/csv; charset=utf-8"
 S HEAD("Content-Disposition")="attachment; filename="""_NAME_""""
 Q $$SENDFILE^MIOHTTP(.DEV,.CONF,PATH,.HEAD,$G(CTX("request_id")),.CTX,"GET")
 ;
