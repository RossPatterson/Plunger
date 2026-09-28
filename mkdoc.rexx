/* Convert README.md to a MEMO file for CMS. */
/* Requires pandoc from https://pandoc.org/ */

Trace C
'RMDIR /q /s fixdoc\.venv 2>NUL:'

'cd fixdoc & py -m venv .venv'
'cd fixdoc & .venv\Scripts\activate.bat & pip install -r requirements.txt'
'cd fixdoc & .venv\Scripts\activate.bat & pandoc --from gfm-smart --to plain --filter .\fixdoc.py --columns 79 < ..\README.md > ..\plunger.memo'
'cd fixdoc & .venv\Scripts\activate.bat & pandoc --from gfm-smart --to html < ..\README.md > ..\README.html'

'RMDIR /q /s fixdoc\.venv 2>NUL:'
