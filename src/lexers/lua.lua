--[[

 Lexer for Lua 5.1 source code powered by LPeg.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 9, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = require 'lxsh.init'
local lpeg = require 'lpeg'
local C = lpeg.C
local Cc = lpeg.Cc
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local D = R'09'
local I = R('AZ', 'az', '\127\255') + P'_'

-- Create a lexer definition context.
local define, compile = lxsh.lexer 'lua'

-- Pattern definitions start here.
define('whitespace', S'\r\n\f\t\v '^1)
define('constant', P'true' + P'false' + P'nil')

-- Interactive prompt.
define('prompt', function(input, index)
  if index == 1 then
    local copyright = '^Lua%s+%S+%s+Copyright[^\r\n]+'
    local first, last = input:find(copyright, index)
    if last then
      return last + 1
    end
  else
    local first, last = input:find('^[\r\n]>>?', index-1)
    if last then
      return last + 1
    end
  end
end)

define('identifier', I * (I + D + '.')^0)

-- Numbers.
local sign = S'+-'^-1
local decimal = D^1
local hexadecimal = P'0' * S'xX' * R('09', 'AF', 'af') ^ 1
local float = D^1 * P'.' * D^0 + P'.' * D^1
local maybeexp = (float + decimal) * (S'eE' * sign * D^1)^-1
define('number', hexadecimal + maybeexp)

-- Pattern for long strings and long comments.
local longstring = #(P'[[' + (P'[' * P'=' ^ 0 * P'[')) * P(function(input, index)
  local level = input:match('^%[(=*)%[', index)
  if level then
    local _, stop = input:find(']' .. level .. ']', index, true)
    if stop then return stop + 1 end
  end
end)

-- String literals.
local singlequoted = P"'" * ((1 - S"'\r\n\f\\") + (P'\\' * 1))^0 * "'"
local doublequoted = P'"' * ((1 - S'"\r\n\f\\') + (P'\\' * 1))^0 * '"'
define('string', singlequoted + doublequoted + longstring)

-- Comments.
local eol = P'\r\n' + P'\n'
local line = (1 - S'\r\n\f')^0 * eol^-1
local soi = P(function(s, i) return i == 1 and i end)
local shebang = soi * '#!' * line
local singleline = P'--' * line
local multiline = P'--' * longstring
define('comment', multiline + singleline + shebang)

-- Operators (matched after comments because of conflict with minus).
define('operator', P'not' + P'...' + P'and' + P'..' + P'~=' +
  P'==' + P'>=' + P'<=' + P'or' + S']{=>^[<;)*(%}+-:,/.#')

-- Define an `error' token kind that consumes one character and enables
-- the lexer to resume as a last resort for dealing with unknown input.
define('error', 1)

-- Words that are not identifiers (operators and keywords).
return compile {
  ['and'     ] = 'operator',
  ['break'   ] = 'keyword',
  ['do'      ] = 'keyword',
  ['else'    ] = 'keyword',
  ['elseif'  ] = 'keyword',
  ['end'     ] = 'keyword',
  ['false'   ] = 'constant',
  ['for'     ] = 'keyword',
  ['function'] = 'keyword',
  ['if'      ] = 'keyword',
  ['in'      ] = 'keyword',
  ['local'   ] = 'keyword',
  ['nil'     ] = 'constant',
  ['not'     ] = 'operator',
  ['or'      ] = 'operator',
  ['repeat'  ] = 'keyword',
  ['return'  ] = 'keyword',
  ['then'    ] = 'keyword',
  ['true'    ] = 'constant',
  ['until'   ] = 'keyword',
  ['while'   ] = 'keyword',
}

-- vim: ts=2 sw=2 et
