--[[

 Lexer for BibTeX source code powered by LPeg.

 Authors:
  - Brendan O'Flaherty
  - Peter Odding
 Last Change: September 29, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = require 'lxsh'
local lpeg = require 'lpeg'

local P, R, S = lpeg.P, lpeg.R, lpeg.S
local D = R'09'
local I = R('AZ', 'az', '\127\255') + '_'
local U, L = R'AZ', R'az' -- uppercase, lowercase
local W = U + L -- case insensitive letter
local A = W + D + '_' -- identifier
local B = -(I + D) -- word boundary

-- Create an LPeg pattern that matches a word case insensitively.
local function ic(word)
  local pattern
  for chr in word:gmatch '.' do
    local uc, lc = chr:upper(), chr:lower()
    local p = (uc == lc) and lpeg.P(chr) or (lpeg.P(uc) + lpeg.P(lc))
    pattern = pattern and (pattern * p) or p
  end
  return pattern
end

-- Create a lexer definition context.
local define, compile = lxsh.lexers.new 'bib'

-- Pattern definitions start here.

define('whitespace' , S'\r\n\f\t\v '^1)

-- Entries.
define('entry', '@' * (ic'booklet' + ic'article' + ic'book' + ic'conference'
  + ic'inbook' + ic'incollection' + ic'inproceedings' + ic'manual'
  + ic'mastersthesis' + ic'lambda' + ic'misc' + ic'phdthesis' + ic'proceedings'
  + ic'techreport' + ic'unpublished') * B)

-- Fields.
define('field', (ic'author' + ic'title' + ic'journal' + ic'year' + ic'volume'
  + ic'number' + ic'pages' + ic'month' + ic'note' + ic'key' + ic'publisher'
  + ic'editor' + ic'series' + ic'address' + ic'edition' + ic'howpublished'
  + ic'booktitle' + ic'organization' + ic'chapter' + ic'school'
  + ic'institution' + ic'type' + ic'isbn' + ic'issn' + ic'affiliation'
  + ic'issue' + ic'keyword' + ic'url') * B)

define('identifier', (W + '_') * A^0)

-- Character and string literals.
define('string', '"' * ((1 - P'"'))^0 * '"')

-- Numbers (matched before operators because .1 is a number).
local int = ('0' + (D^1)) * S'lL'^-2
local flt = ((D^1 * '.' * D^0
            + D^0 * '.' * D^1
            + D^1 * 'e' * D^1) * S'fF'^-1)
            + D^1 * S'fF'
define('number', flt + int)

-- Operators.
define('operator', '=')

-- Delimiters.
define('delimiter', S',{}')

-- Define an `error' token kind that consumes one character and enables
-- the lexer to resume as a last resort for dealing with unknown input.
define('error', 1)

return compile()
