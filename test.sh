#!/usr/bin/bash
# Test Plunger

# Exit if there is an error
set -e

# Show the commands
set -x

# Say how we were called.
VERSION_STRING="$1"
BUILD_DATE="$2"
BUILD_TIME="$3"
EXITRC=1

DOWNLOADS=~/build_work/downloads
UPLOADS=~/build_work/uploads
mkdir -p $DOWNLOADS $UPLOADS

cd ~/build_work/repo

# Download the CMS Pipelines Runtime Library Distribution.
wget -nv "https://www.dropbox.com/scl/fi/psc0xhg8pcxa6vyct0180/runtime.vmarc?rlkey=sez02fzkkkrz7u12gmuat2kvk&dl=0" -O $DOWNLOADS/runtime.vmarc

# IPL VM/370
herccontrol "IPL 6A1" -w "USER DSC LOGOFF AS AUTOLOG1" -f "$MARKER"
herccontrol "/CP START 00C" -w "RDR"
herccontrol "/CP START 00D CLASS A" -w "PUN"
herccontrol "/CP DISCONN" -w "^VM/370 Online"

# Log on as CMSUSER.  Pipelines needs ECMODE ON, which does a SYSTEM RESET, so set that first.
herccontrol "/LOGON CMSUSER CMSUSER NOIPL" -w "^LOGON AT"
herccontrol "/SET ECMODE ON"	# No response to wait for.
herccontrol "/IPL CMS" -w "^VM Community Edition"
herccontrol "/ACCESS (NODISK" -w "^Ready;"
herccontrol "/PURGE RDR" -w "^Ready;"
herccontrol "/SET EMSG ON" -w "^Ready;"
herccontrol "/ACCESS 191 A (ERASE" -w "^Ready;"

# Upload the Plunger distribution to VM.
rexx ./cms_update/upload_file.rexx $DOWNLOADS/plunger.vmarc "CMSUSER"

# Get the MODULE and the test files from it.
herccontrol "/VMARC UNPK PLUNGER VMARC A PLUNGER  MODULE   A (OLDDATE" -w "^Ready;"
herccontrol "/VMARC UNPK PLUNGER VMARC A REXXUNIT EXEC     A (OLDDATE" -w "^Ready;"
herccontrol "/VMARC UNPK PLUNGER VMARC A *        REXXUNIT A (OLDDATE" -w "^Ready;"
herccontrol "/VMARC UNPK PLUNGER VMARC A WITHSTEM TEXT     A (OLDDATE" -w "^Ready;"
herccontrol "/ERASE PLUNGER VMARC A" -w "^Ready;"

# Upload the CMS Pipelines Runtime Library Distribution to VM.
rexx ./cms_update/upload_file.rexx $DOWNLOADS/runtime.vmarc "CMSUSER"

# Get PIPELINE MODULE from it.
herccontrol "/VMARC UNPK RUNTIME VMARC A PIPELINE MODULE A (OLDDATE" -w "^Ready;"
herccontrol "/ERASE RUNTIME VMARC A" -w "^Ready;"

# Verify we've got the expected build.
rexx -ti > temp_vars <<EOF
/* */
Address SYSTEM 'herccontrol "/PLUNGER VERSION" -w "^Ready;"' with output stem O.
Parse value strip(O.2, 'T', '.') with 'PLUNGER version' version 'dated' build_date build_time
Say 'MY_VERSION_STRING=' || strip(version)
Say 'MY_BUILD_DATE=' || strip(build_date)
Say 'MY_BUILD_TIME=' || strip(build_time)
Exit 0
EOF
. ./temp_vars
if [ "$VERSION_STRING" != "$MY_VERSION_STRING" ] ; then
	echo Wrong version found: $MY_VERSION_STRING
	exit 1
fi
if [ "$BUILD_DATE" != "$MY_BUILD_DATE" ] ; then
	echo Wrong build date found: $MY_BUILD_DATE
	exit 1
fi
if [ "$BUILD_TIME" != "$MY_BUILD_TIME" ] ; then
	echo Wrong build time found: $MY_BUILD_TIME
	exit 1
fi

# Test the project.
herccontrol "/REXXUNIT (TYPE" -w "^Ready;"
EXITRC=0

# Shut VM down.
herccontrol "/LOGOFF" -w "^VM/370 Online"
herccontrol "/LOGON OPERATOR OPERATOR" -w "RECONNECTED AT"
herccontrol "/SHUTDOWN" -w "^HHCCP011I"
exit $EXITRC
