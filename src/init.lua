--[[

 Infrastructure to make it easier to define lexers using LPeg
 and perform syntax highlighting based on the defined lexers.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: January 13, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = {}
local lpeg = require 'lpeg'

-- Construct a context for defining a lexer using LPeg.
function lxsh.lexer()

  -- Table of LPeg patterns to match all kinds of tokens.
  local patterns = {}
  local M = { patterns = patterns }

  -- Define a new token type given its name and LPeg pattern.
  local function define(name, patt)
    patt = lpeg.P(patt)
    patterns[name] = patt
    patterns[#patterns + 1] = name
  end

  -- Return an iterator that produces (kind, text) on each iteration.
  local any, keywords
  function M.gmatch(sources)
    local index = 1
    return function()
      if not any then any = compile() end
      local kind, text = any:match(sources, index)
      if kind and text then
        index = index + #text
        if keywords then
          kind = keywords[text] or kind
        end
        return kind, text
      end
    end
  end

  -- Compile all patterns into a single pattern that captures a (kind, text) pair.
  local function compile(_keywords)
    local function id(n) return lpeg.Cc(n) * lpeg.C(patterns[n]) end
    any = id(patterns[1])
    for i = 2, #patterns do any = any + id(patterns[i]) end
    keywords = _keywords
    return M
  end

  -- Return the two functions.
  return define, compile

end

-- Encode text as HTML.
local htmlencode; do
  local entities = { ['<'] = '&lt;', ['>'] = '&gt;', ['&'] = '&amp;' }
  function htmlencode(text)
    return (text:gsub('[<>&]', entities))
  end
end

-- Convert multiple spaces into non-breaking spaces.
local function fixspaces(text)
  return text:gsub(' +', function(space)
    return string.rep('&nbsp;', #space)
  end)
end

-- Wrap text in a <span> element with the given CSS styles.
local function wrap(style, text)
  local template = '<span style="%s">%s</span>'
  return style and template:format(style, text) or text
end

-- Highlight TODO, FIXME and XXX markers in comments.
local hlmarkers; do
  local marker = lpeg.P'TODO' + 'FIXME' + 'XXX'
  local pattern = lpeg.Cs((lpeg.C(marker) * lpeg.Carg(1) / function(text, colors)
    return wrap(colors.marker, text)
  end + 1)^0)
  function hlmarkers(text, colors)
    return lpeg.match(pattern, text, 1, colors)
  end
end

-- Replace URLs in comments/strings with hyperlinks.
local linkify; do
  local protocol = ((lpeg.P'https' + 'http' + 'ftp' + 'irc') * '://') + 'mailto:'
  local remainder = ((1-lpeg.S'\r\n\f\t ,.') + (lpeg.S',.' * (1-lpeg.S'\r\n\f\t ')))^0
  local pattern = lpeg.Cs((lpeg.C(protocol * remainder) * lpeg.Carg(1) / function(url, colors)
    local html = '<a href="' .. url .. '"'
    if colors and colors.url then
      html = html .. ' style="' .. colors.url .. '"'
    end
    return html .. '>' .. url .. '</a>'
  end + 1)^0)
  function linkify(text, colors)
    return lpeg.match(pattern, text, 1, colors)
  end
end

-- Load the default color scheme.
local defaultcolors = require 'lxsh.colors.earendel'

-- Construct a new syntax highlighter from the given parameters.
function lxsh.highlighter(lexer, docs, escseq, isstring)

  -- Create an LPeg pattern to highlight escape sequences in string literals.
  local hlescapes; do
    local pattern = lpeg.Cs((lpeg.C(escseq) * lpeg.Carg(1) / function(text, colors)
      return wrap(colors.escape, text)
    end + 1)^0)
    function hlescapes(text, colors)
      return lpeg.match(pattern, text, 1, colors)
    end
  end

  -- Return a function that syntax highlights a string of source code.
  return function(sources, options)

    local output = {}
    local options = type(options) == 'table' and options or {}
    local colors = options.colors or defaultcolors

    for kind, text in lexer.gmatch(sources) do
      local doclink = docs[text]
      if doclink then
        local template = '<a href="%s" style="%s">%s</a>'
        text = template:format(doclink, colors.global, text)
      else
        text = htmlencode(text)
        if options.encodews then
          text = fixspaces(text)
        end
        if kind == 'string' or kind == 'comment' then
          text = linkify(text, colors)
        end
        if kind == 'comment' then
          text = hlmarkers(text, colors)
        end
        local newkind = isstring(kind, text)
        if newkind then
          kind = newkind
          text = hlescapes(text, colors)
        end
        local style = colors[kind]
        if style then
          text = wrap(style, text)
        end
      end
      output[#output + 1] = text
    end

    local wrapper = options.wrapper or 'pre'
    local defaultstyle = colors.default or 'color: #000; background-color: #FFF'
    table.insert(output, 1, '<' .. wrapper .. ' style="' .. defaultstyle .. '">')
    table.insert(output, '</' .. wrapper .. '>')
    local html = table.concat(output)

    if options.encodews then
      html = html:gsub('\r?\n', '<br>')
    end

    return html
  end

end

return lxsh
