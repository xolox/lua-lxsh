--[[

 Syntax highlighter for C source code.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 9, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = require 'lxsh'
local lpeg = require 'lpeg'

-- LPeg pattern to match escape sequences in string literals.
local escseq = lpeg.P'%' * lpeg.R('AZ', 'az', '09')
             + lpeg.P'\\' * ((#lpeg.R'07' * lpeg.R'07'^-3) + 1)

return lxsh.highlighters.new(lxsh.lexers.c, lxsh.docs.c, escseq, function(kind, text)
  return kind == 'constant' and kind
end)

-- vim: ts=2 sw=2 et
