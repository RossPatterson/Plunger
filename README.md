# _CMS Pipelines_ Support for VM/370 Community Edition

_PLUNGER clears the clogs and makes PIPEs run clean!_

_Plunger_ is a CMS command that, combined with the _CMS Pipelines Runtime
Distribution_, makes _CMS Pipelines_ work on the [_VM/370 Community
Edition_](https://www.vm370.org/vm), a derivative of IBM's VM/370 Release 6
system.

## Contents

* [Overview](#overview)
* [Pre-requisites](#pre-requisites)
* [Installation](#installation)
* [Notes](#notes)
* [Plunger code](#plunger-code)
* [Plunger command](#plunger-command)
* [Licenses](#licenses)

## Overview

Many years ago, John Hartmann of IBM Denmark created a tool he called "_CMS
Pipelines_" (or just "_Pipelines_" or "_Pipes_").  Some years later, IBM
allowed its customers to obtain _Pipelines_, and the VM community, centered
around the SHARE user group, and with tremendous work by Princeton University's
Melinda Varian, adopted it with gusto.  Even more years later, IBM and
Princeton reached
[an agreement](#cms-pipelines-runtime-library-distribution-license) to allow
Princeton to re-distribute certain specific _Pipelines_ files and to allow
those who received them to further re-distribute them.  This is called the _CMS
Pipelines Runtime Library Distribution_, and the files include everything a CMS
user would need to create and run _Pipelines_ programs.  Quite a few times in
the following years, IBM and Princeton updated the _CMS Pipelines Runtime
Library Distribution_ to a then-more-recent version, and for the last time on
2015-07-30.  At some time along the way, the distribution point moved from a
Princeton web and FTP site to one operated by Marist University.

_CMS Pipelines_ was designed with certain baseline assumptions, including that
the CMS operating system was at least VM/SP.  It was carefully built to widely
support VM releases newer than that, and rarely removed support for older
releases.  The _VM/370 Community Edition_ is based on VM/370 Release 6, which
lacks quite a few of those assumptions.  _Plunger_ fills those gaps.  Building
upon facilities that many people added to VM/370 R6 over the years (_e.g._, in
the "Six-pack" and "Community Edition" releases), _Plunger_ makes _Pipelines_
believe it is running in VM/SP CMS, and provides services that _Pipelines_
expects to exist there.

## Pre-requisites
  * VM/370 Community Edition 1.1.2
    * or a VM/370 R6 with at least the following updates:
      * HRC015DS - Prevent UPDATE from failing when the filesystem API is
        updated
      * HRC105DS - Extend FSTD/STATEFST for greater compatability with VM/SP
     * more?
  * HRC100DS - Add EXEC-in-storage support.  (Needed by the Rexx-related
    stages).
  * HRC405DS - Fix several with nucleus extensions.
  * HRC422DS - NUCXTEXT occasionally causes DMSLIO109S.
  * RAP016DS - BALR to TYPLIN through ADMSCWR. (Needed by the CMS stage,
    and maybe others).
  * bREXX version 1.2.0 or higher - support for in-storage Rexx programs.
    (Needed by the Rexx-related stages.)
  * more?

## Installation

1. Get the distribution files from the [_CMS Pipelines Runtime Library
Distribution_](http://vm.marist.edu/~pipeline/index.html#Runtime). You want the
"All executables" and "All documentation" archive (_i.e_, `VMARC`) files.

1. Get the _Plunger_ package from
[GitHub](https://github.com/RossPatterson/Plunger/releases).

1. Upload the `RUNTIME VMARC` and `PLUNGER VMARC` files to CMS in binary as
RECFM F and LRECL 80.

1. Extract the `PIPELINE MODULE` file from the `RUNTIME VMARC` package:
   ```
   VMARC UNPACK RUNTIME VMARC fm PIPELINE MODULE fm (OLDDATE
   ```

1. Extract the `PLUNGER MODULE` file from the `PLUNGER VMARC` package:
   ```
   VMARC UNPACK PLUNGER VMARC fm PLUNGER MODULE fm (OLDDATE
   ```

1. Optionally see the
[Pipelines documentation note](#pipelines-documentation) below about
documentation.

1. Optionally build and deploy the _CMS Pipelines_ HELP files.  See the
[Pipelines HELP note](#pipelines-help) for the process to do so.

## Notes

### Pipelines documentation
_CMS Pipelines_ has extensive documentation.  All of it is available in the
_CMS Pipelines Runtime Library Distribution_, in the `RTDOC VMARC` file.
Unfortunately, that file is too large to store as-is on VM/370 CMS.  The
`PLUNGER VMARC` package includes a Microsoft Windows script file,
`splitdoc.bat`, that will read `RTDOC VMARC` and create two subset files.  The
script requires `vma.exe` from Leland Lucius's excellent
[VMARC Utility](https://www.homerow.net/zvm/vma/) for Windows and MacOS, which
frankly every CMS user ought to have.  The `RTDOC1 VMARC` package contains
documentation that will probably only be useful on a non-CMS system (_i.e._,
PDF and Postscript files) - in particular, Hartmann's "_CMS Pipelines
User's Guide and Reference_" (as `PIPELINE.PDF`).  The `RTDOC2 VMARC` package
contains all the other files, and can be uploaded to CMS and unpacked.

### Pipelines HELP
_CMS Pipelines_ has a collection of almost 1,400 HELP files (approximately 15
3350 cylinders), documenting each comand (`HELPCMS`), stage (`HELPPIPE`),
subcommand (`HELPPIPC`), syntax element (`HELPPIPS`), and message (`HELPMSG`).
All of it is available in the _CMS Pipelines Runtime Library Distribution_, in
the `RUNTIME VMARC` package, but it must be extracted and installed to
useful on VM/370. The process to do so is documented at the
[_CMS Pipelines Runtime Distribution_ website](http://vm.marist.edu/~pipeline/install.html),
and the following recommended procedure is based upon it:

1. Extract the necessary files from the `RUNTIME VMARC` and `PLUNGER VMARC`
packages:

   ```
   VMARC UNPACK RUNTIME VMARC fm HLIB2HIN REXX     fm (OLDDATE
   VMARC UNPACK RUNTIME VMARC fm PIPELINE HELPLIB  fm (OLDDATE
   VMARC UNPACK RUNTIME VMARC fm PIPGHELP EXEC     fm (OLDDATE
   VMARC UNPACK RUNTIME VMARC fm PIPGHELP REXX     fm (OLDDATE
   VMARC UNPACK RUNTIME VMARC fm PIPMENU  REXX     fm (OLDDATE

   VMARC UNPACK PLUNGER VMARC fm PIPE     HELPTASK fm (OLDDATE
   ```

1. Make a minor change to `PIPGHELP EXEC`, because the _VM/370 Community
   Edition_ `HELP` command doesn't support SCRIPT-like control words:

   * Insert the following line after original line 65:
   ```rexx
          'nfind .|',                        /* No  control words */
   ```

1. Make a few minor changes to `PIPGHELP REXX`, because the _VM/370 Community
   Edition_ `HELP` command doesn't support `HELPMENU` files or related help:

   *  Insert the following line after original line 55:
   ```rexx
    wmenu=''           /* VM/370 CE doesn't have menu files */
   ```

   *  Insert the following line after original line 50:
   ```rexx
    append = ''             /* VM/CE doesn't have "related" */
   ```

   *  Insert the following lines after original line 33:
   ```rexx
      /* Some don't have a mode number.  Dunno why. */
      if \datatype(mode_number, 'W') then do
     parse var in . fn ft systems
     mode_number = ''
      end
   ```

1. Extract the HELP-file data from `PIPELINE HELPLIB`:
   ```
   PIPE HLIB2HIN | > PIPELINE HELPIN fm FIXED
   ```

1. Generate the HELP files on your A-disk:
   ```
   PIPGHELP % NOTEXT
   ERASE PIPELINE HELPIN fm
   ```

1. Make the generated files available to the VM/370 HELP system:
   ```
   RENAME * HELPCMS A = HELP$CM =
   COPY HELP HELPTASK U = = A
   COPY PIPE HELPTASK A HELP HELPTASK A (APPEND
   ```

1. Move the generated files and the updated `HELP HELPTASK` file to a minidisk
where CMS users can accessthem (_e.g._, the CMS `MAINT 19D` HELP disk).

1. Optionally, delete all the files extracted in the first step:
   ```
   ERASE HLIB2HIN REXX     fm
   ERASE PIPELINE HELPLIB  fm
   ERASE PIPGHELP EXEC     fm
   ERASE PIPGHELP REXX     fm
   ERASE PIPMENU  REXX     fm
   ERASE PIPE     HELPTASK fm
   ```

## _Plunger_ code

_Plunger_ provides a collection of services that _CMS Pipelines_ requires and
that _VM/370 Community Edition_ does not offer. That includes:

* `ABNEXIT` macro functions - just `ABNEXIT SET` and `ABNEXIT CLR`.
* `CMSCALL` SVC - basic support to map `CMSCALL` macros to CMS's SVC 202.
* `DMSFNSMC` - a (presumed) synonym for `FINIS`
* `ESPIE` SVC - basic support to map the MVS `ESPIE` macro to the OS/360 (and
CMS) `SPIE` macro.
* `FORM=E` disk I/O macro functions - just remapping plists, not expanding
limits.  Specifically, `EPOINT`, `ESTATE`, `ESTATEW`, `RDBUF`, and `WRBUF`
* EXEC in storage functions - a front-end to the `EXEC` command, and the
`EXECLOAD`, `EXECDROP`, `EXECMAP`, and `EXECSTAT` commands.
* `GLOBALV` command - a very limited implementation, just enough for Pipelines'
use cases.
* `LINERD` function - basic support to map `LINERD` macros into `RDTERM`
equivalents.
* `WAITRD` function - map an undocumented use of the `RDTERM` macro to
`EDIT=NO`.
* Several instructions that Pipelines depends on but that are not part of
System/370.  These are implemented as their necessity is discovered, and
currently include `AHI` (A7xA), `BRC` (A7x4), `BSM` (0B), and `CHI` (A7xE).

_Plunger_ also modifies several parts of the _CMS Pipelines_ code in memory,
altering them while it loads `PIPELINE MODULE` as a nucleus extension.  In
general, _Plunger_ tries to avoid this technique, but there are things that
simply can't be "faked out" with shims and remappings.  All these patches, and
the code that applies them, are in the `PLUZAP ASSEMBLE` source file, in a form
that anyone familiar with the CMS `ZAP` command should understand.  The current
list of ZAPs is:
* `ZAP001` - Suppress message _FPLINY1291I The field ADMSCWR in NUCON is
incorrect; found 00F8C158; display of ABEND information may be in jeopardy._
* `ZAP003` - Relocate `NUCMFLAG` in CMS `NUCON`.  See
https://github.com/s390guy/vm370/issues/97 for details.
* `ZAP004` - Set the "VM/SP" bit in `DIAG x'0000'`.
* `ZAP005` - PIPELINE uses a filesystem workarea called `FVS`, but it expects a
newer version than VM/370 CE's
* `ZAP006` - PIPELINE calls RENAME (NOUPDIR, but VM/370 R6 expects (NOUPDIRT.
* `ZAP007` - Bypass DMSEXC when calling Rexx stages (pre-dates CMS update
HRC100DS).

## `PLUNGER` command

`PLUNGER MODULE` is a self-loading nucleus extension.  It sets itself up in
memory the first time a `PLUNGER` command is issued.

* `PLUNGER VERSION` - display the version number and build date and time.
* `PLUNGER DEBUG [ON|OFF]` - display and possibly change the debugging status.
* `PLUNGER ENABLE' - enable all the services and load and initialize _CMS
Pipelines_.
* `PLUNGER DISABLE` - disable all the services and unload _CMS Pipelines_.

`PLUNGER` also responds to ABEND and `NUCXDROP` situations via the `SERVICE`
nucleus extension option.

## Licenses

The _CMS Pipelines Runtime Distribution_ and _Plunger_ are released under
separate and very different licenses.  Use of either of them is bound by its
specific license.

### CMS Pipelines Runtime Library Distribution license

See http://vm.marist.edu/~pipeline/tandc.html for the specific terms and
conditions related to distributing the _CMS Pipelines Runtime Library
Distribution_.  The remainder of this section is provided as courtesy for
_Plunger_ users, and does not supercede or replace thoe terms and conditions.

Melinda Varian of Princeton University, in her paper
["_Pipe Dreams - What's New in CMS/TSO Pipelines_"](http://vm.marist.edu/~pipeline/pipdream.pdf)
presented at the 1996 VM Workshop, wrote this (pp. 2-3):

>**III. DISTRIBUTION OF THE CMS PIPELINES RUNTIME LIBRARY**
>
>In May, 1993, SHARE submitted a requirement to IBM stating, "Applications
written in _CMS Pipelines_ should be permitted to ship the _Pipelines_ runtime
library with the applications, to unlicensed parties. This ability exists for
most languages." Three months later, IBM closed that requirement as
"announced", but did not say how one could go about actually shipping _Pipes_
with a software product without getting sued.
>
>IBM and Princeton recently signed a software license agreement that allows
Princeton to redistribute the December, 1995, version of the _CMS Pipelines_
runtime library royalty-free to anybody and that also allows people who get the
version from Princeton to redistribute it themselves royalty-free.  In other
words, we can all now package a recent version of the _CMS Pipelines_ runtime
library with our software products, including shareware, so there is no reason
not to use the recent version in one's software.  Note, however, that there is
**no** official support for this version.  You are likely to get help if you
report any problems in one of the _Pipelines_ fora, but there is no guarantee
of that.
>
>The _CMS Pipelines_ runtime library distribution is available via the World
Wide Web (http://PUCC.Princeton.EDU/~pipeline/) or by anonymous FTP from
PUCC.Princeton.EDU (cd anonymous.376).  You will find a README FIRST file that
stipulates the conditions, which are primarily that you must not remove the IBM
copyright notice and that IBM retains title to the _CMS Pipelines_ runtime
library being distributed.  (An excerpt from this README file is in Appendix
A.) The files that make up the runtime library include the MODULE, the help
library, and softcopy documentation (in LIST3820 and BOOK format).  There is no
separate message repository, as the messages are included in the MODULE file.
This version of the runtime library contains function well beyond what was
shipped in CMS 12, but it does not include MVS-specific function or IBM
Internal-Use-Only function, such as the `pattern` stage.
>
>The document contained in the BOOK and LIST3820 files is what is known
familiarly as "the real _Pipes_ book", the _CMS/TSO Pipelines Guide and
Reference_ written by the author of Pipelines, John Hartmann.  It
provides complete documentation for the version of _Pipelines_ shipped in
CMS 12 and in BatchPipeWorks.

Melinda continued in Appendix A of that paper, with what appears to be a
verbatim quote of the terms and conditions (see p. 64):

> **CMS PIPELINES RUNTIME LIBRARY DISTRIBUTION**
> This distribution of the _CMS Pipelines_ runtime library has been made
available in response to SHARE requirement SOCMSX93003, which requested IBM's
permission for software vendors (including shareware vendors) to package a
current version of the _CMS Pipelines_ runtime library with their software
products in order that they could use new features of "_Pipes_" in their
products.
>
>Questions concerning this distribution may be addressed to Melinda Varian
(Melinda@Princeton.EDU).
>
> **_Terms and Conditions_**
>
> IBM and Princeton University have signed a Software License Agreement (Number
07227), which contains the following provisions:
>
>* 3.1 IBM hereby grants to Princeton a nonexclusive, royalty free, worldwide
right to use,  reproduce, copy, execute, display, perform, prepare and/or have
prepared derivative works to the Licensed Works, to distribute internally
and/or externally for any purpose whatsoever and to sublicense (royalty free
only) and authorize others to do and/or exercise any, some or all of the
foregoing, including the right to further sublicense others. The rights granted
in this Section 3.1 are hereinafter called "Rights Granted".
>
>* 4.0 Princeton acknowledges that title to the Licensed Works shall remain
with IBM and that any copies of the Licensed Works or portions thereof made by
Princeton in accordance with the Rights Granted hereunder shall include an IBM
copyright notice thereon. The notice shall be affixed to all copies or portions
thereof in such manner and location as to give reasonable notice of IBM's claim
of copyright and shall be in conformity with all applicable regulations or
affixation prescribed by the United States Register of Copyright. Princeton
agrees to inform any licensee and/or sublicensee will conform to the
requirements of this Section.
>
>* Appendix A: Description of Licensed Works
>
>  Code Files: NXPIPE MODULE, PIPELINE HELPLIB
>
>  Documentation: PIPELINE LIST3820, PIPELINE BOOK
>
> **Support**
>
>There is no official support for the code and documentation included in this
distribution. If you experience a problem with the code or documentation,
please report it on one of the _Pipelines_ fora:
>* PROB PIPELINE on VMSHARE
>* PIPELINE CFORUM on IBMLink
>* CMSPIP-L LISTSERV list
>
>You will likely receive assistance, but there are no guarantees.

Melinda Varian retired several years ago, and you probably shouldn't try to
contact her at that Princeton email address.

### _Plunger_ license

_Plunger_ itself is free and unencumbered software and is released into the
public domain.  The specific licensing text _Plunger_ uses to do this is
[The Unlicense](https://unlicense.org), which is contained as file
`UNLICENSE.txt` in the `PLUNGER VMARC` package, and which you can and should
read in its (brief) entirety.
