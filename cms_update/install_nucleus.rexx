/* Build a CMS nucleus deck and install it. */
Parse arg SDiskVAddr NucCylNum SavedSysName BannerMsg

Signal on Error
Trace C

'herccontrol "/SPOOL PUNCH * CLASS Z" -w "^Ready;"'
'herccontrol "/PURGE RDR" -w "^Ready;"'
'herccontrol "/SPOOL RDR CLASS Z NOH" -w "^Ready;"'

Address SYSTEM 'herccontrol "/VMFLOAD CMSLOAD DMSLCL" -w "^Ready;"' with output stem O.
If (O.0 <> 4) | (SubWord(O.3, 1, 2) <> 'PUN FILE') then Signal Error
Parse var O.3 'PUN FILE' NucleusFileNum .

'herccontrol "/SPOOL PRT TO * CLASS Y" -w "^Ready;"'
'herccontrol "/ORDER RDR' NucleusFileNum '" -w "^Ready;"'
'herccontrol "/DEFINE STORAGE 16M" -w "^STORAGE ="'

'herccontrol "/IPL 00C CLEAR" -w "^DMSINI606R"'
'herccontrol "/' || SDiskVAddr || '" -w "^DMSINI615R"'
'herccontrol "/19E" -w "^DMSINI607R"'
'herccontrol "/YES" -w "^DMSINI608R"'
'herccontrol "/' || SDiskVAddr || '" -w "^DMSINI609R"'
'herccontrol "/' || NucCylNum || '" -w "^DMSINI610R"'
'herccontrol "/YES" -w "^DMSINI611R"'
'herccontrol "/' || BannerMsg || '" -w "^DMSINI612R"'
'herccontrol "/" -w "^' || BannerMsg || '"'
'herccontrol "/" -w "^Ready;"'

Address SYSTEM 'herccontrol "/#CP CLOSE PRT" -w "^PRT FILE"' with output stem O.
If (O.0 <> 2) | (SubWord(O.2, 1, 2) <> 'PRT FILE') then Signal Error
Parse var O.2 'PRT FILE' NucleusMapFileNum .

'herccontrol "/CLOSE RDR"'
'herccontrol "/SPOOL RDR CLASS Y NOH" -w "^Ready;"'
'herccontrol "/ORDER RDR' NucleusMapFileNum '" -w "^Ready;"'
'herccontrol "/READ' SavedSysName 'MAP A" -w "^Ready;"'

'herccontrol "/IPL' SDiskVAddr 'CLEAR" -w "^' || BannerMsg || '"'
'herccontrol "/SAVESYS' SavedSysName ||'" -w "^' || BannerMsg || '"'
'herccontrol "/" -w "^Ready;"'

Exit 0


Error:
Say 'Error' RC 'in line' SigL':' SourceLine(SigL)
Exit RC