/* Upload a file to CMS. */
Trace C
Parse arg InputFile Userid CmsFn CmsFt .
If CmsFn = '' then ,
	Parse upper value Substr(InputFile, LastPos('/', InputFile)+1) with CmsFn '.' CmsFt

'rm /tmp/cardfile 2>/dev/null'

Signal on Error

Call CharOut '/tmp/header', Left('USERID' Userid 'NAME' CmsFn CmsFt, 80)
Call CharOut '/tmp/header', Left(':READ' CmsFn CmsFt, 80)
Call LineOut '/tmp/header'
'iconv -f cp819 -t cp1047 < /tmp/header > /tmp/cardfile'

'cat' InputFile '>> /tmp/cardfile'

Address SYSTEM 'herccontrol --mark' with output stem Marker.
'netcat -q 0 localhost 3505 < /tmp/cardfile'
'herccontrol -w "HHCRD012I" -f "' || Marker.1 || '"'
'herccontrol "/" -w "RDR FILE"'
'herccontrol "/READ *" -w "^Ready;"'
Drop Marker.

'rm /tmp/header /tmp/cardfile'

Exit 0


Error:
Say 'Error' RC 'in line' SigL':' SourceLine(SigL)
Exit RC
