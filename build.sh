#!/usr/bin/bash

#
# Make Plunger on CMS
#

# Exit if there is an error.
set -e

# Show the commands.
set -x

# Install the Pandoc documentation file converter.
apt-get update
apt-get install --no-install-recommends -y pandoc python3-venv

cd ~/build_work/repo

# Make the CMS documentation.
./mkdoc.sh

# Make the source upload.
mv UNLICENSE.txt UNLICENS.memo
vma -a -m0 -t -s asis ~/build_work/gitsrc.vmarc *.*

# IPL VM/370
herccontrol "ipl 6a1" -w "USER DSC LOGOFF AS AUTOLOG1"
herccontrol "/CP START 00C" -w "RDR"
herccontrol "/CP START 00D CLASS A" -w "PUN"
herccontrol "/CP DISCONN" -w "^VM/370 Online"

# Log on as CMSUSER
herccontrol "/LOGON CMSUSER CMSUSER" -w "^VM Community Edition"
herccontrol "/ACCESS (NODISK" -w "^Ready;"
herccontrol "/PURGE RDR" -w "^Ready;"
herccontrol "/SET EMSG ON" -w "^Ready;"
herccontrol "/ACCESS 191 A (ERASE" -w "^Ready;"

# Upload the source to CMS.
rexx ./cms_update/upload_file.rexx ~/build_work/gitsrc.vmarc "CMSUSER"
herccontrol "/VMARC UNPK GITSRC VMARC A * * A (OLDDATE" -w "^Ready;"
herccontrol "/ERASE GITSRC VMARC A" -w "^Ready;"

# Fix the source file formats.  Some of these may fail due to no files, that's OK.
herccontrol "/COPYFILE * ASSEMBLE A (RECFM F LRECL 80" -w "^Ready"
herccontrol "/COPYFILE * COPY     A (RECFM F LRECL 80" -w "^Ready"
herccontrol "/COPYFILE * CNTRL    A (RECFM F LRECL 80" -w "^Ready"
herccontrol "/COPYFILE * MACRO    A (RECFM F LRECL 80" -w "^Ready"

# Compile the code and build the MODULE.
herccontrol "/MKPLUNGE (DEBUG" -w "^Ready;"

# Make the package VMARC file.
# Add all the AUX* and UPD* files to the list of files to package.  LISTFILE
# doesn't have (ARGS, but we just built Plunger, so we've got Pipelines:
herccontrol "/PLUNGER ENABLE"
herccontrol "/PIPE COMMAND LISTFILE * AUX* A (FMODE | APPEND COMMAND LISTFILE * UPD* A (FMODE | INSERT / &1 &2 / BEFORE | INSERT / &3 &4 &5 &6 &7 &8 &9 &10/ AFTER | PAD 80 | >> PKGFILES EXEC A"
herccontrol "/NUCXDROP PLUNGER"
herccontrol "devinit 00d /opt/hercules/vm370/io/plunger.vmarc" -w "^HHCPN098I"
sleep 5	# Because "devinit" is timing-related :-(
herccontrol "/PKGFILES VMARC PACK PLUNGER VMARC A (APPEND NOTRACE" -w "^Ready;"
herccontrol "/PUNCH PLUNGER VMARC A (NOHEADER" -w "^Ready;"
herccontrol "devinit 00d dummy" -w "^HHCPN098I"
sleep 5	# Because "devinit" is timing-related :-(
# Remove the trailing lace card:
truncate -s-80 /opt/hercules/vm370/io/plunger.vmarc

# Export the version string and build info.
# For example:
#	VERSION_STRING=0.1.27
#	BUILD_DATE=04/03/26
#	BUILD_TIME=21.06
rexx -ti >> "$GITHUB_OUTPUT" <<EOF
/* */
Address SYSTEM 'herccontrol "/PLUNGER VERSION" -w "^Ready;"' with output stem O.
Parse value strip(O.2, 'T', '.') with 'PLUNGER version' version 'dated' build_date build_time
Say 'VERSION_STRING=' || strip(version)
Say 'BUILD_DATE=' || strip(build_date)
Say 'BUILD_TIME=' || strip(build_time)
Exit 0
EOF

# Shut VM down.
herccontrol "/LOGOFF" -w "^VM/370 Online"
herccontrol "/LOGON OPERATOR OPERATOR" -w "RECONNECTED AT"
herccontrol "/SHUTDOWN" -w "^HHCCP011I"
