--[[

 Syntax highlighter for Lua 5.1 source code.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 9, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lpeg = require 'lpeg'
local lxsh = require 'lxsh.init'
local lexer = require 'lxsh.lexers.lua'
local docs = require 'lxsh.docs.lua'

-- LPeg pattern to match escape sequences in string literals.
local escseq = lpeg.P'%' * ('%' + lpeg.R('AZ', 'az', '09'))
             + lpeg.P'\\' * ((#lpeg.R'09' * lpeg.R'09'^-3) + 1)

return lxsh.highlighter(lexer, docs, escseq, function(kind, text)
  return kind == 'string' and 'constant' or kind
end)

-- vim: ts=2 sw=2 et
