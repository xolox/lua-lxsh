-- Run this Lua script from the project root.

local lxsh = require 'lxsh'
local delete_intermediates = true

local function readfile(path)
  local handle = assert(io.open(path))
  local data = assert(handle:read '*a')
  assert(handle:close())
  return data
end

local function writefile(path, data)
  local handle = assert(io.open(path, 'w'))
  handle:write(data)
  local nbytes = handle:seek()
  assert(handle:close())
  return nbytes
end

for _, formatter in ipairs { lxsh.formatters.html, lxsh.formatters.rtf, lxsh.formatters.latex } do
  for _, colors in ipairs { 'earendel', 'slate', 'wiki' } do
    local function demo(infile, outfile, highlighter)
      local input = readfile(infile)
      local nbytes = writefile(outfile, highlighter(input, {
        demo = true,
        external = true,
        colors = lxsh.colors[colors],
        formatter = formatter,
      }))
      io.stderr:write(('Wrote %iK to %s!\n'):format(nbytes/1024, outfile))
      if outfile:find '%.tex$' then
        -- Try to run the LaTeX PDF compiler (tested on Ubuntu 10.04 with texlive).
        -- Requires "Bera Mono" (try `sudo apt-get install texlive-fonts-extra').
        local outdir, filename = outfile:match '^(.-)([^/]*)$'
        local command = 'pdflatex -interaction batchmode -halt-on-error ' .. filename -- .. ' >/dev/null 2>&1'
        io.stderr:write(" - Compiling ", outfile:gsub('%.tex$', '.pdf'), ": ")
        local status = os.execute('cd ' .. outdir .. ' && ' .. command .. ' && ' .. command)
        io.stderr:write(status == 0 and "OK" or "Failed! (do you have LaTeX installed?)", "\n")
        -- Cleanup temporary files.
        if delete_intermediates and status == 0 then os.remove(outfile) end
        os.remove((outfile:gsub('%.tex$', '.aux')))
        os.remove((outfile:gsub('%.tex$', '.log')))
        os.remove((outfile:gsub('%.tex$', '.out')))
      end
    end
    -- Highlight example Lua source code (from my Lua/APR binding).
    demo('examples/apr.lua', 'examples/' .. colors .. '/apr.lua' .. formatter.extension, lxsh.highlighters.lua)
    -- Highlight example Lua source code copied from the interactive prompt.
    demo('examples/prompt.lua', 'examples/' .. colors .. '/prompt.lua' .. formatter.extension, lxsh.highlighters.lua)
    -- Highlight example C source code (also from my Lua/APR binding).
    demo('examples/lua_apr.c', 'examples/' .. colors .. '/lua_apr.c' .. formatter.extension, lxsh.highlighters.c)
    -- Highlight example BibTeX entry (from http://en.wikipedia.org/wiki/BibTeX#Examples).
    demo('examples/entry.bib', 'examples/' .. colors .. '/entry.bib' .. formatter.extension, lxsh.highlighters.bib)
    -- Highlight example shell script code (something random from my ~/bin).
    demo('examples/gvim.sh', 'examples/' .. colors .. '/gvim.sh' .. formatter.extension, lxsh.highlighters.sh)
  end
end
