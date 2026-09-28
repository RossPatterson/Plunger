#!/usr/bin/bash

# Convert README.md to a MEMO file for CMS.
# Requires pandoc from https://pandoc.org/

# Show the commands.
set -x

rm -rf fixdoc/.venv 2/dev/null

# Exit if there is an error.
set -e

cd fixdoc
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pandoc --from gfm-smart --to plain --filter ./fixdoc.py --columns 79 < ../README.md > ../plunger.memo
pandoc --from gfm-smart --to html < ../README.md > ../README.html
deactivate
cd ..

rm -rf fixdoc/.venv 2/dev/null
