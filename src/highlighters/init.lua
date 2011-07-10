--[[

 Infrastructure to make it easier to define syntax highlighters.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 10, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local lxsh = require 'lxsh'
local lpeg = require 'lpeg'

-- Internal functions. {{{1

-- htmlencode() - Encode text as HTML. {{{2
local htmlencode; do
  local entities = { ['<'] = '&lt;', ['>'] = '&gt;', ['&'] = '&amp;' }
  function htmlencode(text)
    return (text:gsub('[<>&]', entities))
  end
end

-- fixspaces() - Convert multiple spaces into non-breaking spaces. {{{2
local function fixspaces(text)
  return text:gsub(' +', function(space)
    return string.rep('&nbsp;', #space)
  end)
end

-- wrap() - Wrap text in a <span> element with the given CSS styles. {{{2
local function wrap(token, text, options)
  if token then
    local attr = options.external and 'class' or 'style'
    local value = options.external and token or options.colors[token]
    if value then
      local template = '<span %s="%s">%s</span>'
      return template:format(attr, value, text)
    end
  end
  return text
end

-- hlmarkers() - Highlight TODO, FIXME and XXX markers in comments. {{{2
local hlmarkers; do
  local marker = lpeg.P'TODO' + 'FIXME' + 'XXX'
  local pattern = lpeg.Cs((lpeg.C(marker) * lpeg.Carg(1) / function(text, options)
    return wrap('marker', text, options)
  end + 1)^0)
  function hlmarkers(text, options)
    return lpeg.match(pattern, text, 1, options)
  end
end

-- linkify() - Replace URLs in comments/strings with hyperlinks. {{{2
local linkify; do
  -- LPeg pattern to match e-mail addresses.
  local alnum = lpeg.R('AZ', 'az', '09')
  local domainpart = alnum^1 * (lpeg.S'_-' * alnum^1)^0
  local domain = domainpart * ('.' * domainpart)^1
  local email = alnum^1 * (lpeg.S'_-.+' * alnum^1)^0 * '@' * domain
  -- LPeg pattern to match URLs.
  local protocol = ((lpeg.P'https' + 'http' + 'ftp' + 'irc') * '://') + 'mailto:'
  local remainder = ((1-lpeg.S'\r\n\f\t ,.') + (lpeg.S',.' * (1-lpeg.S'\r\n\f\t ')))^0
  local url = protocol * remainder
  -- Function to obfuscate e-mail addresses.
  local function obfuscate(email)
    return email:gsub('.', function(c)
      return ('&#%d;'):format(c:byte())
    end)
  end
  local pattern = lpeg.Cs((lpeg.Cs(email + url) * lpeg.Carg(1) / function(url, options)
    local text = url
    if url:find '@' and not url:find '://' then
      if not url:find '^mailto:' then
        url = 'mailto:' .. url
      end
      url = obfuscate(url)
      text = obfuscate(text)
    end
    local html = '<a href="' .. url .. '"'
    if options.colors.url and not options.external then
      html = html .. ' style="' .. options.colors.url .. '"'
    end
    return html .. '>' .. text .. '</a>'
  end + 1)^0)
  function linkify(text, options)
    return lpeg.match(pattern, text, 1, options)
  end
end

-- Constructor for syntax highlighting modes. {{{1

-- Construct a new syntax highlighter from the given parameters.
function lxsh.highlighters.new(lexer, docs, escseq, isstring)

  -- Create an LPeg pattern to highlight escape sequences in string literals.
  local hlescapes; do
    local pattern = lpeg.Cs((lpeg.C(escseq) * lpeg.Carg(1) / function(text, options)
      return wrap('escape', text, options)
    end + 1)^0)
    function hlescapes(text, options)
      return lpeg.match(pattern, text, 1, options)
    end
  end

  -- Return a function that syntax highlights a string of source code.
  return function(sources, options)

    local output = {}
    local options = type(options) == 'table' and options or {}
    if not options.colors then options.colors = lxsh.colors.earendel end

    for kind, text in lexer.gmatch(sources) do
      local doclink = docs[text]
      if doclink then
        local template = '<a href="%s" %s="%s">%s</a>'
        local attr = options.external and 'class' or 'style'
        local value = options.external and 'library' or options.colors.library
        text = template:format(doclink, attr, value, text)
      else
        text = htmlencode(text)
        if options.encodews then
          text = fixspaces(text)
        end
        if kind == 'string' or kind == 'comment' then
          text = linkify(text, options)
        end
        if kind == 'comment' then
          text = hlmarkers(text, options)
        end
        local newkind = isstring(kind, text)
        if newkind then
          kind = newkind
          text = hlescapes(text, options)
        end
        if kind ~= 'whitespace' then
          text = wrap(kind, text, options)
        end
      end
      output[#output + 1] = text
    end

    local wrapper = options.wrapper or 'pre'
    local elem = '<' .. wrapper
    if not options.external then
      elem = elem .. ' style="' .. options.colors.default .. '"'
    end
    table.insert(output, 1, elem .. ' class="sourcecode ' .. lexer.language .. '">')
    table.insert(output, '</' .. wrapper .. '>')
    local html = table.concat(output)

    if options.encodews then
      html = html:gsub('\r?\n', '<br>')
    end

    return html
  end

end

-- Style sheet generator. {{{2

function lxsh.highlighters.includestyles(default, includeswitcher)
  local template = '<link rel="%s" type="text/css" href="http://peterodding.com/code/lua/lxsh/styles/%s.css" title="%s">'
  local output = {}
  for _, style in ipairs { 'earendel', 'slate', 'wiki' } do
    local rel = style == default and 'stylesheet' or 'alternate stylesheet'
    output[#output + 1] = template:format(rel, style, style:gsub('^%w', string.upper))
  end
  if includeswitcher then
    output[#output + 1] = '<script type="text/javascript" src="http://peterodding.com/code/lua/lxsh/styleswitcher.js"></script>'
  end
  return table.concat(output, '\n')
end

function lxsh.highlighters.stylesheet(name)
  local colors = require('lxsh.colors.' .. name)
  local keys = {}
  for k in pairs(colors) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  local output = {}
  for _, key in ipairs(keys) do
    if key == 'default' then
      output[#output + 1] = ('.sourcecode { %s; }'):format(colors[key])
    elseif key == 'url' then
      output[#output + 1] = ('.sourcecode a:link, .sourcecode a:visited { %s; }'):format(colors[key])
    elseif key == 'library' then
      local styles = (colors[key] .. ';'):gsub(';', ' !important;')
      output[#output + 1] = ('.sourcecode .%s { %s }'):format(key, styles)
    else
      output[#output + 1] = ('.sourcecode .%s { %s; }'):format(key, colors[key])
    end
  end
  return table.concat(output, '\n')
end

return lxsh.highlighters
