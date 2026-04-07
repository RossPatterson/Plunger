/* RexxUnit 1.1.2 */

/*---------------------------------------------------------------------------*/
/* This is free and unencumbered software released into the public domain.   */
/*                                                                           */
/* Anyone is free to copy, modify, publish, use, compile, sell, or           */
/* distribute this software, either in source code form or as a compiled     */
/* binary, for any purpose, commercial or non-commercial, and by any         */
/* means.                                                                    */
/*                                                                           */
/* In jurisdictions that recognize copyright laws, the author or authors     */
/* of this software dedicate any and all copyright interest in the           */
/* software to the public domain. We make this dedication for the benefit    */
/* of the public at large and to the detriment of our heirs and              */
/* successors. We intend this dedication to be an overt act of               */
/* relinquishment in perpetuity of all present and future rights to this     */
/* software under copyright law.                                             */
/*                                                                           */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,           */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF        */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    */
/* IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR         */
/* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,     */
/* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR     */
/* OTHER DEALINGS IN THE SOFTWARE.                                           */
/*                                                                           */
/* For more information, please refer to <https://unlicense.org>             */
/*---------------------------------------------------------------------------*/

Parse arg Argstring

Signal on NoValue
Signal on Syntax

Call Setup
Call ParseArgs Argstring
TestNames = CollectTests(G._TestNamePatterns)
If TestNames = '' then Do
   Say 'No tests found.'
   Exit 666
End
Call Time 'R'    /* Start the elapsed time clock. */
Say G._Separator
Do while Not(TestNames = '')
    Parse var TestNames TestName TestNames
    Call RunTest TestName
End
If Not(G._Verbose) then Call LineOut , ''
Call DeleteFile G._TempFile
Call Report
Exit G._Count.FAIL + G._Count.ERROR + G._Count.SIGNAL + G._Count.XFAIL

/* Signal traps are at the bottom, since they have to be shared with the */
/* $RXU code. */

/*---------------------------------------------------------------------------*/
/* CacheRoutinesFromFile(Filename)                                           */
/*                                                                           */
/* Collect the Test* subroutine names from the specified file.               */
/*---------------------------------------------------------------------------*/
CacheRoutinesFromFile: Procedure expose G. TestCache.
Parse arg Filename

FilenameUpper = Translate(Filename)
If WordPos(Translate(FilenameUpper), TestCache._Files) > 0 then Return
G._HasSetup.FilenameUpper = G._False
G._HasTeardown.FilenameUpper = G._False
Call SystemInterface 'READFILE', Filename
TestRoutines = ''
Do I = 1 to SI_Results.0
    Do while Pos(':', SI_Results.I) > 0
        Parse var SI_Results.I Instruction ';' SI_Results.I
        Do while Pos(':', Instruction) > 0
            Parse var Instruction Label ':' Instruction
            LabelUpper = Translate(Label)
            Select
                When Not(Words(Label) = 1) then Nop
                When Not(Left(LabelUpper, 4) = 'TEST') then Nop
                When LabelUpper = 'TESTSETUP' then ,
                    G._HasSetup.FilenameUpper = G._True
                When LabelUpper = 'TESTTEARDOWN' then ,
                    G._HasTeardown.FilenameUpper = G._True
                Otherwise
                    TestRoutines = TestRoutines Label
            End
        End
    End
End
TestCache._Files = TestCache._Files FilenameUpper
TestCache.FilenameUpper = TestRoutines
If G._Verbose then Say Filename':' Words(TestCache.FilenameUpper) 'tests.'
Return


/*---------------------------------------------------------------------------*/
/* CollectTests(TestNamePatterns)                                            */
/*                                                                           */
/* Collect and return names of tests from the supplied name patterns.  Each  */
/* name is 'file:rtn', where either part may contain a '*' for pattern       */
/* matching.                                                                 */
/*---------------------------------------------------------------------------*/
CollectTests: Procedure expose G.
Parse arg TestNamePatterns

TestCache. = ''
TestNames = ''
Do while Not(TestNamePatterns = '')
    Parse var TestNamePatterns TestNamePattern TestNamePatterns
    Parse var TestNamePattern TestFilePattern ':' TestRoutinePattern
    If TestRoutinePattern = '' then TestRoutinePattern = '*'
    Select
        When Pos('*', TestFilePattern) > 0 then Do
            TestFiles = ListFiles(TestFilePattern)
            Do while Not(TestFiles = '')
                Parse var TestFiles TestFile TestFiles
                Call CacheRoutinesFromFile TestFile
                TestName = TestFile || ':' || TestRoutinePattern
                TestNamePatterns = TestNamePatterns TestName
            End
        End
        When Pos('*', TestRoutinePattern) > 0 then Do
            TestRoutines = ListRoutines(TestFilePattern, TestRoutinePattern)
            Do while Not(TestRoutines = '')
                Parse var TestRoutines TestRoutine TestRoutines
                TestName = TestFilePattern || ':' || TestRoutine
                TestNamePatterns = TestNamePatterns TestName
            End
        End
        Otherwise
            Call CacheRoutinesFromFile TestFilePattern
            TestFilePatternUpper = Translate(TestFilePattern)
            I = WordPos(Translate(TestRoutinePattern), ,
                Translate(TestCache.TestFilePatternUpper))
            If I = 0 then ,
                Say 'Test' TestNamePattern 'not found, ignored.'
            Else Do
                TestName = TestFilePattern || ':' || ,
                    Word(TestCache.TestFilePatternUpper, I)
                If WordPos(Translate(TestName), Translate(TestNames)) = 0 ,
                    then TestNames = TestNames TestName
            End
    End
End
Return TestNames


/*---------------------------------------------------------------------------*/
/* DeleteFile(Filename)                                                      */
/*                                                                           */
/* Delete the specified file.                                                */
/*---------------------------------------------------------------------------*/
DeleteFile: Procedure expose G.
Parse arg Filename

Call SystemInterface 'DELETEFILE', Filename

Return


/*---------------------------------------------------------------------------*/
/* ExitError(ExitRC, Message)                                                */
/*                                                                           */
/* Display a message and exit.                                               */
/*---------------------------------------------------------------------------*/
ExitError:
Parse arg ExitRC, Message

Say ExitRC ':' Message

Exit ExitRC


/*---------------------------------------------------------------------------*/
/* GetSigL()                                                                 */
/*                                                                           */
/* This just sets SigL to the caller's line #, to work around a bug in BREXX */
/* 1.0.2 and earlier (BREXX Issue #80).                                      */
/*---------------------------------------------------------------------------*/
GetSigL: Return SigL


/*---------------------------------------------------------------------------*/
/* ListFiles(FilePattern)                                                    */
/*                                                                           */
/* Return a list of files matching the pattern.                              */
/*---------------------------------------------------------------------------*/
ListFiles: Procedure expose G.
Parse arg FilePattern

FileList = ''
Call SystemInterface 'LISTFILES', FilePattern
Do I = 1 to SI_Results.0
    FileList = FileList SI_Results.I
End

Return FileList


/*---------------------------------------------------------------------------*/
/* ListRoutines(Filename, RoutinePattern)                                    */
/*                                                                           */
/* Return a list of test routine names in the file matching the pattern .    */
/*---------------------------------------------------------------------------*/
ListRoutines: Procedure expose G. TestCache.
Parse arg Filename, RoutinePattern

Call CacheRoutinesFromFile Filename
FilenameUpper = Translate(Filename)
Routines = TestCache.FilenameUpper
RoutineList = ''
RoutinePattern = Translate(RoutinePattern)
Do while Not(Routines = '')
    Parse var Routines Routine Routines
    If Match(Translate(Routine), RoutinePattern) then ,
        RoutineList = RoutineList Routine
End

Return RoutineList


/*---------------------------------------------------------------------------*/
/* Match(String, Pattern)                                                    */
/*                                                                           */
/* Return true if string matches pattern, otherwise false.                   */
/*---------------------------------------------------------------------------*/
Match: Procedure expose G.
Parse arg String, Pattern

Select
    When String == Pattern then Return G._True
    When Pos('*',Pattern) > 0 then Do
        Parse var Pattern Before '*' After
        Return (Left(String, Length(Before)) == Before & ,
            Right(String, Length(After)) == After )
    End
    /* There are probably other patterns to check, but we'll code them later */
    Otherwise Return G._False
End /* notreached */


/*---------------------------------------------------------------------------*/
/* Not(Boolean)                                                              */
/*                                                                           */
/* Because some Rexx implementations have problems with not-sign operators.  */
/*---------------------------------------------------------------------------*/
Not: Procedure

If Arg(1) then Return 0
Return 1


/*---------------------------------------------------------------------------*/
/* ParseArgs(Argstring)                                                      */
/*                                                                           */
/* Parse the argument string in the style of the current system.             */
/* NOTE: We allow the command to specify it's syntax style, both for ease of */
/*       testing, and so scripts can call this command in a                  */
/*       system-independent manner.                                          */
/*---------------------------------------------------------------------------*/
ParseArgs: Procedure expose G.
Parse arg Argstring

SavedSystemInterface = G._SystemInterface
If Left(Word(Argstring, 1), 2) == '__' then Do
    Parse value Substr(Argstring, 3) with G._SystemInterface Argstring
    G._SystemInterface = Translate(G._SystemInterface)
End
Call SystemInterface 'PARSEARGS', Argstring
G._SystemInterface = SavedSystemInterface

Return


/*---------------------------------------------------------------------------*/
/* Report()                                                                  */
/*                                                                           */
/* Report on final results.                                                  */
/*---------------------------------------------------------------------------*/
Report: Procedure expose G.
Say G._Separator
Do I = 1 to G._BadTests.0
    Parse var G._BadTests.I TestName '15'x TestStatus TestMessage '15'x ,
        TestDetails
    Say TestName TestStatus TestMessage
    Do while Not(TestDetails = '')
        Parse var TestDetails Line '15'x TestDetails
        Say '   ' || Line
    End
End
Say G._Separator
Say G._Count.PASS 'passed'
Say G._Count.FAIL 'failed'
Say G._Count.ERROR 'errors'
Say G._Count.SIGNAL 'SIGNALed'
Say G._Count.SKIP 'skipped'
Say G._Count.XFAIL 'passed when expected to fail'
Say 'Elapsed time:' Time('E') 'seconds'

Return


/*---------------------------------------------------------------------------*/
/* RunTest(TestName)                                                         */
/*                                                                           */
/* Run a test.                                                               */
/*---------------------------------------------------------------------------*/
RunTest:  Procedure expose G.
Parse arg TestName
Parse var TestName Filename ':' Routine

FilenameUpper = Translate(Filename)
If Not(G._CurrentTestFile = FilenameUpper) then Do
    Call SystemInterface 'WRITETESTFILE', Filename, G._TempFile
    G._CurrentTestFile = FilenameUpper
End
If G._Verbose then Say TestName '...'
Interpret "TestResult = " G._TempFileName || "('" || Routine ,
    G._HasSetup.FilenameUpper G._HasTeardown.FilenameUpper G._OS G._RexxLevel ,
    G._SoftAsserts G._AssertionDetails G._Trace || "')"
Call SystemInterface 'SYNCOUTPUT'

Parse var TestResult TestStatus TestMessage '15'x TestDetails
TestStatus = Translate(TestStatus)
If WordPos(TestStatus, 'ERROR FAIL PASS SKIP SIGNAL XFAIL') = 0 then Do
    TestMessage = 'Invalid test status:' TestResult
    TestStatus = 'ERROR'
End
If G._Verbose then Do
    Say TestName TestStatus TestMessage
    Do while Not(TestDetails = '')
        Parse var TestDetails Line '15'x TestDetails
        Say '   ' || Line
    End
End
Else Call CharOut , G._Char.TestStatus
G._Count.TestStatus = G._Count.TestStatus + 1
If Not(TestStatus = 'PASS') then Do
    I = G._BadTests.0 + 1
    G._BadTests.I = TestName || '15'x || TestResult
    G._BadTests.0 = I
End

Return


/*---------------------------------------------------------------------------*/
/* Setup()                                                                   */
/*                                                                           */
/* Set up to run tests, including system dependencies.                       */
/*---------------------------------------------------------------------------*/
Setup: Procedure expose G.

/* Global variables that the RexxUnit program itself will use. */
G. = ''
G._True = (1=1)
G._False = Not(G._True)
G._Separator = Copies('=', 80)
G._AssertionDetails = G._False
G._SoftAsserts = G._False
G._Trace = 'N'
G._Verbose = G._False
G._BadTests.0 = 0
G._Char.ERROR  = 'E'
G._Char.FAIL   = 'F'
G._Char.PASS   = '.'
G._Char.SIGNAL = '!'
G._Char.SKIP   = 'S'
G._Char.XFAIL  = 'X'
G._Count.ERROR  = 0
G._Count.FAIL   = 0
G._Count.PASS   = 0
G._Count.SIGNAL = 0
G._Count.SKIP   = 0
G._Count.XFAIL  = 0

/* System dependent behaviors. */
Parse source SourceSystem SourceAddress SourceFile
Parse version VersionSystem VersionRexxLevel VersionDate
G._OS = SourceSystem
G._RexxLevel = VersionRexxLevel
Select
    When VersionSystem = 'REXX370' & SourceSystem = 'CMS' then ,
        G._SystemInterface = 'CMS' /* VM/SP et seq. */
    When Left(VersionSystem, 10) = 'REXX-bREXX' & ,
        Substr(VersionSystem, 18, 6) = 'CMS370' then ,
        G._SystemInterface = 'CMS' /* VM/CE BREXX > 1.0.1 */
    When Left(VersionSystem, 11) = 'REXX-Regina' & ,
            Left(SourceSystem, 3) = 'WIN' then ,
        G._SystemInterface = 'WINDOWS'  /* Regina on Windows */
    When Left(VersionSystem, 11) = 'REXX-Regina' & ,
            SourceSystem = 'UNIX' then ,
        G._SystemInterface = 'UNIX'  /* Regina on Linux/Unix/etc. */
    When SourceSystem = 'CMS' then ,
        G._SystemInterface = 'CMS' /* Unknown VM Rexx */
    Otherwise Call ExitError 1, 'Unknown system type:' ,
        SourceSystem VersionSystem
End
Call SystemInterface 'SETUP'
/* Get the RexxUnit test boilerplate for later use. */
BoilerPlateStart = FindBoilerPlate()
Do I = 1 by 1 for SourceLine() - BoilerPlateStart
    G._Framework.I = SourceLine(BoilerPlateStart + I)
End
G._Framework.0 = I - 1

Return


/*---------------------------------------------------------------------------*/
/* ShowHelp(SystemType)                                                      */
/*                                                                           */
/* Display the command help and exit.                                        */
/*---------------------------------------------------------------------------*/
ShowHelp: Procedure
SystemType = Arg(1)

Select
    When SystemType = 'CMS' then ,
        Say 'REXXUNIT fn_pat[:test_pat] ... (' ,
           '[[NO]DETAILS] [HELP] [QUIET] [[NO]SOFT] [TRACE opt] [[NO]TYPE] [)]'
    When SystemType = 'WIN' then ,
        Say 'rexxunit [/d|/D] [/?|/H] [/q|/Q] [/s|/S] [/t|/T opt] [/v|/V]' ,
            'file_pat[:test_pat]'
    When SystemType = 'UNIX' then ,
        Say 'rexxunit [-d|--details] [-h|--help] [-q|--quiet] [-s|--soft]' ,
            '[-t|--trace opt] [-v|--verbose] file_pat[:test_pat] ...'
    Otherwise Call ExitError 2, 'Bad system type:' SystemType
End

Exit


/*---------------------------------------------------------------------------*/
/* SystemInterface(Action, Arg1, Arg2, ...)                                  */
/*                                                                           */
/* Perform the specified system-interface action with the specified          */
/* arguments.                                                                */
/*---------------------------------------------------------------------------*/
SystemInterface: Procedure expose G. SI_Input. SI_Results.
Parse arg Action, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9

If Action = 'SETUP' then Do
    G._SystemInterfaceTypes = 'CMS WINDOWS UNIX'
    G._SystemInterface._CMS._Setup     = 'SI_CMS_Setup'
    G._SystemInterface._Windows._Setup = 'SI_Windows_Setup'
    G._SystemInterface._Unix._Setup    = 'SI_Unix_Setup'
End
Target = Value('G._SystemInterface._' || G._SystemInterface || '._' || Action)
If Not(Target = '') then Signal Value Translate(Target)
Call ExitError 3, 'Invalid system interface action:' Action

/*---------------------------------------------------------------------------*/
/* SI_Stream_*                                                              */
/*                                                                           */
/* Perform the specified system-interface action with the arguments parsed   */
/* by SystemInterface, using Rexx stream I/O.                                */
/*                                                                           */
/* For obvious reasons, this interface is only partial, and is used by the   */
/* other system-interface modules.                                           */
/*---------------------------------------------------------------------------*/
SI_Stream_ReadFile:
InFile = Arg1
$RXU._TrapNotReadyDest = 'SI_STREAM_READFILE_EOF'
Signal on NotReady
Do I = 1 by 1
    SI_Results.I = LineIn(InFile)
End
SI_Stream_ReadFile_EOF:
SI_Results.0 = I - 1
Call Stream InFile, 'C', 'CLOSE'
If Not(Result = 'UNKNOWN') then ,
    Call ExitError 5, 'Error' Result 'closing' InFile

Return

SI_Stream_WriteTestFile:
InFile = Arg1
OutFile = Arg2
Call Stream OutFile, 'C', 'OPEN WRITE REPLACE'
Call LineOut OutFile, '/* RexxUnit Test Case file */ Signal $RXU_Start'
Call Stream InFile, 'C', 'OPEN READ'
$RXU._TrapNotReadyDest = 'SI_STREAM_WRITETESTFILE_EOF'
Signal on NotReady
Do Forever
    Call LineOut OutFile, LineIn(InFile)
End
SI_Stream_WriteTestFile_EOF:
Call Stream InFile, 'C', 'CLOSE'
Do I = 1 to G._Framework.0
    Call LineOut OutFile, G._Framework.I
End
Call Stream OutFile, 'C', 'CLOSE'

Return


/*---------------------------------------------------------------------------*/
/* SI_CMS_*                                                                  */
/*                                                                           */
/* Perform the specified system-interface action with the arguments parsed   */
/* by SystemInterface, for the CMS system.                                   */
/*---------------------------------------------------------------------------*/
SI_CMS_DeleteFile:
    Parse upper var Arg1 Fn '.' Ft '.' Fm
    If Fm = '' then Fm = 'A'
    'SET CMSTYPE HT'
    'ERASE' Fn Ft Fm
    'SET CMSTYPE RT'
Return

SI_CMS_ListFiles:
    Parse upper var Arg1 Fn '.' Ft
    'MAKEBUF'
    BufferNum = RC
    StackedBefore = Queued()
    'LISTFILE' Fn Ft '* ( FIFO'
    FileCount = Queued() - StackedBefore
    Do I = 1 to FileCount
        Pull Fn Ft .
        SI_Results.I = Fn || '.' || Ft
    End
    SI_Results.0 = FileCount
    'DROPBUF' BufferNum
Return

SI_CMS_ParseArgs:
    Parse var Arg1 Operands '(' Options
    Options = Translate(Options)
    Do while Not(Operands = '')
        Parse var Operands Testname Operands
        Parse var Testname Fn ':' Routine
        If Pos('.', Fn) = 0 then Fn = Fn || '.rexxunit'
        G._TestNamePatterns = G._TestNamePatterns Fn || ':' || Routine
    End
    If G._TestNamePatterns = '' then G._TestNamePatterns = '*.rexxunit'
    Do while Not(Options = '')
        Parse var Options Option Options
        Select
            When Left(Option, 1) = ')' then Options = ''
            When Option = 'HELP' then Call ShowHelp 'CMS'
            When Option = 'DETAILS' then G._AssertionDetails = G._True
            When Option = 'NODETAILS' then G._AssertionDetails = G._False
            When Option = 'SOFT' then G._SoftAsserts = G._True
            When Option = 'NOSOFT' then G._SoftAsserts = G._False
            When Option = 'TRACE' then ,
               Parse var Options G._Trace Options
            When Option = 'TYPE' then G._Verbose = G._True
            When Option = 'NOTYPE' | Option = 'QUIET' then ,
                G._Verbose = G._False
            Otherwise Call ExitError 6, 'Unknown option:' Option

        End
    End
Return

SI_CMS_ReadFile:
    Parse upper var Arg1 Fn '.' Ft
    'EXECIO * DISKR' Fn Ft '* ( STEM SI_RESULTS. FINIS'
Return

SI_CMS_Setup:
    G._SystemInterface._CMS._DeleteFile    = 'SI_CMS_DeleteFile'
    G._SystemInterface._CMS._ListFiles     = 'SI_CMS_ListFiles'
    G._SystemInterface._CMS._ParseArgs     = 'SI_CMS_ParseArgs'
    G._SystemInterface._CMS._ReadFile      = 'SI_CMS_ReadFile'
    G._SystemInterface._CMS._SyncOutput    = 'SI_CMS_SyncOutput'
    G._SystemInterface._CMS._WriteTestFile = 'SI_CMS_WriteTestFile'
    G._TempFile = 'RXUTEMP.EXEC.A'
    Parse var G._TempFile G._TempFileName '.' .
    If G._RexxLevel < 3 then G._RexxLevel = '3.40'
Return

SI_CMS_SyncOutput:
    'CONWAIT'
Return

SI_CMS_WriteTestFile:
    Parse upper var Arg1 InFn '.' InFt '.' InFm
    If InFm = '' then InFm = '*'
    Parse upper var Arg2 OutFn '.' OutFt '.' OutFm
    If OutFm = '' then OutFm = 'A'
    Call DeleteFile Arg2
    'EXECIO 1 DISKW' OutFn OutFt OutFm '( FINIS STRING',
        '/* RexxUnit Test Case file */ Signal $RXU_Start'
    'COPYFILE' InFn InFt InFm OutFn OutFt OutFm '( APPEND'
    X.0 = G._Framework.0
    Do I = 1 to X.0
        X.I = G._Framework.I
        If X.I == '' then X.I = ' ' /* Ensure Length() > 0 */
    End
    'EXECIO' X.0 'DISKW' OutFn OutFt OutFm '( STEM X. FINIS'

Return


/*---------------------------------------------------------------------------*/
/* SI_Unix_*                                                                 */
/*                                                                           */
/* Perform the specified system-interface action with the arguments parsed   */
/* by SystemInterface, for the Unix system.                                  */
/*---------------------------------------------------------------------------*/
SI_Unix_DeleteFile:
    If Words(Arg1) > 1 | Arg1 = '*' then Call ExitError 9, 'No.'
    'rm' Arg1 '2>/dev/null'
Return

SI_Unix_ListFiles:
    Address SYSTEM 'ls' Arg1 with output stem SI_Results.
Return

SI_Unix_ParseArgs:
    G._TestNamePatterns = ''
    Do while Not(Arg1 = '')
        Parse var Arg1 Arg Arg1
        Select
            When Arg = '--' then Leave
            When Left(Arg,1) = '-' & Not(Left(Arg,2) = '--') & ,
                Length(Arg) > 2 then Do
                Parse var Arg Arg +2 Rest
                Arg1 = '-' || Rest Arg1
            End
            When Arg = '--details' | Arg = '-d' then ,
               G._AssertionDetails = G._True
            When Arg = '--help' | Arg = '-h' then Call ShowHelp 'UNIX'
            When Arg = '--quiet' | Arg = '-q' then G._Verbose = G._False
            When Arg = '--soft' | Arg = '-s' then G._SoftAsserts = G._True
            When Arg = '--trace' | Arg = '-t' then Parse var Arg1 G._Trace Arg1
            When Arg = '--verbose' | Arg = '-v' then G._Verbose = G._True
            When Left(Arg, 1) = '-' then ,
                Call ExitError 10, 'Unknown option:' Arg
            Otherwise G._TestNamePatterns = G._TestNamePatterns Arg
        End
    End
    G._TestNamePatterns = G._TestNamePatterns Arg1
    If G._TestNamePatterns = '' then G._TestNamePatterns = '*.rexxunit'
Return

SI_Unix_Setup:
    G._SystemInterface._Unix._DeleteFile    = 'SI_Unix_DeleteFile'
    G._SystemInterface._Unix._ListFiles     = 'SI_Unix_ListFiles'
    G._SystemInterface._Unix._ParseArgs     = 'SI_Unix_ParseArgs'
    G._SystemInterface._Unix._ReadFile      = 'SI_Stream_ReadFile'
    G._SystemInterface._Unix._SyncOutput    = 'SI_Unix_SyncOutput'
    G._SystemInterface._Unix._WriteTestFile = 'SI_Stream_WriteTestFile'
    G._TempFile = 'rxutemp.rexx'
    G._TempFileName = G._TempFile
Return

SI_Unix_SyncOutput:
Return


/*---------------------------------------------------------------------------*/
/* SI_Windows_*                                                              */
/*                                                                           */
/* Perform the specified system-interface action with the arguments parsed   */
/* by SystemInterface, for the Windows system.                               */
/*---------------------------------------------------------------------------*/
SI_Windows_DeleteFile:
    If Words(Arg1) > 1 | Arg1 = '*.*' then Call ExitError 7, 'No.'
    'DEL' Arg1 '2>NUL:'
Return

SI_Windows_ListFiles:
    Address SYSTEM 'DIR /B' Arg1 with output stem SI_Results.
Return

SI_Windows_ParseArgs:
    G._TestNamePatterns = ''
    Do while Not(Arg1 = '')
        Parse var Arg1 Arg Arg1
        Select
            When Arg = '/?' | Translate(Arg) = '/H' then ,
                Call ShowHelp 'WIN'
            When Translate(Arg) = '/D' then G._AssertionDetails = G._True
            When Translate(Arg) = '/Q' then G._Verbose = G._False
            When Translate(Arg) = '/S' then G._SoftAsserts = G._True
            When Translate(Arg) = '/T' then Parse var Arg1 G._Trace Arg1
            When Translate(Arg) = '/V' then G._Verbose = G._True
            When Left(Arg, 1) = '/' then ,
                Call ExitError 8, 'Unknown option:' Arg
            Otherwise G._TestNamePatterns = G._TestNamePatterns Arg
        End
    End
    If G._TestNamePatterns = '' then G._TestNamePatterns = '*.rexxunit'
Return

SI_Windows_Setup:
    G._SystemInterface._Windows._DeleteFile    = 'SI_Windows_DeleteFile'
    G._SystemInterface._Windows._ListFiles     = 'SI_Windows_ListFiles'
    G._SystemInterface._Windows._ParseArgs     = 'SI_Windows_ParseArgs'
    G._SystemInterface._Windows._ReadFile      = 'SI_Stream_ReadFile'
    G._SystemInterface._Windows._SyncOutput    = 'SI_Windows_SyncOutput'
    G._SystemInterface._Windows._WriteTestFile = 'SI_Stream_WriteTestFile'
    G._OS = 'WINDOWS'
    G._TempFile = 'rxutemp.rexx'
    G._TempFileName = G._TempFile
Return

SI_Windows_SyncOutput:
Return


/*---------------------------------------------------------------------------*/
/* WordPos(needle, haystack, startword)                                      */
/*                                                                           */
/* Because some Rexx implementations don't have the built-in.                */
/*---------------------------------------------------------------------------*/
WordPos: Procedure
Parse arg Needle, Haystack, StartWord

If StartWord = '' then StartWord = 1
If Words(Needle) = 0 then Return 0
Do I = StartWord by 1 while Not(Haystack = '')
    Parse var Haystack HaystackWord1 Haystack
    If Not(Word(Needle, 1) = HaystackWord1) then Iterate
    Do J = 2 to Words(Needle)
        If Not(Word(Needle, J) = Word(Haystack, J-1)) then Iterate
    End
    Return I
End

Return 0


/*
===============================================================================
Everything below here is the "boilerplate" code that will be appended to
the actual test file.  None of the variables or labels above here are used in
it, and none of its variables or labels are used above.
===============================================================================
*/
FindBoilerPlate: Return GetSigL()
Call Fail 'Test script ran off end of file instead of RETURNing.'


/*---------------------------------------------------------------------------*/
/* AssertEndsWith(expected, actual, [message])                               */
/*                                                                           */
/* Return if the actual value ends with the expected value, otherwise fail   */
/* the test with the optional assertion message.                             */
/*---------------------------------------------------------------------------*/
AssertEndsWith: Procedure expose $RXU. SigL
Parse arg Expected, Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = Expected == Right(Actual, Length(Expected))
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected ending', Expected, 'Actual', ,
      Actual, Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertEqual(expected, actual, [message])                                  */
/*                                                                           */
/* Return if the actual value matches the expected value, otherwise fail     */
/* the test with the optional assertion message.                             */
/*---------------------------------------------------------------------------*/
AssertEqual: Procedure expose $RXU. SigL
Parse arg  Expected, Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = Expected = Actual
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected', Expected, 'Actual', ,
      Actual, Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertFalse(actual, [message])                                            */
/*                                                                           */
/* Return if the actual value is false (i.e., 0), otherwise fail the test    */
/* with the optional assertion message.                                      */
/*---------------------------------------------------------------------------*/
AssertFalse: Procedure expose $RXU. SigL
Parse arg Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = $RXU_Not(Actual)
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected', 0, 'Actual', Actual, Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertIdentical(expected, actual, [message])                              */
/*                                                                           */
/* Return if the actual value is identical to the expected value, otherwise  */
/* fail the test with the optional assertion message.                        */
/*---------------------------------------------------------------------------*/
AssertIdentical: Procedure expose $RXU. SigL
Parse arg Expected, Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = Expected == Actual
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected', Expected, 'Actual', Actual, ,
      Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertNotEqual(expected, actual, [message])                               */
/*                                                                           */
/* Return if the actual value does not match the expected value, otherwise   */
/* fail the test with the optional assertion message.                        */
/*---------------------------------------------------------------------------*/
AssertNotEqual: Procedure expose $RXU. SigL
Parse arg Expected, Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = $RXU_Not(Expected = Actual)
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected', Expected, 'Actual', Actual, ,
      Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertNotIdentical(expected, actual, [message])                           */
/*                                                                           */
/* Return if the actual value is not identical to the expected value,        */
/* otherwise fail the test with the optional assertion message.              */
/*---------------------------------------------------------------------------*/
AssertNotIdentical: Procedure expose $RXU. SigL
Parse arg Expected, Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = $RXU_Not(Expected == Actual)
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected', Expected, 'Actual', Actual, ,
      Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertStartsWith(expected, actual, [message])                             */
/*                                                                           */
/* Return if the actual value starts with the expected value, otherwise fail */
/* the test with the optional assertion message.                             */
/*---------------------------------------------------------------------------*/
AssertStartsWith: Procedure expose $RXU. SigL
Parse arg Expected, Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = Expected == Left(Actual, Length(Expected))
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected begining', Expected, 'Actual', ,
      Actual, Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* AssertStemEqual(expected_stem, actual_stem, [message])                    */
/*                                                                           */
/* Return if the actual stem matches the expected stem via the rules that    */
/* Rexx uses for "=", otherwise fail the test with the optional assertion    */
/* message.  Stems must be numeric-indexed with a count in stem.0, and are   */
/* compared in order, starting at 0.                                         */
/*---------------------------------------------------------------------------*/
AssertStemEqual:

$RXU.__Line = SigL /* Patch for Regina bug #610 */
$RXU.__How = 'EQUAL'
Signal $RXU_ASEI_Inner

Return


/*---------------------------------------------------------------------------*/
/* AssertStemIdentical(expected_stem, actual_stem, [message])                */
/*                                                                           */
/* Return if the actual stem is identical to  the expected stem, otherwise   */
/* fail the test with the optional assertion message.  Stems must be numeric-*/
/* indexed with a count in stem.0, and are compared in order, starting at 0. */
/*---------------------------------------------------------------------------*/
AssertStemIdentical:

$RXU.__Line = SigL /* Patch for Regina bug #610 */
$RXU.__How = 'IDENTICAL'
Signal $RXU_ASEI_Inner

$RXU_ASEI_Inner:

Parse arg  $RXU.__ExpectedStem, $RXU.__ActualStem, $RXU.__Message

$RXU.__Expected0 = Value($RXU.__ExpectedStem || '0')
$RXU.__Actual0 = Value($RXU.__ActualStem || '0')
Select
   When DataType($RXU.__Expected0, 'W') & DataType($RXU.__Actual0, 'W') then ,
      $RXU.__MaxCount = Max($RXU.__Expected0, $RXU.__Actual0)
   When DataType($RXU.__Expected0, 'W') then $RXU.__MaxCount = $RXU.__Expected0
   Otherwise $RXU.__MaxCount = $RXU.__Actual0
End
$RXU.__AllOK = 1
$RXU.__Details = ''
Do I = 0 to $RXU.__MaxCount
   $RXU.__Expected = Value($RXU.__ExpectedStem || I)
   $RXU.__Actual = Value($RXU.__ActualStem || I)
   If $RXU.__How = 'EQUAL' then $RXU.__OK = $RXU.__Expected = $RXU.__Actual
   Else $RXU.__OK = $RXU.__Expected == $RXU.__Actual
   $RXU.__AllOK = $RXU.__AllOK & $RXU.__OK
   If $RXU_Not($RXU.__OK) | $RXU._AssertionDetails then ,
      $RXU.__Details = $RXU.__Details || '15'x || ,
         RXU$_AssertionDetails('Expected' I, $RXU.__Expected, 'Actual' I, ,
            $RXU.__Actual, $RXU.__Line)
End
If $RXU._AssertionDetails then Say $RXU.__Details
If $RXU.__AllOK then Return
Call $RXU_AssertFailed $RXU.__Message, $RXU.__Details

Return


/*---------------------------------------------------------------------------*/
/* AssertTrue(actual, [message])                                             */
/*                                                                           */
/* Return if the actual value is true (i.e., 1), otherwise fail the test     */
/* with the optional assertion message.                                      */
/*---------------------------------------------------------------------------*/
AssertTrue: Procedure expose $RXU. SigL
Parse arg Actual, Message

Line = SigL /* Patch for Regina bug #610 */
OK = Actual
If $RXU._AssertionDetails | $RXU_Not(OK) then ,
   Details = RXU$_AssertionDetails('Expected', 1, 'Actual', Actual, Line)
If $RXU._AssertionDetails then Say Details
If OK then Return
Call $RXU_AssertFailed Message, Details

Return


/*---------------------------------------------------------------------------*/
/* Expect(condition, [subcondition], [message])                              */
/*                                                                           */
/* Expect the named condition to occur before the test returns.  Condition   */
/* must be one of 'ERROR', 'FAILURE', 'HALT', 'NOTREADY', 'NOVALUE', or      */
/* 'SYNTAX', case independent. In the case of 'ERROR', 'FAILURE', and        */
/* 'SYNTAX', there may be an expected subcondition RC value.                 */
/*---------------------------------------------------------------------------*/
Expect: Procedure expose $RXU.
Parse arg $RXU._ExpectWhat, $RXU._ExpectHow, $RXU._ExpectMsg

$RXU._ExpectWhat = Translate($RXU._ExpectWhat)
If WordPos($RXU._ExpectWhat, ,
        'ERROR FAILURE HALT NORMAL NOTREADY NOVALUE SYNTAX') = 0 then Do
    $RXU._TestStatus = 'ERROR Invalid parameter:' $RXU._ExpectWhat
    Signal $RXU_TestComplete
End
If WordPos($RXU._ExpectWhat, 'ERROR FAILURE SYNTAX') = 0 & ,
    $RXU_Not($RXU._ExpectHow = '') then Do
    $RXU._TestStatus = 'ERROR Unexpected details for' ,
        $RXU._ExpectWhat':' $RXU._ExpectHow
    Signal $RXU_TestComplete
End

Return

/*---------------------------------------------------------------------------*/
/* Fail([message])                                                           */
/*                                                                           */
/* Fail the test with the optional message.                                  */
/*---------------------------------------------------------------------------*/
Fail: Procedure expose $RXU. SigL
Parse arg Message

Line = SigL /* Patch for Regina bug #610 */
Call $RXU_AssertFailed Message, RXU$_AssertionDetails(, , , , Line)

Return


/*---------------------------------------------------------------------------*/
/* NoError(command)                                                          */
/*                                                                           */
/* Execute a command with SIGNAL OFF ERROR and return its return code.       */
/* This is not a procedure, so the command can access the caller's variables.*/
/*---------------------------------------------------------------------------*/
NoError:

Signal off Error
''Arg(1)
Signal on Error

Return RC


/*---------------------------------------------------------------------------*/
/* RexxLevel()                                                               */
/*                                                                           */
/* Return the version of the Rexx language supported by this implementation. */
/*---------------------------------------------------------------------------*/
RexxLevel: Procedure expose $RXU.

Return $RXU._RexxLevel


/*---------------------------------------------------------------------------*/
/* RexxOS()                                                                  */
/*                                                                           */
/* Return the OS name of the Rexx language supported by this implementation. */
/*---------------------------------------------------------------------------*/
RexxOS: Procedure expose $RXU.

Return $RXU._OS


/*---------------------------------------------------------------------------*/
/* Skip([message])                                                           */
/*                                                                           */
/* Skip the test with the optional message.                                  */
/*---------------------------------------------------------------------------*/
Skip: Procedure expose $RXU.
Parse arg Message

$RXU._TestStatus = 'SKIP' Message
Signal $RXU_TestComplete


/*---------------------------------------------------------------------------*/
/* SkipIf(condition, [message])                                              */
/*                                                                           */
/* Skip the test with the optional message, if the condition is true.        */
/*---------------------------------------------------------------------------*/
SkipIf: Procedure expose $RXU.
Parse arg Condition, Message

If $RXU_Not(Condition) then Return
$RXU._TestStatus = 'SKIP' Message
Signal $RXU_TestComplete


/*---------------------------------------------------------------------------*/
/* XFail([Message])                                                          */
/*                                                                           */
/* Expect the test to fail, and report the optional message if it passes.    */
/*---------------------------------------------------------------------------*/
XFail: Procedure expose $RXU.
Parse arg Message

If Message = '' then Message = 'Expected to fail, but passed'
$RXU._ExpectFailure = 1
$RXU._ExpectFailureMessage = Message

Return


/*---------------------------------------------------------------------------*/
/* Test authors: Do not call or signal anything below this point.            */
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
/* $RXU_AssertFailed(Message, Details)                                       */
/*                                                                           */
/* Back-end processing for a failed assertion.  Adds to the response to      */
/* the test runner and exits to $RXU_TestComplete.  Does not return to       */
/* caller unless SoftAsserts is set.                                         */
/*---------------------------------------------------------------------------*/
$RXU_AssertFailed: Procedure expose $RXU.
Parse arg Message, Details

Signal off Error
If $RXU._RexxLevel > 3.40 then Interpret "Signal off Failure"
Signal off NotReady
Signal off NoValue
Signal off Syntax
If Message = '' then Message = 'Assertion failed'
Parse var $RXU._TestStatus . PreviousDetails
If $RXU_Not(PreviousDetails = '') then ,
    PreviousDetails = PreviousDetails || '15'x
$RXU._TestStatus = 'FAIL' PreviousDetails || Message || '15'x || Details

If $RXU._SoftAsserts then Return
Signal $RXU_TestComplete


/*---------------------------------------------------------------------------*/
/* RXU$_AssertionDetails([ExpectedText], [ExpectedValue], [ActualText],      */
/*                [ActualValue], [Line])                                     */
/*                                                                           */
/* Format and return a assertion-details string.                             */
/*---------------------------------------------------------------------------*/
RXU$_AssertionDetails: Procedure expose $RXU.

Parse arg ExpectedText, ExpectedValue, ActualText, ActualValue, Line
If $RXU_Not(Line = '') then FailingCode = Line-1':' $RXU_SourceCode(Line)
Else FailingCode = ''
Details = FailingCode
TextWidth = Max(Length(ExpectedText), Length(ActualText))
If $RXU_Not(ExpectedText = '') then ,
    Details = Details || '15'x || Left(ExpectedText, TextWidth) || ,
        ': ["' || ExpectedValue || '"]'
If $RXU_Not(ActualText = '') then ,
    Details = Details || '15'x || Left(ActualText, TextWidth) || ,
        ': ["' || ActualValue || '"]'

Return Details


/*---------------------------------------------------------------------------*/
/* $RXU_Not(Boolean)                                                         */
/*                                                                           */
/* Because some Rexx implementations have problems with not-sign operators.  */
/*---------------------------------------------------------------------------*/
$RXU_Not: Procedure

If Arg(1) then Return 0
Return 1


$RXU_TrapError:
Call $RXU_TrapSprung 'ERROR', RC, $RXU._TrapLine


$RXU_TrapFailure:
Call $RXU_TrapSprung 'FAILURE', RC, $RXU._TrapLine


$RXU_TrapNotReady:
Call $RXU_TrapSprung 'NOTREADY', , $RXU._TrapLine


$RXU_TrapNoValue:
Call $RXU_TrapSprung 'NOVALUE', , $RXU._TrapLine


$RXU_TrapSyntax:
Call $RXU_TrapSprung 'SYNTAX', RC, $RXU._TrapLine

/*---------------------------------------------------------------------------*/
/* $RXU_SourceCode(line_num)                                                 */
/*                                                                           */
/* Return the source code on the specified line, including any continuatioms.*/
/*---------------------------------------------------------------------------*/
$RXU_SourceCode: Procedure
Arg Line

Code = ''
Do Line = Line by 1
   Code = Code Strip(SourceLine(Line))
   If $RXU_Not(Right(Code, 1) = ',') then Leave
   Code = Left(Code, Length(Code)-1)
End

Return Strip(Code)


/*---------------------------------------------------------------------------*/
/* $RXU_Start                                                                */
/*                                                                           */
/* Run the test.                                                             */
/*--------------                -------------------------------------------------------------*/
$RXU_Start:

Drop $RXU.
$RXU. = ''
$RXU._ExpectFailure = 0
$RXU._ExpectOccurred = 0
$RXU._ExpectWhat = 'NORMAL'
$RXU._TestStatus = 'PASS'

Parse arg $RXU._Testname $RXU._HasSetup $RXU._HasTeardown $RXU._OS ,
    $RXU._RexxLevel $RXU._SoftAsserts $RXU._AssertionDetails $RXU._Trace .
Signal on Error ; $RXU._TrapErrorDest = '$RXU_TrapError'
If $RXU._RexxLevel > 3.40 then ,
    Interpret "Signal on Failure ; $RXU._TrapFailureDest = '$RXU_TrapFailure'"
Signal on NotReady ; $RXU._TrapNotReadyDest = '$RXU_TrapNotReady'
Signal on NoValue ; $RXU._TrapNoValueDest = '$RXU_TrapNoValue'
Signal on Syntax; $RXU._TrapSyntaxDest = '$RXU_TrapSyntax'
If $RXU._HasSetup then Call TestSetup
If $RXU_Not($RXU._Trace = '') then Trace value $RXU._Trace
Interpret 'Call' $RXU._Testname

$RXU_TestComplete:
If $RXU._HasTeardown then Call TestTeardown

If $RXU._ExpectFailure & $RXU._TestStatus = 'PASS' then ,
    Exit 'XFAIL' $RXU._ExpectFailureMessage
If $RXU._ExpectWhat = 'NORMAL' then Exit $RXU._TestStatus
If $RXU._ExpectOccurred then Exit $RXU._TestStatus
If $RXU_Not($RXU._ExpectMsg = '') then Exit 'FAIL' $RXU._ExpectMsg
Exit 'FAIL Expected' $RXU._ExpectWhat $RXU._ExpectHow 'not SIGNALed'


/*---------------------------------------------------------------------------*/
/* $RXU_TrapSprung(ConditionName, [Details], Line)                           */
/*                                                                           */
/* Back-end processing for a trapped SIGNAL.  Constructs the response to     */
/* the test runner and exits to $RXU_TestComplete.  Does not return to       */
/* caller.                                                                   */
/*---------------------------------------------------------------------------*/
$RXU_TrapSprung:

Signal off Error
If $RXU._RexxLevel > 3.40 then Interpret "Signal off Failure"
Signal off NotReady
Signal off NoValue
Signal off Syntax
Parse arg ConditionName, Details, Line
$RXU._ExpectOccurred = ($RXU._ExpectWhat == ConditionName)
if $RXU_Not($RXU._ExpectHow = '') then ,
    $RXU._ExpectOccurred = $RXU._ExpectOccurred & ($RXU._ExpectHow == Details)
If $RXU._ExpectOccurred then $RXU._TestStatus = 'PASS'
Else $RXU._TestStatus = 'SIGNAL' ConditionName Details 'in line' Line

Signal $RXU_TestComplete


/*---------------------------------------------------------------------------*/
/* $RXU_WordPos(needle, haystack, startword)                                 */
/*                                                                           */
/* Because some Rexx implementations don't have the built-in.                */
/*---------------------------------------------------------------------------*/
$RXU_WordPos: Procedure
Parse arg Needle, Haystack, StartWord

If StartWord = '' then StartWord = 1
If Words(Needle) = 0 then Return 0
Do I = StartWord by 1 while $RXU_Not(Haystack = '')
    Parse var Haystack HaystackWord1 Haystack
    If $RXU_Not(Word(Needle, 1) = HaystackWord1) then Iterate
    Do J = 2 to Words(Needle)
        If $RXU_Not(Word(Needle, J) = Word(Haystack, J-1)) then Iterate
    End
    Return I
End

Return 0

/* Note: This program does not use SIGNAL ON condition NAME label,
         because it isn't supported in (at least) VM/SP5 Rexx.  Instead,
         it uses SignalDest='label'; SIGNAL ON condition; ... Syntax:
         SIGNAL VALUE SignalDest.  Yes, it's hokey.  But it works.
*/

Error:
$RXU._TrapLine = SigL
If Symbol('$RXU._TrapErrorDest') = 'VAR' then ,
    Signal value Translate($RXU._TrapErrorDest)
Say 'Error in line' $RXU._TrapLine || ':' $RXU_SourceCode($RXU._TrapLine)
Exit 1

Failure:
$RXU._TrapLine = SigL
If Symbol('$RXU._TrapFailureDest') = 'VAR' then ,
    Signal value Translate($RXU._TrapFailureDest)
Say 'Failure in line' $RXU._TrapLine || ':' $RXU_SourceCode($RXU._TrapLine)
Exit 2

NotReady:
$RXU._TrapLine = SigL
If Symbol('$RXU._TrapNotReadyDest') = 'VAR' then ,
    Signal value Translate($RXU._TrapNotReadyDest)
Say 'NotReady in line' $RXU._TrapLine || ':' $RXU_SourceCode($RXU._TrapLine)
Exit 3

NoValue:
$RXU._TrapLine = SigL
If Symbol('$RXU._TrapNoValueDest') = 'VAR' then ,
    Signal value Translate($RXU._TrapNoValueDest)
Say 'NoValue error in line' $RXU._TrapLine || ':' $RXU_SourceCode($RXU._TrapLine)
Exit 4


Syntax:
$RXU._TrapLine = SigL
If Symbol('$RXU._TrapSyntaxDest') = 'VAR' then ,
    Signal value Translate($RXU._TrapSyntaxDest)
Say 'Syntax error' RC ErrorText(RC) 'in line' $RXU._TrapLine || ':' $RXU_SourceCode($RXU._TrapLine)
Exit 5

