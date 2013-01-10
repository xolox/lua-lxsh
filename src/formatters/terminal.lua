--[[

 ANSI terminal escape formatter for LXSH.

 Author: Craig Barnes <cr@igbarn.es>
 Last Change: January 10, 2013

]]

local formatter = { format = 'terminal' }

local colors = {
  default = { color = 39, background = 49 },
  keyword = { color = 39, bold = true },
  comment = { color = 36 },
  constant = { color = 36, bold = true },
  operator = { color = 31 },
  string = { color = 33 },
  escape = { color = 35 },
  library = { color = 34, bold = true },
  marker = { color = 37, background = 46, bold = true },
  number = { color = 34 },
  preprocessor = { color = 33, bold = true},
  prompt = { color = 36 },
  url = { color = 36, underline = true },
}

-- wrap(context, output, options) {{{1

function formatter.wrap(context, output, options)
  output[#output + 1] = "\027[0m"
  return table.concat(output)
end

-- token(kind, text, url, options) {{{1

function formatter.token(kind, text, url, options)
  options.colors = colors -- Override colors here - other themes don't work yet
  local style = options.colors[kind]
  if style then
    if style.bold then
      text = ('\027[1m%s\027[0m'):format(text)
    end
    if style.underline then
      text = ('\027[4m%s\027[0m'):format(text)
    end
    if style.color then
      text = ('\027[%dm%s\027[39m'):format(style.color, text)
    end
    if style.background then
      text = ('\027[%dm%s\027[49m'):format(style.background, text)
    end
  end
  return text
end

return formatter
