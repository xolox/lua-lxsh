--[[

 Lexer for Lua 5.1 source code powered by LPeg.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 10, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = require 'lxsh'
local lpeg = require 'lpeg'
local C = lpeg.C
local Cc = lpeg.Cc
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local D = R'09'
local I = R('AZ', 'az', '\127\255') + '_'
local B = -(I + D) -- word boundary

-- Create a lexer definition context.
local define, compile = lxsh.lexers.new 'lua'

-- Pattern definitions start here.
define('whitespace', S'\r\n\f\t\v '^1)
define('constant', (P'true' + 'false' + 'nil') * B)

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

-- Pattern for long strings and long comments.
local longstring = #(P'[[' + (P'[' * P'='^0 * '[')) * P(function(input, index)
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
local eol = P'\r\n' + '\n'
local line = (1 - S'\r\n\f')^0 * eol^-1
local soi = P(function(s, i) return i == 1 and i end)
local shebang = soi * '#!' * line
local singleline = P'--' * line
local multiline = P'--' * longstring
define('comment', multiline + singleline + shebang)

-- Numbers.
local sign = S'+-'^-1
local decimal = D^1
local hexadecimal = P'0' * S'xX' * R('09', 'AF', 'af') ^ 1
local float = D^1 * P'.' * D^0 + P'.' * D^1
local maybeexp = (float + decimal) * (S'eE' * sign * D^1)^-1
define('number', hexadecimal + maybeexp)

-- Operators (matched after comments because of conflict with minus).
define('operator', P'not' + '...' + 'and' + '..' + '~=' + '==' + '>=' + '<='
  + 'or' + S']{=>^[<;)*(%}+-:,/.#')

-- Keywords.
define('keyword', (P'break' + 'do' + 'elseif' + 'else' + 'end' + 'for'
  + 'function' + 'if' + 'in' + 'local' + 'repeat' + 'return' + 'then'
  + 'until' + 'while') * B)

-- Identifiers.
define('identifier', I * (I + D + '.')^0)

-- Define an `error' token kind that consumes one character and enables
-- the lexer to resume as a last resort for dealing with unknown input.
define('error', 1)

-- Compile the final LPeg pattern to match any single token and return the
-- table containing the various definitions that make up the Lua lexer.
return compile()

-- vim: ts=2 sw=2 et
