# _CMS Pipelines_ Support for VM/370 Community Edition

_PLUNGER clears the clogs and makes PIPEs run clean!_

_Plunger_ is a CMS command that, combined with the _CMS Pipelines Runtime
Distribution_, makes _CMS Pipelines_ work on the [_VM/370 Community
Edition_](https://www.vm370.org/vm), a derivative of IBM's VM/370 Release 6
system.

The _CMS Pipelines Runtime Distribution_ is graciously provided free of charge
by IBM under a specific set of terms, which you must adhere to if you use it.
See [Licenses](#licenses) below for more information.

## Contents

* [Overview](#overview)
* [Pre-requisites](#pre-requisites)
* [Installation](#installation)
* [Use](#use)
* [Plunger command](#plunger-command)
* [Notes](#notes)
  * [Pipelines documentation](#pipelines-documentation)
  * [Pipelines HELP](#pipelines-help)
  * [Compatibility](#compatibility)
  * [Unsupported stages](#unsupported-stages)
  * [Pipelines MACLIBs](#pipelines-maclibs)
* [Plunger code](#plunger-code)
  * [Release History](#release-history)
* [Licenses](#licenses)
  * [CMS Pipelines Runtime Library Distribution license](#cms-pipelines-runtime-library-distribution-license)
  * [Plunger license](#plunger-license)

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
      * Probably more if you want to run the unit tests.
  * HRC405DS - NUCEXT and SUBCOM macro and function fixes. (Required both to
    build and to run _Plunger_.)
  * HRC422DS - NUCXTEXT occasionally causes DMSLIO109S. (If you want to run the
    unit tests.)
  * RAP016DS - BALR to TYPLIN through ADMSCWR. (Needed by the CMS and COMMAND
    stages, and maybe others).
  * bREXX version 1.2.0 or higher - support for in-storage Rexx programs.
    (Needed by the Rexx-related stages.)

## Installation

1. Get the distribution files from the [_CMS Pipelines Runtime Library
Distribution_](http://vm.marist.edu/~pipeline/index.html#Runtime). You want the
"All executables" and "All documentation" archive (_i.e._, `VMARC`) files.

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

1. Optionally rebuild `PLUNGER MODULE` from source:
   ```
   VMARC UNPACK PLUNGER VMARC fm * * fm (OLDDATE
   MKPLUNGE ( DEBUG
   * or
   MKPLUNGE ( NODEBUG
   ```

## Use

After installation, it is easy to use _CMS Pipelines_.  Issue the `PLUNGER
ENABLE` command to load _Plunger_ and _Pipelines_ into memory, and then issue
`PIPE` commands exactly like the _Pipelines_ documentation says.  To unload
_Plunger_ and _Pipelines_, issue the `NUCXDROP PLUNGER` command.  To unload
only _Pipelines_, issue the `PLUNGER DISABLE` command.

For example:

```
plunger enable
Ready;
pipe literal Hello World! | console
Hello World!
Ready;
```
_Plunger_ is relatively small - about 12KB in memory.  _Pipelines_ is not - it
consumes 1.1MB when loaded.  There are no options to reduce either of these,
so you may need to increase the storage size of some of your CMS virtual
machines to use _Pipelines_.

## `PLUNGER` command

`PLUNGER MODULE` is a small self-loading nucleus extension.  It sets itself up
in memory the first time a `PLUNGER` command is issued.

* `PLUNGER DEBUG [ON|OFF]` - display and possibly change the debugging status.
* `PLUNGER DISABLE` - disable all the services and unload _CMS Pipelines_ from
memory.
* `PLUNGER ENABLE` - enable all the services and load and initialize _CMS
Pipelines_.
* `PLUNGER VERSION` - display the version number and build date and time.

`PLUNGER` also responds to `ABEND` and `NUCXDROP` situations via the `SERVICE`
nucleus extension option.  When dropped, _Plunger_ also drops _Pipelines_.

## Notes

### _Pipelines_ documentation
_CMS Pipelines_ has extensive documentation.  All of it is available in the
_CMS Pipelines Runtime Library Distribution_, in the `RTDOC VMARC` file.
Unfortunately, that file is too large to store as-is on VM/370 CMS.  The
`PLUNGER VMARC` package includes a Microsoft Windows script file,
`splitdoc.bat`, that will read `RTDOC VMARC` and create two subset files.  The
script requires `vma.exe` from Leland Lucius's excellent
[VMARC Utility](https://www.homerow.net/zvm/vma/) for Windows and MacOS, which
frankly every CMS user ought to have.  The `RTDOC1 VMARC` package `splitdoc`
creates contains documentation that will probably only be useful on a non-CMS
system (_i.e._, PDF and Postscript files) - in particular, Hartmann's "_CMS
Pipelines User's Guide and Reference_" (as `PIPELINE.PDF`).  The `RTDOC2 VMARC`
package contains all the other files, and can be uploaded to CMS and unpacked.

### _Pipelines_ HELP
_CMS Pipelines_ has a collection of almost 1,400 HELP files (approximately 15
3350 cylinders), documenting each command (`HELPCMS`), stage (`HELPPIPE`),
subcommand (`HELPPIPC`), syntax element (`HELPPIPS`), and message (`HELPMSG`).
All of it is available in the _CMS Pipelines Runtime Library Distribution_, in
the `RUNTIME VMARC` package, but it must be extracted and installed to be
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
   PLUNGER ENABLE
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
where CMS users can access them (_e.g._, the CMS `MAINT 19D` HELP disk).

1. Optionally, delete all the files extracted in the first step:
   ```
   ERASE HLIB2HIN REXX     fm
   ERASE PIPELINE HELPLIB  fm
   ERASE PIPGHELP EXEC     fm
   ERASE PIPGHELP REXX     fm
   ERASE PIPMENU  REXX     fm
   ERASE PIPE     HELPTASK fm
   ```

### Compatibility

_Plunger_ assumes that _Pipelines_ generally works correctly, and that only
certain issues exist and need correction.  Those issues are almost entirely in
the "system interface" portions of _Pipelines_ - specifically, the _device
driver_ stages, and other areas where _Pipelines_ issues commands to the system
environment (in this case, CMS, CP, or Rexx).  All of the _device driver_
stages have been tested, and either found to work fine, or issues have been
logged and fixed.  In the process of testing the _device drivers_, no _filter_
stages were found to require support from _Plunger_, although no significant
effort was made to test all _filter_ stages.

There is only one known incompatibility with between _Pipelines_ and
_Pipelines_ with _Plunger_, involved in how the main disk I/O drivers (`<`,
`>`, `>>`, `<MDSK`, `>MDSK`, and `>>MDSK`) function.  As _CMS Pipelines_ notes
in the documentation for these stages:

> The fast interface to the file system is bypassed if the bit X'10' is on in
> offset X'3D' of the FST that is exposed by the FSSTATE macro. Products that
> compress files on the fly or in other ways intercept the file system macros
> should turn on this bit to ensure that CMS/TSO Pipelines uses documented
> interfaces only.

Unfortunately, there are cases where even setting that bit (which _Plunger_
does) is not sufficient.  Thus _Plunger_ does what _Pipelines_ suggests in a
companion note:

>  Use `diskslow` if `<mdsk` fails to operate.

 _Plunger_ forces them all to be handled by the `MDSKSLOW` stage.  This causes
 one incompatibility:

   1. The `>` and `>MDSK` stages will now **always** erase their output file
   before starting, if it already exists, even if the stage exits with a non-0
   return code.  The correct behavior would be to check to see if the file
   exists, and if so, "_a utility file is written. When this file has been
   written successfully, the original file is erased and the utility file
   renamed to the specified name._"  This might cause a problem for
   sophisticated pipelines, but it's a small edge-case, and unlikely to cause
   problems in general.

### Unsupported stages

In addition to stages that Pipelines does not intend to work on CMS (_e.g._,
`<mvs`), the following stages are known not to work, and may never work, as
they require support that VM/370 CE CMS and CP do not have:

* `<OE`
* `<SFS`
* `>OE`
* `>>SFS`
* `>>OE`
* `>>SFS`
* `>>SFSSLOW`
* `ACIGROUP`
* `ADRSPACE`
* `AFTFST`
* `ALSERV`
* `DATECONVERT`
* `DEVINFO`
* `DFSORT`
* `DIAGE4`
* `DISKID`
* `FBAREAD`
* `FBAWRITE`
* `FILEDESCRIPTOR`
* `FILETOKEN`
* `HELP`
* `IMMCMD`
* `MAPMDISK`
* `MDISKBLK`
* `MDSKUPDATE`
* `READER`
* `SFSBACK`
* `SFSDIRECTORY`
* `SFSUPDATE`
* `SQLCODES`
* `SQLSELECT`
* `STARMON`
* `STARMSG`
* `STARSYS`
* `STATE`
* `STFLE`
* `STSI`
* `TCPCLIENT`
* `TCPDATA`
* `TCPLISTEN`
* `TRACKREAD`
* `TRACKWRITE`
* `TRFREAD`
* `UDP`
* `VARFETCH`
* `VMC`
* `WAITDEV`
* `XAB`
* `XEDIT`
* `XMSG`

### Pipelines MACLIBs

The _Pipelines_ distribution comes with two assembler-code macro libraries,
`FPLGPI MACLIB` and `FPLOM MACLIB`, which are shipped in the `RUNTIME VMARC`
archive.  Both are in the post-VM/370 `LIBPDS` file format, which VM/370 CMS
cannot process.  Luckily, _Pipelines_ can read them.  If you want to use them,
you will need to convert them yourself.  The following pipeline will do the
job:

```rexx
Arg Fn .                                /* FPLGPI or FPLOM.           */
'PIPE (end ? name FIXMAC)',
   '?listpds' Fn 'MACLIB' ,             /* Get the list of members.   */
   '|chop 8' ,                          /* Just the names, please.    */
   '|mems: fanout' ,                    /* Pass them around.          */
   '|spec /*COPY/ 1 word 1 nextword' ,  /* "name" -> "*COPY name".    */
   '|pad 80' ,                          /* Make it a card.            */
   '|merge: faninany' ,                 /* Receive member contents.   */
   '|> FIXMAC COPY A F 80' ,            /* Write temp file for MACLIB.*/
   '?mems:' ,                           /* Receive member names.      */
   '|members' Fn 'MACLIB' ,             /* Extract the members' data. */
   '|merge:'                            /* Send to FANINANY.          */
```

The you just:

```rexx
PLUNGER ENABLE
FIXMAC FPLname
MACLIB GEN newfilename FIXMAC
ERASE FIXMAC COPY
```

## _Plunger_ code

_Plunger_ provides a collection of services that _CMS Pipelines_ requires and
that _VM/370 Community Edition_ does not offer. That includes:

* `ABNEXIT` macro functions - just `ABNEXIT SET` and `ABNEXIT CLR`, and only
  capturing program-check interruptions.
* `CMSCALL` SVC - basic support to map `CMSCALL` macros to CMS's SVC 202.
* `DMSFNSMC` - a (presumed) synonym for `FINIS`
* `ESPIE` SVC - basic support to map the MVS `ESPIE` macro to the OS/360 (and
CMS) `SPIE` macro.
* `FORM=E` disk I/O macro functions - just remapping plists, not expanding
  limits.  Specifically, `EPOINT`, `ESTATE`, `ESTATEW`, `RDBUF`, and `WRBUF`.
* EXEC-in-storage functions - the `EXECLOAD`, `EXECDROP`, `EXECMAP`, and
  `EXECSTAT` commands and a front-end to the `EXEC` command.  If you have
  installed CMS mod HRC100DS, these will not be enabled, and the HRC100DS
  versions will be used instead.
* `GLOBALV` command - a very limited implementation, just enough for
  _Pipelines_' use cases.
* `LINERD` function - basic support to map `LINERD` macros into `RDTERM`
  equivalents.
* `NUCXLOAD` command - a nearly-complete re-implementation of the VM/SP5 CMS
  `NUCXLOAD` command, including relocation support, but only for `PIPELINE
  MODULE`.  ***This has not been tested with any other MODULE.***
* `WAITRD` function - map an undocumented use of the `RDTERM` macro to
  `EDIT=NO`.
* Several CPU instructions that Pipelines depends on but that are not part of
  System/370.  These are implemented as their necessity is discovered.  The
  list currently includes:
  * `AHI` (A7xA) - Add Halfword Immediate, fully implemented.
  * `BRC` (A7x4) - Branch Relative Conditional, fully implemented.
  * `BSM` (0B) - Branch and Set Mode, implemented to always set 24-bit mode.
  * `CHI` (A7xE) - Compare Halfword Immediate, fully implemented.
  * `LAE` (51) - Load Address Extended, implemented exactly as LA (41).
  * `STAM` (9B) - Store Access Multiple, implemented to always store 0 ("home
    space").

_Plunger_ also modifies several parts of the _CMS Pipelines_ code in memory,
altering them while it loads `PIPELINE MODULE` as a nucleus extension.  In
general, _Plunger_ tries to avoid this technique, but there are things that
simply can't be "faked out" with shims and remappings, or that are trivial
enough to make this the better choice of techniques.  All these patches, and
the code that applies them, are in the `PLUZAP ASSEMBLE` source file, in a form
that anyone familiar with the CMS `ZAP` command should understand.  The current
list of ZAPs is:
* `ZAP001` - Suppress message "_FPLINY1291I The field ADMSCWR in NUCON is
   incorrect; found 00F8C158; display of ABEND information may be in
   jeopardy._"
* `ZAP003` - Relocate `NUCMFLAG` in CMS `NUCON`.  See
  https://github.com/s390guy/vm370/issues/97 for details.
* `ZAP004` - Set the "VM/SP" bit in the CP `DIAG x'0000'` response.
* `ZAP005` - PIPELINE uses a filesystem workarea called `FVS`, but it expects a
  newer version than VM/370 CE's.
* `ZAP006` - PIPELINE calls RENAME (NOUPDIR, but VM/370 R6 expects (NOUPDIRT.
* `ZAP007` - Bypass DMSEXC when calling Rexx stages (pre-dates CMS update
  HRC100DS, and is not applied if HRC100DS is installed on CMS).
* `ZAP008` - Force the `CMS` and `COMMAND` stages down the CMS 5.5 code path,
  because we've implemented everything it needs, and the pre-5.5 path fails.
* `ZAP009` - Make the main disk I/O drivers (`<`, `>`, `>>`, `<MDSK`, `>MDSK`,
  and `>>MDSK`) go through `MDSKSLOW` instead, because the "fast" interface
  uses EDF interfaces not present in, and not likely to be added to, VM/370
  CMS.

### Release History
The _Plunger_ 0.0.n levels were focused on just getting _Pipelines_ to work at
all in VM/370 CMS.  _Plunger_ level 0.1.7 successfully demonstrated simple and
multistream pipelines with only limited _device driver_ usage.  The 0.1.n
levels which followed were focused on getting the most important _device
drivers_ working - `console`, `stack`, and disk I/O, and on supporting stages
written in Rexx (with bREXX release 1.2.0 providing much-needed Exec-in-Storage
support).  The 0.2.n levels, which were developed after the 0.1.27 level was
uploaded to GitHub, were focused on finishing testing and repair of the _device
drivers_.  _Plunger_ level 0.3.xxx completed that effort.

The _Plunger_ automated tests are written in
[RexxUnit](https://github.com/RossPatterson/RexxUnit), and a copy of the
`REXXUNIT EXEC` driver is included in the source code.  To run them, simply
install _Plunger_, with both the `REXXUNIT EXEC` and the `* REXXUNIT` files,
and enter `REXXUNIT`.  See the
[RexxUnit README](https://github.com/RossPatterson/RexxUnit/blob/main/README.md)
for more information.

## Licenses

The _CMS Pipelines Runtime Distribution_ and _Plunger_ are released under
separate and very different licenses.  Use of either of them is bound by its
specific license.

### CMS Pipelines Runtime Library Distribution license

See http://vm.marist.edu/~pipeline/tandc.html for the specific terms and
conditions related to distributing the _CMS Pipelines Runtime Library
Distribution_.  The remainder of this section is provided as courtesy for
_Plunger_ users, and does not supersede, modify, or replace those terms and
conditions.

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

_Plunger_ itself is free, unencumbered, and unwarranteed software and is
released into the public domain.  The specific licensing text _Plunger_ uses to
do this is [The Unlicense](https://unlicense.org), which is contained as file
`UNLICENS MEMO` in the `PLUNGER VMARC` package, and which you can and should
read in its (brief) entirety.
