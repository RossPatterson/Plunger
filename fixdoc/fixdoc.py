#!/usr/bin/env python

"""
Pandoc filter to make converting README.md to plaintext a little more
readable.

1. Format headers a bit.
   1. "# header" - upcase and center
   2. "## header" - upcase
2. Include link URLs: "[desc](url)" -> "desc (url)" (but not bare URLs)
"""

from panflute import *

def do_filter(elem, doc):
    # debug(repr(elem))
    if type(elem)== Header:
        if elem.level == 1:
            return Header(Str(stringify(elem).upper().center(80)))
        elif elem.level == 2:
            return Header(Str(stringify(elem).upper()))
    elif type(elem) == Link:
        if elem.url and not elem.url.startswith('#') and \
                stringify(elem.content).strip() != elem.url.strip():
            # debug(f'{elem.content=} {elem.url=}')
            elem.content.append(Str(f' ({elem.url})'))
            # debug(f'{elem.content=}')
            return elem

def main(doc=None):
    return run_filter(do_filter, doc=doc)

if __name__ == '__main__':
    main()