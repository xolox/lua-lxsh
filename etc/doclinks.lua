--[[

 Documentation link scanner for the syntax highlighters in the LXSH module.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: July 16, 2011
 URL: http://peterodding.com/code/lua/lxsh/

]]

local include_all_manpages = false

-- This script uses the LuaSocket module to download the
-- Lua 5.1 reference manual and the Lua/APR documentation.
local http = require 'socket.http'

function message(...)
  io.stderr:write(string.format(...), '\n')
end

function download(url)
  message("Fetching %s ..", url)
  return http.request(url)
end

-- Manually defined documentation links (LPeg & C standard library). {{{1
local c_docs = {
  abort = "http://linux.die.net/man/3/abort",
  abs = "http://linux.die.net/man/3/abs",
  acos = "http://linux.die.net/man/3/acos",
  acosf = "http://linux.die.net/man/3/acosf",
  acosl = "http://linux.die.net/man/3/acosl",
  asctime = "http://linux.die.net/man/3/asctime",
  asin = "http://linux.die.net/man/3/asin",
  asinf = "http://linux.die.net/man/3/asinf",
  asinl = "http://linux.die.net/man/3/asinl",
  assert = "http://linux.die.net/man/3/assert",
  atan = "http://linux.die.net/man/3/atan",
  atan2 = "http://linux.die.net/man/3/atan2",
  atan2f = "http://linux.die.net/man/3/atan2f",
  atan2l = "http://linux.die.net/man/3/atan2l",
  atanf = "http://linux.die.net/man/3/atanf",
  atanl = "http://linux.die.net/man/3/atanl",
  atexit = "http://linux.die.net/man/3/atexit",
  atof = "http://linux.die.net/man/3/atof",
  atoi = "http://linux.die.net/man/3/atoi",
  atol = "http://linux.die.net/man/3/atol",
  bsearch = "http://linux.die.net/man/3/bsearch",
  calloc = "http://linux.die.net/man/3/calloc",
  ceil = "http://linux.die.net/man/3/ceil",
  ceilf = "http://linux.die.net/man/3/ceilf",
  ceill = "http://linux.die.net/man/3/ceill",
  clearerr = "http://linux.die.net/man/3/clearerr",
  clock = "http://linux.die.net/man/3/clock",
  cos = "http://linux.die.net/man/3/cos",
  cosf = "http://linux.die.net/man/3/cosf",
  cosh = "http://linux.die.net/man/3/cosh",
  coshf = "http://linux.die.net/man/3/coshf",
  coshl = "http://linux.die.net/man/3/coshl",
  cosl = "http://linux.die.net/man/3/cosl",
  ctime = "http://linux.die.net/man/3/ctime",
  difftime = "http://linux.die.net/man/3/difftime",
  div = "http://linux.die.net/man/3/div",
  div_t = "http://linux.die.net/man/3/div_t",
  EDOM = "http://linux.die.net/man/3/EDOM",
  EILSEQ = "http://linux.die.net/man/3/EILSEQ",
  ERANGE = "http://linux.die.net/man/3/ERANGE",
  errno = "http://linux.die.net/man/3/errno",
  exit = "http://linux.die.net/man/3/exit",
  exp = "http://linux.die.net/man/3/exp",
  expf = "http://linux.die.net/man/3/expf",
  expl = "http://linux.die.net/man/3/expl",
  fabs = "http://linux.die.net/man/3/fabs",
  fabsf = "http://linux.die.net/man/3/fabsf",
  fabsl = "http://linux.die.net/man/3/fabsl",
  fclose = "http://linux.die.net/man/3/fclose",
  feof = "http://linux.die.net/man/3/feof",
  ferror = "http://linux.die.net/man/3/ferror",
  fflush = "http://linux.die.net/man/3/fflush",
  fgetc = "http://linux.die.net/man/3/fgetc",
  fgetpos = "http://linux.die.net/man/3/fgetpos",
  fgets = "http://linux.die.net/man/3/fgets",
  floor = "http://linux.die.net/man/3/floor",
  floorf = "http://linux.die.net/man/3/floorf",
  floorl = "http://linux.die.net/man/3/floorl",
  fmod = "http://linux.die.net/man/3/fmod",
  fmodf = "http://linux.die.net/man/3/fmodf",
  fmodl = "http://linux.die.net/man/3/fmodl",
  fopen = "http://linux.die.net/man/3/fopen",
  fpos_t = "http://linux.die.net/man/3/fpos_t",
  fprintf = "http://linux.die.net/man/3/fprintf",
  fputc = "http://linux.die.net/man/3/fputc",
  fputs = "http://linux.die.net/man/3/fputs",
  fread = "http://linux.die.net/man/3/fread",
  free = "http://linux.die.net/man/3/free",
  freopen = "http://linux.die.net/man/3/freopen",
  frexp = "http://linux.die.net/man/3/frexp",
  frexpf = "http://linux.die.net/man/3/frexpf",
  frexpl = "http://linux.die.net/man/3/frexpl",
  fscanf = "http://linux.die.net/man/3/fscanf",
  fseek = "http://linux.die.net/man/3/fseek",
  fsetpos = "http://linux.die.net/man/3/fsetpos",
  ftell = "http://linux.die.net/man/3/ftell",
  fwrite = "http://linux.die.net/man/3/fwrite",
  getc = "http://linux.die.net/man/3/getc",
  getchar = "http://linux.die.net/man/3/getchar",
  getenv = "http://linux.die.net/man/3/getenv",
  gets = "http://linux.die.net/man/3/gets",
  gmtime = "http://linux.die.net/man/3/gmtime",
  HUGE_VAL = "http://linux.die.net/man/3/HUGE_VAL",
  isalnum = "http://linux.die.net/man/3/isalnum",
  isalpha = "http://linux.die.net/man/3/isalpha",
  iscntrl = "http://linux.die.net/man/3/iscntrl",
  isdigit = "http://linux.die.net/man/3/isdigit",
  isgraph = "http://linux.die.net/man/3/isgraph",
  islower = "http://linux.die.net/man/3/islower",
  isprint = "http://linux.die.net/man/3/isprint",
  ispunct = "http://linux.die.net/man/3/ispunct",
  isspace = "http://linux.die.net/man/3/isspace",
  isupper = "http://linux.die.net/man/3/isupper",
  isxdigit = "http://linux.die.net/man/3/isxdigit",
  jmp_buf = "http://linux.die.net/man/3/jmp_buf",
  labs = "http://linux.die.net/man/3/labs",
  LC_ALL = "http://linux.die.net/man/3/LC_ALL",
  LC_COLLATE = "http://linux.die.net/man/3/LC_COLLATE",
  LC_CTYPE = "http://linux.die.net/man/3/LC_CTYPE",
  LC_MONETARY = "http://linux.die.net/man/3/LC_MONETARY",
  LC_NUMERIC = "http://linux.die.net/man/3/LC_NUMERIC",
  LC_TIME = "http://linux.die.net/man/3/LC_TIME",
  lconv = "http://linux.die.net/man/3/lconv",
  ldexp = "http://linux.die.net/man/3/ldexp",
  ldexpf = "http://linux.die.net/man/3/ldexpf",
  ldexpl = "http://linux.die.net/man/3/ldexpl",
  ldiv = "http://linux.die.net/man/3/ldiv",
  ldiv_t = "http://linux.die.net/man/3/ldiv_t",
  localeconv = "http://linux.die.net/man/3/localeconv",
  localtime = "http://linux.die.net/man/3/localtime",
  log = "http://linux.die.net/man/3/log",
  log10 = "http://linux.die.net/man/3/log10",
  log10f = "http://linux.die.net/man/3/log10f",
  log10l = "http://linux.die.net/man/3/log10l",
  logf = "http://linux.die.net/man/3/logf",
  logl = "http://linux.die.net/man/3/logl",
  longjmp = "http://linux.die.net/man/3/longjmp",
  malloc = "http://linux.die.net/man/3/malloc",
  mblen = "http://linux.die.net/man/3/mblen",
  mbstowcs = "http://linux.die.net/man/3/mbstowcs",
  mbtowc = "http://linux.die.net/man/3/mbtowc",
  memchr = "http://linux.die.net/man/3/memchr",
  memcmp = "http://linux.die.net/man/3/memcmp",
  memcpy = "http://linux.die.net/man/3/memcpy",
  memmove = "http://linux.die.net/man/3/memmove",
  memset = "http://linux.die.net/man/3/memset",
  mktime = "http://linux.die.net/man/3/mktime",
  modf = "http://linux.die.net/man/3/modf",
  modff = "http://linux.die.net/man/3/modff",
  modfl = "http://linux.die.net/man/3/modfl",
  perror = "http://linux.die.net/man/3/perror",
  pow = "http://linux.die.net/man/3/pow",
  powf = "http://linux.die.net/man/3/powf",
  powl = "http://linux.die.net/man/3/powl",
  printf = "http://linux.die.net/man/3/printf",
  putc = "http://linux.die.net/man/3/putc",
  putchar = "http://linux.die.net/man/3/putchar",
  puts = "http://linux.die.net/man/3/puts",
  qsort = "http://linux.die.net/man/3/qsort",
  raise = "http://linux.die.net/man/3/raise",
  rand = "http://linux.die.net/man/3/rand",
  realloc = "http://linux.die.net/man/3/realloc",
  remove = "http://linux.die.net/man/3/remove",
  rename = "http://linux.die.net/man/3/rename",
  rewind = "http://linux.die.net/man/3/rewind",
  scanf = "http://linux.die.net/man/3/scanf",
  setbuf = "http://linux.die.net/man/3/setbuf",
  setjmp = "http://linux.die.net/man/3/setjmp",
  setlocale = "http://linux.die.net/man/3/setlocale",
  setvbuf = "http://linux.die.net/man/3/setvbuf",
  SIG_DFL = "http://linux.die.net/man/3/SIG_DFL",
  SIG_ERR = "http://linux.die.net/man/3/SIG_ERR",
  SIG_IGN = "http://linux.die.net/man/3/SIG_IGN",
  SIGABRT = "http://linux.die.net/man/3/SIGABRT",
  SIGFPE = "http://linux.die.net/man/3/SIGFPE",
  SIGILL = "http://linux.die.net/man/3/SIGILL",
  SIGINT = "http://linux.die.net/man/3/SIGINT",
  signal = "http://linux.die.net/man/3/signal",
  SIGSEGV = "http://linux.die.net/man/3/SIGSEGV",
  SIGTERM = "http://linux.die.net/man/3/SIGTERM",
  sin = "http://linux.die.net/man/3/sin",
  sinf = "http://linux.die.net/man/3/sinf",
  sinh = "http://linux.die.net/man/3/sinh",
  sinhf = "http://linux.die.net/man/3/sinhf",
  sinhl = "http://linux.die.net/man/3/sinhl",
  sinl = "http://linux.die.net/man/3/sinl",
  sprintf = "http://linux.die.net/man/3/sprintf",
  sqrt = "http://linux.die.net/man/3/sqrt",
  sqrtf = "http://linux.die.net/man/3/sqrtf",
  sqrtl = "http://linux.die.net/man/3/sqrtl",
  srand = "http://linux.die.net/man/3/srand",
  sscanf = "http://linux.die.net/man/3/sscanf",
  stderr = "http://linux.die.net/man/3/stderr",
  stdin = "http://linux.die.net/man/3/stdin",
  stdout = "http://linux.die.net/man/3/stdout",
  strcat = "http://linux.die.net/man/3/strcat",
  strchr = "http://linux.die.net/man/3/strchr",
  strcmp = "http://linux.die.net/man/3/strcmp",
  strcoll = "http://linux.die.net/man/3/strcoll",
  strcpy = "http://linux.die.net/man/3/strcpy",
  strcspn = "http://linux.die.net/man/3/strcspn",
  strerror = "http://linux.die.net/man/3/strerror",
  strftime = "http://linux.die.net/man/3/strftime",
  strlen = "http://linux.die.net/man/3/strlen",
  strncat = "http://linux.die.net/man/3/strncat",
  strncmp = "http://linux.die.net/man/3/strncmp",
  strncpy = "http://linux.die.net/man/3/strncpy",
  strpbrk = "http://linux.die.net/man/3/strpbrk",
  strrchr = "http://linux.die.net/man/3/strrchr",
  strspn = "http://linux.die.net/man/3/strspn",
  strstr = "http://linux.die.net/man/3/strstr",
  strtod = "http://linux.die.net/man/3/strtod",
  strtok = "http://linux.die.net/man/3/strtok",
  strtol = "http://linux.die.net/man/3/strtol",
  strtoul = "http://linux.die.net/man/3/strtoul",
  strxfrm = "http://linux.die.net/man/3/strxfrm",
  system = "http://linux.die.net/man/3/system",
  tan = "http://linux.die.net/man/3/tan",
  tanf = "http://linux.die.net/man/3/tanf",
  tanh = "http://linux.die.net/man/3/tanh",
  tanhf = "http://linux.die.net/man/3/tanhf",
  tanhl = "http://linux.die.net/man/3/tanhl",
  tanl = "http://linux.die.net/man/3/tanl",
  tmpfile = "http://linux.die.net/man/3/tmpfile",
  tmpnam = "http://linux.die.net/man/3/tmpnam",
  tolower = "http://linux.die.net/man/3/tolower",
  toupper = "http://linux.die.net/man/3/toupper",
  ungetc = "http://linux.die.net/man/3/ungetc",
  va_arg = "http://linux.die.net/man/3/va_arg",
  va_end = "http://linux.die.net/man/3/va_end",
  va_list = "http://linux.die.net/man/3/va_list",
  va_start = "http://linux.die.net/man/3/va_start",
  vfprintf = "http://linux.die.net/man/3/vfprintf",
  vprintf = "http://linux.die.net/man/3/vprintf",
  vsprintf = "http://linux.die.net/man/3/vsprintf",
  wchar_t = "http://linux.die.net/man/3/wchar_t",
  wcstombs = "http://linux.die.net/man/3/wcstombs",
  wctomb = "http://linux.die.net/man/3/wctomb",
}
local lua_docs = {
  ['lpeg.match'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-match',
  ['lpeg.type'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-type',
  ['lpeg.version'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-version',
  ['lpeg.setstack'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#f-setmaxstack',
  ['lpeg.P'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-p',
  ['lpeg.B'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-behind',
  ['lpeg.R'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-r',
  ['lpeg.S'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-s',
  ['lpeg.V'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-v',
  ['lpeg.locale'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#op-locale',
  ['lpeg.C'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-c',
  ['lpeg.Carg'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-arg',
  ['lpeg.Cb'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-b',
  ['lpeg.Cc'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-cc',
  ['lpeg.Cf'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-f',
  ['lpeg.Cg'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-g',
  ['lpeg.Cp'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-p',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Ct'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-t',
  ['lpeg.Cmt'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#matchtime',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
  ['lpeg.Cs'] = 'http://www.inf.puc-rio.br/~roberto/lpeg/#cap-s',
}

-- Scan the Lua reference manual for documentation links. {{{1
local lua_refman = 'http://www.lua.org/manual/5.1/manual.html'
for anchor in download(lua_refman):gmatch 'name="([^"]+)"' do
  local id = anchor:gsub('^pdf%-', '')
  if anchor:find '^pdf%-'
      and not anchor:find '^pdf%-LUA_'
      and not anchor:find '%.h$'
      and not anchor:find 'luaopen'
      and anchor ~= 'pdf-luai_apicheck'
      and anchor ~= 'pdf-LUAL_BUFFERSIZE'
      then
    lua_docs[id] = lua_refman .. '#' .. anchor
  elseif anchor:find '^luaL?_' or anchor:find '^pdf%-LUAL?_' then
    c_docs[id] = lua_refman .. '#' .. anchor
  end
end

-- Scan the Lua/APR manual for documentation links. {{{1
local lua_apr_docs = 'http://peterodding.com/code/lua/apr/docs/'
for id in download(lua_apr_docs):gmatch 'name="(apr%.[A-Za-z0-9_]+)"' do
  lua_docs[id] = lua_apr_docs .. '#' .. id
end

-- Scan section 3 (library calls) of the Linux man pages (disabled). {{{1

-- The following code is not enabled by default because it results in a 1,1 MB
-- Lua script which may be a bit much to commit or include in installations.
local manpages = 'http://linux.die.net/man/3/'
if include_all_manpages then
  local source = http.request(manpages)
  local body = source:match '<dl[^>]*>(.-)</dl>'
  for id in body:gmatch 'href="([A-Za-z0-9_]+)"' do
    c_docs[id] = manpages .. id
  end
end

-- Generate the src/docs/*.lua scripts. {{{1

function sorted(input)
  local keys = {}
  for key in pairs(input) do table.insert(keys, key) end
  table.sort(keys, function(a, b) return a:lower() < b:lower() end)
  local index = 1
  return function()
    local key = keys[index]
    index = index + 1
    return key, input[key]
  end
end

function dump(language, doclinks)
  local lines = {}
  for id, url in sorted(doclinks) do
    if id:find '^[A-Za-z_][A-Za-z0-9_]*$' then
      lines[#lines + 1] = string.format('%s=%q,', id, url)
    else
      lines[#lines + 1] = string.format('[%q]=%q,', id, url)
    end
  end
  local outfile = 'src/docs/' .. language:lower() .. '.lua'
  message("Generating %s ..", outfile)
  local handle = assert(io.open(outfile, 'w'))
  handle:write(string.format([=[
--[[

 Documentation links for the %s syntax highlighter of the LXSH module.

 Author: Peter Odding <peter@peterodding.com>
 Last Change: %s
 URL: http://peterodding.com/code/lua/lxsh/

 Generated by http://github.com/xolox/lua-lxsh/blob/master/etc/doclinks.lua.

]]

return {
%s
}
]=], language, os.date '%B %d, %Y', table.concat(lines, '\n')))
end

dump('Lua', lua_docs)
dump('C', c_docs)
