/* Update CMS so we can build and test Plunger. */

Signal On Error
Trace C

WorkDir = '~/cms_update_work'
DownloadDir = WorkDir || '/downloads'
UploadDir = WorkDir || '/uploads'

/* Detach some devices so we can reconfigure them.  Do this now, so they stabilize before the "attach"es. */
'herccontrol "detach 9f0"'
'sleep 5'	/* Because "detach" is timing-related and may respond variously :-( */

'mkdir' WorkDir DownloadDir UploadDir

/* Download each update we need. */
/*        Groups.io only allows logged-in members to download files, so we'll used copies Ross saved instead :-( */
'cd' DownloadDir '; wget -nv -O "hrc100ds_v2.vmarc" "https://www.dropbox.com/scl/fi/maa0nughdkz4e9fc6prpu/hrc100ds_v2.vmarc?rlkey=vkj0l624g5qkz8v4fih564d4b&dl=0"'
'cd' DownloadDir '; wget -nv -O "hrc405ds_v4.vmarc" "https://www.dropbox.com/scl/fi/hozx45wcrlx2o7se843ig/hrc405ds_v4.vmarc?rlkey=g5qx2grqiktqd3uzprvf01bz3&dl=0"'
'cd' DownloadDir '; wget -nv -O "hrc422ds.vmarc" "https://www.dropbox.com/scl/fi/ej7418pmklk1kusn4iqs1/hrc422ds.vmarc?rlkey=7m8q0bm0w4klumss4llqku2n7&dl=0"'
'cd' DownloadDir '; wget -nv -O "rap016ds.vmarc" "https://www.dropbox.com/scl/fi/n36o850g3t6y0ovak05ju/rap016ds.vmarc?rlkey=50oiyap2qigd7mdk2ydj5ep04&dl=0"'
'cd' DownloadDir '; wget -nv -O BREXX.zip "https://github.com/RossPatterson/CMS-370-BREXX/releases/download/v1.2.0/BREXX.zip"'
'cd' DownloadDir '; mv hrc100ds_v2.vmarc hrc100ds.vmarc'
'cd' DownloadDir '; mv hrc405ds_v4.vmarc hrc405ds.vmarc'
'cd' DownloadDir '; mv *.vmarc' UploadDir
'cd' DownloadDir '; unzip -j BREXX.zip BREXX/gccbrx.cckd ; mv gccbrx.cckd' UploadDir
'cd' DownloadDir '; rm BREXX.zip'

/* Install the latest gccbrx.cckd disk image for bREXX. */
'mv' UploadDir || '/gccbrx.cckd /opt/hercules/vm370/'
'herccontrol "attach 9f0 3350 gccbrx.cckd ro" -w "HHCDA020I"'

/* IPL VM/370 */
'herccontrol "ipl 6a1" -w "USER DSC LOGOFF AS AUTOLOG1"'
'herccontrol "/CP START 00C" -w "RDR"'
'herccontrol "/CP START 00D CLASS A" -w "PUN"'

/* Log on as MAINT */
'herccontrol "/CP DISCONN" -w "^VM/370 Online"'
'herccontrol "/LOGON MAINT CPCMS NOIPL"'
'herccontrol "/SPOOL CONSOLE START TO * CLASS Q"'
'herccontrol "/DEFINE STORAGE 16M" -w "^STORAGE ="'
'herccontrol "/IPL CMS" -w "^VM Community Edition"'
'herccontrol "/" -w "^Ready;"'
'herccontrol "/SET EMSG ON" -w "^Ready;"'

/* Redeploy GCCLIB and bREXX from the new DASD file. */
'herccontrol "/NEWBREXX" -w "^Ready;"'
'herccontrol "/IPL 190 CLEAR" -w "^VM Community Edition"'
'herccontrol "/SAVESYS CMS" -w "^VM Community Edition"'
'herccontrol "/IPL CMS" -w "^VM Community Edition"'
'herccontrol "/ACCESS (NOPROF" -w "^Ready;"'
'herccontrol "/GCCSEG F20000" -w "^Ready;"'

'herccontrol "/IPL CMS" -w "^VM Community Edition"'
'herccontrol "/" -w "^Ready;"'
'herccontrol "/VMSETUP CMS" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/COPY GCCSEG MAP A = = F2 (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ERASE GCCSEG MAP A" -w "^Ready;"'
'herccontrol "/ACCESS 093 F/A" -w "^Ready;"'

/* Make a temporary disk to hold the update tools. */
'herccontrol "/RELEASE A" -w "^Ready;"'
'herccontrol "/DEFINE T3350 281 30" -w "^Ready;"'
'herccontrol "/FORMAT 281 A" -w "FORMAT WILL ERASE ALL FILES ON DISK .A.281.."'
'herccontrol "/YES" -w "ENTER DISK LABEL"'
'herccontrol "/TMP281" -w "^Ready;"'

'cd cms_update/tools ; vma -a -c -m0 -t' UploadDir || '/updtools.vmarc *'
'rexx ./cms_update/upload_file.rexx' UploadDir || '/updtools.vmarc "MAINT"'
'herccontrol "/VMARC UNPK UPDTOOLS VMARC A * * A (OLDDATE" -w "^Ready;"'
'herccontrol "/ERASE UPDTOOLS VMARC A" -w "^Ready;"'
'herccontrol "/ACCESS 281 B" -w "^Ready;"'

/* Make a temporary disk to run the update process. */
'herccontrol "/DEFINE T3350 282 30" -w "^Ready;"'
'herccontrol "/FORMAT 282 A" -w "FORMAT WILL ERASE ALL FILES ON DISK .A.282.."'
'herccontrol "/YES" -w "ENTER DISK LABEL"'
'herccontrol "/TMP282" -w "^Ready;"'

/* Upload the updates to CMS and unpack them. */
'herccontrol "/EXECIO 1 DISKW _ASMALL EXEC B (FINIS STRING *" -w "^Ready;"'
'herccontrol "/COPY _ASMALL EXEC B (RECFM F LRECL 80 REPLACE OLDDATE" -w "^Ready;"'
Call UploadAndUnpack UploadDir || '/hrc405ds.vmarc', 'MAINT', 'NUCEXT and SUBCOM macro and function fixes.'
Call UploadAndUnpack UploadDir || '/hrc422ds.vmarc', 'MAINT', 'NUCXTEXT occasionally causes DMSLIO109S.'
Call UploadAndUnpack UploadDir || '/hrc100ds.vmarc', 'MAINT', 'In-storage EXEC and FBLOCK support.'
Call UploadAndUnpack UploadDir || '/rap016ds.vmarc', 'MAINT', 'BALR to TYPLIN through ADMSCWR.'

/* Now everything is unpacked to F and A is empty. */

/* Reuild the CMSHRC macro library, move it to F and S (as Z), and then erase it from A. */
'herccontrol "/VMFMAC CMSHRC DMSHRC" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/COPY CMSHRC MACLIB A = = F  (OLDD REPLACE" -w "^Ready;"'
'herccontrol "/COPY CMSHRC COPY   A = = F  (OLDD REPLACE" -w "^Ready;"'
'herccontrol "/ACCESS 093 F/A" -w "^Ready;"'
'herccontrol "/ACCESS 190 Z" -w "^Ready;"'
'herccontrol "/COPY CMSHRC MACLIB A = = Z2 (OLDD REPLACE" -w "^Ready;"'
'herccontrol "/RELEASE Z" -w "^Ready;"'
'herccontrol "/ACCESS 290 Z" -w "^Ready;"'
'herccontrol "/COPY CMSHRC MACLIB A = = Z2 (OLDD REPLACE" -w "^Ready;"'
'herccontrol "/RELEASE Z" -w "^Ready;"'
'herccontrol "/ERASE CMSHRC * A" -w "^Ready;"'

/* Assemble all the modified source files and copy the TEXT files to F and S (as Z). */
/* TODO: Is there a way to ensure that every package follows the "update if macro changed" rule? */
'herccontrol "/_ASMALL EXEC VMFASM DMSHRC" -w "^Ready;"'
'herccontrol "/_RNMTXTS" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/_ASMALL COPY % TEXT A = = F (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ACCESS 093 F/A" -w "^Ready;"'
'herccontrol "/ACCESS 190 Z" -w "^Ready;"'
'herccontrol "/_ASMALL COPY % TEXT A = = Z (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/RELEASE Z" -w "^Ready;"'
'herccontrol "/ACCESS 290 Z" -w "^Ready;"'
'herccontrol "/_ASMALL COPY % TEXT A = = Z (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/RELEASE Z" -w "^Ready;"'

/* Update CMSLOAD EXEC with new/updated ASSEMBLE files. */
/* TODO: Can we really just assume that an ASSEMBLE file that isn't in _GENMODS DATA goes at the end of the nucleus? */
'herccontrol "/_UPDLL _ASMALL EXEC B CMSLOAD EXEC A" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/COPY CMSLOAD EXEC A = = F2 (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ACCESS 093 F/A" -w "^Ready;"'

/* Build all the modified MODULE files and move them to the S-disk. */
'herccontrol "/_GENMODS" -w "^Ready;"'
'herccontrol "/LISTFILE * MODULE A ( EXEC" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/EXPLOIT COPY &FN &FT A = = F2 (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ACCESS 093 F/A" -w "^Ready;"'
'herccontrol "/ACCESS 190 Z" -w "^Ready;"'
'herccontrol "/EXPLOIT COPY &FN &FT A = = Z2 (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/RELEASE Z" -w "^Ready;"'
'herccontrol "/ACCESS 290 Z" -w "^Ready;"'
'herccontrol "/EXPLOIT COPY &FN &FT A = = Z2 (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/RELEASE Z" -w "^Ready;"'

/* Build and install the CMS nucleus.
   This will re-IPL the MAINT VM a few times.
*/
'herccontrol "/RELEASE A (DET" -w "^Ready;"'
'herccontrol "/RELEASE B (DET" -w "^Ready;"'
'herccontrol "/ACCESS 191 A" -w "^Ready;"'
'herccontrol "/ACCESS 5E5 B/B" -w "^Ready;"'
'herccontrol "/VMSETUP CMS" -w "^Ready;"'

'rexx "./cms_update/install_nucleus.rexx" "190" "59" "CMS" "VM Community Edition V1 R1.2+"'
'herccontrol "/IPL CMS" -w "^VM Community Edition"'
'herccontrol "/" -w "^Ready;"'
'herccontrol "/VMSETUP CMS" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/COPY CMS MAP A = = F (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ERASE CMS MAP A" -w "^Ready;"'

'rexx "./cms_update/install_nucleus.rexx" "290" "59" "CMSTEST" "VM Community Edition V1 R1.2+"'
'herccontrol "/IPL CMSTEST" -w "^VM Community Edition"'
'herccontrol "/" -w "^Ready;"'
'herccontrol "/VMSETUP CMS" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/COPY CMSTEST MAP A = = F (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ERASE CMSTEST MAP A" -w "^Ready;"'

/* Shut VM down. */
/* 'herccontrol "/LOGOFF" -w "^VM/370 Online"' */
'herccontrol "/LOGOFF" -w "Online"'
'herccontrol "/LOGON OPERATOR OPERATOR" -w "RECONNECTED AT"'
'herccontrol "/SHUTDOWN" -w "^HHCCP011I"'

Exit 0


Error:
Say 'Error' RC 'in line' SigL':' SourceLine(SigL)
Exit RC


UploadAndUnpack: Procedure
Parse arg InputFile, Userid, Description
Parse upper value Substr(InputFile, LastPos('/', InputFile)+1) with PackageFn '.' 

/* Upload the VMARC file. */
'rexx ./cms_update/upload_file.rexx' InputFile Userid

/* Unpack and  clean up source, and make AUXHRC files. */
'herccontrol "/VMARC UNPK' PackageFn 'VMARC A * * A (OLDDATE" -w "^Ready;"'
'herccontrol "/ERASE' PackageFn 'VMARC A" -w "^Ready;"'
'herccontrol "/_FIXSRC" -w "^Ready;"'
'herccontrol "/_MAKEAUX' Description || '" -w "^Ready;"'

/* Copy all files to CMS HRC disk. */
'herccontrol "/LISTFILE * * A ( EXEC FTYPE" -w "^Ready;"'
'herccontrol "/ACCESS 093 F" -w "^Ready;"'
'herccontrol "/EXPLOIT COPY &FN &FT A = = F (OLDDATE REPLACE" -w "^Ready;"'
'herccontrol "/ACCESS 093 F/A" -w "^Ready;"'

/* Update CMSHRC COPY with new/updated COPY and MACRO files. */
'herccontrol "/_UPDMACS CMSHRC EXEC B" -w "^Ready;"'

/* Update _ASMALL EXEC with new/updated ASSEMBLE files. */
'herccontrol "/_UPDASMS _ASMALL EXEC B" -w "^Ready;"'

/* Clear the work disk for the next set of files. */
'herccontrol "/ACCESS 282 A (ERASE" -w "^Ready;"'

Return

