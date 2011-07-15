--[[

 Infrastructure to make it easier to define syntax highlighters.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 15, 2011
 URL: http://peterodding.com/code/lua/lxsh/

 The syntax highlighters in the LXSH module decorate the token streams produced
 by the lexers with the following additional tokens:

  - TODO, FIXME and XXX markers in comments
  - e-mail addresses and hyper links in strings and comments
  - escape sequences in character and string literals

 Coroutines are used to simplify the implementation of the decorated token
 stream and while it works I'm not happy with the code. Note also that the
 token stream is flat which means the following Lua source code:

   -- TODO Nested tokens?

 Produces the following HTML source code (reformatted for readability):

   <span class="comment">--</span>
   <span class="marker">TODO</span>
   <span class="comment">Nested tokens?</span>

 Instead of what you may have expected:

   <span class="comment">--
   <span class="marker">TODO</span>
   Nested tokens?</span>

]]

local lxsh = require 'lxsh'
local lpeg = require 'lpeg'

-- Internal functions. {{{1

local function obfuscate(email)
  return (email:gsub('.', function(c)
    return ('&#%d;'):format(c:byte())
  end))
end

local entities = { ['<'] = '&lt;', ['>'] = '&gt;', ['&'] = '&amp;' }
local function htmlencode(text)
  return (text:gsub('[<>&]', entities))
end

local function fixspaces(text)
  return (text:gsub(' +', function(space)
    return string.rep('&nbsp;', #space)
  end))
end

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

-- LPeg patterns to decorate the token stream (richer highlighting). {{{1

-- LPeg patterns to scan for comment markers.
local comment_marker = lpeg.P'TODO' + 'FIXME' + 'XXX'
local comment_scanner = lpeg.Cc'marker' * lpeg.C(comment_marker)
                      + lpeg.Carg(1) * lpeg.C((1 - comment_marker)^1)

-- LPeg patterns to match e-mail addresses.
local alnum = lpeg.R('AZ', 'az', '09')
local domainpart = alnum^1 * (lpeg.S'_-' * alnum^1)^0
local domain = domainpart * ('.' * domainpart)^1
local email = alnum^1 * (lpeg.S'_-.+' * alnum^1)^0 * '@' * domain

-- LPeg patterns to match URLs.
local protocol = ((lpeg.P'https' + 'http' + 'ftp' + 'irc') * '://') + 'mailto:'
local remainder = ((1-lpeg.S'\r\n\f\t\v ,."}])') + (lpeg.S',."}])' * (1-lpeg.S'\r\n\f\t\v ')))^0
local url = protocol * remainder

-- LPeg pattern to scan for e-mail addresses and URLs.
local other = (1 - (email + url))^1
local url_scanner = lpeg.C(email) / function(email) return 'email', email, email end
                  + lpeg.C(url) / function(url) return 'url', url, url end
                  + lpeg.Carg(1) * lpeg.C(other)

-- Constructor for syntax highlighting modes. {{{1

-- Construct a new syntax highlighter from the given parameters.
function lxsh.highlighters.new(context)

  -- Implementation of decorated token stream (depends on lexer as upvalue). {{{2

  -- LPeg pattern to scan for escape sequences in character and string literals.
  local escape_scanner = lpeg.Cc'escape' * lpeg.C(context.escape_sequence)
                       + lpeg.Carg(1) * lpeg.C((1 - context.escape_sequence)^1)

  -- Turn an LPeg pattern into an iterator that produces (kind, text) pairs.
  -- TODO Find a better name for this.
  local function iterator(kind, text, pattern)
    local index = 1
    while index <= #text do
      local subkind, subtext, url = pattern:match(text, index, kind)
      if subkind and subtext then
        coroutine.yield(subkind, subtext, url)
        index = index + #subtext
      end
    end
  end

  -- Transform a function that produces values using yield() into an iterator.
  -- TODO Find a better name for this.
  local function producer(fun, a1, a2, a3)
    -- Lua refuses to pass ... as an upvalue but we
    -- only need three arguments so we fake it :-)
     return coroutine.wrap(function() fun(a1, a2, a3) end)
  end

  -- Decorate the token stream produced by a lexer so that comment markers,
  -- URLs, e-mail addresses and escape sequences are recognized as well.
  local function decorator(context, subject)
    for kind, text in context.lexer.gmatch(subject, { join_identifiers = true }) do
      -- Check to see if this token has documentation.
      local docs = context.docs[text]
      if docs then
        coroutine.yield('library', text, docs)
      elseif kind == 'comment' or kind == 'constant' or kind == 'string' then
        -- Identify e-mail addresses and URLs.
        for kind, text, url in producer(iterator, kind, text, url_scanner) do
          if kind == 'comment' then
            -- Identify comment markers.
            iterator(kind, text, comment_scanner)
          elseif context.has_escapes(kind, text) then
            -- Identify escape sequences.
            iterator(kind, text, escape_scanner)
          else
            coroutine.yield(kind, text, url)
          end
        end
      else
        coroutine.yield(kind, text)
      end
    end
  end

  -- Highlighter function (depends on lexer and decorator as upvalues). {{{2

  return function(subject, options)

    local output = {}
    local options = type(options) == 'table' and options or {}
    if not options.colors then options.colors = lxsh.colors.earendel end

    for kind, text, url in producer(decorator, context, subject) do
      local html
      if url then
        if url:find '@' and not url:find '://' then
          if not url:find '^mailto:' then
            url = 'mailto:' .. url
          end
          url = obfuscate(url)
          text = obfuscate(text)
        end
        if kind == 'url' or kind == 'email' then
          html = ('<a href="%s">%s</a>'):format(url, text)
        else
          local attr = options.external and 'class' or 'style'
          local value = options.external and kind or options.colors[kind]
          html = ('<a href="%s" %s="%s">%s</a>'):format(url, attr, value, text)
        end
      else
        html = htmlencode(text)
        if options.encodews then
          html = fixspaces(html)
        end
        if kind == 'string' then
          kind = 'constant'
        end
        if kind ~= 'whitespace' then
          html = wrap(kind, html, options)
        end
      end
      output[#output + 1] = html
    end

    local wrapper = options.wrapper or 'pre'
    local elem = '<' .. wrapper
    if not options.external then
      elem = elem .. ' style="' .. options.colors.default .. '"'
    end
    table.insert(output, 1, elem .. ' class="sourcecode ' .. context.lexer.language .. '">')
    table.insert(output, '</' .. wrapper .. '>')
    local html = table.concat(output)

    if options.encodews then
      html = html:gsub('\r?\n', '<br>')
    end

    return html
  end

end

-- Style sheet generator. {{{1

-- Generate the HTML to include the LXSH style sheets (CSS files) and
-- optionally the JavaScript for the style sheet switcher.

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

-- Generate a CSS style sheet from an LXSH color scheme.

function lxsh.highlighters.stylesheet(name)
  local keys = {}
  for k in pairs(lxsh.colors[name]) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  local output = {}
  for _, key in ipairs(keys) do
    if key == 'default' then
      output[#output + 1] = ('.sourcecode { %s; }'):format(lxsh.colors[name][key])
    elseif key == 'url' then
      output[#output + 1] = ('.sourcecode a:link, .sourcecode a:visited { %s; }'):format(lxsh.colors[name][key])
    elseif key == 'library' then
      local styles = (lxsh.colors[name][key] .. ';'):gsub(';', ' !important;')
      output[#output + 1] = ('.sourcecode .%s { %s }'):format(key, styles)
    else
      output[#output + 1] = ('.sourcecode .%s { %s; }'):format(key, lxsh.colors[name][key])
    end
  end
  return table.concat(output, '\n')
end

-- }}}1

return lxsh.highlighters
