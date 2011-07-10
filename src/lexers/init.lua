--[[

 Infrastructure to make it easier to define lexers using LPeg.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 10, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = require 'lxsh'
local lpeg = require 'lpeg'

-- Constructor for lexers defined using LPeg.
function lxsh.lexers.new(language)

  -- Table of LPeg patterns to match all kinds of tokens.
  local patterns = {}
  local lexer = { language = language, patterns = patterns }

  -- Closure to define token type given name and LPeg pattern.
  local function define(name, patt)
    patt = lpeg.P(patt)
    patterns[name] = patt
    patterns[#patterns + 1] = name
  end

  -- Closure to compile all patterns into one pattern that captures (kind, text) pair.
  local function compile()
    local function id(n)
      return lpeg.Cc(n) * patterns[n] * lpeg.Cp()
    end
    any = id(patterns[1])
    for i = 2, #patterns do
      any = any + id(patterns[i])
    end
    return lexer
  end

  -- The basic function for lexical analysis, it takes a subject string and
  -- optional index and returns a token type and the last index of the match.
  function lexer.find(subject, init)
    local kind, after = any:match(subject, init)
    if kind and after then return kind, after - 1 end
  end

  -- Convenience function that returns token type and matched text.
  function lexer.match(subject, init)
    local kind, after = any:match(subject, init)
    if kind and after then
      return kind, subject:sub(init, after - 1)
    end
  end

  -- Return an iterator that produces (kind, text) on each iteration.
  function lexer.gmatch(subject)
    local index = 1
    return function()
      local kind, after = any:match(subject, index)
      if kind and after then
        local text = subject:sub(index, after - 1)
        index = after
        return kind, text
      end
    end
  end

  -- Return the two closures used to construct the lexer.
  return define, compile

end

return lxsh.lexers
