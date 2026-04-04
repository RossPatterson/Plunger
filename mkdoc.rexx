/* Convert README.md to a MEMO file for CMS. */
/* Requires pandoc from https://pandoc.org/ */

Trace C
'RMDIR /q /s fixdoc\.venv 2>NUL:'

Call CD 'fixdoc'
'py -m venv .venv'
' .venv\Scripts\activate.bat & pip install -r requirements.txt'
' .venv\Scripts\activate.bat & pandoc --from gfm-smart --to plain --filter .\fixdoc.py --columns 79 < ..\README.md > ..\plunger.memo'
Call CD ..

'RMDIR /q /s fixdoc\.venv 2>NUL:'
