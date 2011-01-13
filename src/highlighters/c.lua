--[[

 Syntax highlighter for C source code.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: January 13, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lpeg = require 'lpeg'
local lxsh = require 'lxsh.init'
local lexer = require 'lxsh.lexers.c'
local docs = require 'lxsh.docs.c'

-- LPeg pattern to match escape sequences in string literals.
local escseq = lpeg.P'%' * lpeg.R('AZ', 'az', '09')
             + lpeg.P'\\' * ((#lpeg.R'07' * lpeg.R'07'^-3) + 1)

return lxsh.highlighter(lexer, docs, escseq, function(kind, text)
  return kind == 'constant' and kind
end)
