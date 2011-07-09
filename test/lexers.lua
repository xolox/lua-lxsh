local verbose = true

local escape_sequences = {
  ['\0'] = '\\0',
  ['\r'] = '\\r',
  ['\n'] = '\\n',
  ['\f'] = '\\f',
  ['\t'] = '\\t',
  ['\v'] = '\\v',
  ['\''] = '\\\'',
}
local function quote_string(s)
  return "'" .. s:gsub('[%z\r\n\f\t\v\']', function(c)
    return escape_sequences[c] or c
  end) .. "'"
end

-- Check that token stream returned by lexer matches expected output.
local function check_tokens(iterator, table)
  local i = 0
  for kind, text in iterator do
    i = i + 1
    if verbose then
      print("Checking", table[i][1])
      print(string.format(" - Expecting (%s, %s)", table[i][1], quote_string(table[i][2])))
      print(string.format(" - Received  (%s, %s)", kind, quote_string(text)))
    end
    assert(table[i][1] == kind)
    assert(table[i][2] == text)
  end
  assert(i == #table)
end

-- Tests for the Lua lexer. {{{1

local lua_lexer = require 'lxsh.lexers.lua'

-- Whitespace characters. {{{2
check_tokens(lua_lexer.gmatch '\r\n\f\t\v ', {
  { 'whitespace', '\r\n\f\t\v ' },
})

-- Constants (true, false and nil). {{{2
check_tokens(lua_lexer.gmatch 'true false nil', {
  { 'constant', 'true' },
  { 'whitespace', ' ' },
  { 'constant', 'false' },
  { 'whitespace', ' ' },
  { 'constant', 'nil' },
})

-- Interactive prompt. {{{2
check_tokens(lua_lexer.gmatch [[
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> print "Hello world!"]], {
  { 'prompt', 'Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio' },
  { 'whitespace', '\n' },
  { 'prompt', '>' },
  { 'whitespace', ' ' },
  { 'identifier', 'print' },
  { 'whitespace', ' ' },
  { 'string', '"Hello world!"' },
})

-- Numbers. {{{2
check_tokens(lua_lexer.gmatch '1 3.14 1. .1 0x0123456789ABCDEF 1e5', {
  { 'number', '1' },
  { 'whitespace', ' ' },
  { 'number', '3.14' },
  { 'whitespace', ' ' },
  { 'number', '1.' },
  { 'whitespace', ' ' },
  { 'number', '.1' },
  { 'whitespace', ' ' },
  { 'number', '0x0123456789ABCDEF' },
  { 'whitespace', ' ' },
  { 'number', '1e5' },
})

-- String literals. {{{2
check_tokens(lua_lexer.gmatch [==[
'single quoted string'
"double quoted string"
[[long string]]
[[multi line
long string]]
[=[nested [[long]] string]=]
]==], {
  { 'string', "'single quoted string'" },
  { 'whitespace', '\n' },
  { 'string', '"double quoted string"' },
  { 'whitespace', '\n' },
  { 'string', '[[long string]]' },
  { 'whitespace', '\n' },
  { 'string', '[[multi line\nlong string]]' },
  { 'whitespace', '\n' },
  { 'string', '[=[nested [[long]] string]=]' },
  { 'whitespace', '\n' },
})

-- Comments. {{{2
check_tokens(lua_lexer.gmatch [==[
#!shebang line
-- single line comment
--[[
long
comment
]]
--[[
nested
--[=[long]=]
comment
]]
]==], {
  { 'comment', '#!shebang line\n' },
  { 'comment', '-- single line comment\n' },
  { 'comment', '--[[\nlong\ncomment\n]]' },
  { 'whitespace', '\n' },
  { 'comment', '--[[\nnested\n--[=[long]=]\ncomment\n]]' },
  { 'whitespace', '\n' },
})

-- Operators. {{{2
local operators = 'not ... and .. ~= == >= <= or ] { = > ^ [ < ; ) * ( % } + - : , / . #'
check_tokens(lua_lexer.gmatch(operators), {
  { 'operator', 'not' },
  { 'whitespace', ' ' },
  { 'operator', '...' },
  { 'whitespace', ' ' },
  { 'operator', 'and' },
  { 'whitespace', ' ' },
  { 'operator', '..' },
  { 'whitespace', ' ' },
  { 'operator', '~=' },
  { 'whitespace', ' ' },
  { 'operator', '==' },
  { 'whitespace', ' ' },
  { 'operator', '>=' },
  { 'whitespace', ' ' },
  { 'operator', '<=' },
  { 'whitespace', ' ' },
  { 'operator', 'or' },
  { 'whitespace', ' ' },
  { 'operator', ']' },
  { 'whitespace', ' ' },
  { 'operator', '{' },
  { 'whitespace', ' ' },
  { 'operator', '=' },
  { 'whitespace', ' ' },
  { 'operator', '>' },
  { 'whitespace', ' ' },
  { 'operator', '^' },
  { 'whitespace', ' ' },
  { 'operator', '[' },
  { 'whitespace', ' ' },
  { 'operator', '<' },
  { 'whitespace', ' ' },
  { 'operator', ';' },
  { 'whitespace', ' ' },
  { 'operator', ')' },
  { 'whitespace', ' ' },
  { 'operator', '*' },
  { 'whitespace', ' ' },
  { 'operator', '(' },
  { 'whitespace', ' ' },
  { 'operator', '%' },
  { 'whitespace', ' ' },
  { 'operator', '}' },
  { 'whitespace', ' ' },
  { 'operator', '+' },
  { 'whitespace', ' ' },
  { 'operator', '-' },
  { 'whitespace', ' ' },
  { 'operator', ':' },
  { 'whitespace', ' ' },
  { 'operator', ',' },
  { 'whitespace', ' ' },
  { 'operator', '/' },
  { 'whitespace', ' ' },
  { 'operator', '.' },
  { 'whitespace', ' ' },
  { 'operator', '#' },
})

-- Keywords. {{{2
local keywords = 'break do else elseif end for function if in local repeat return then until while'
check_tokens(lua_lexer.gmatch(keywords), {
  { 'keyword', 'break' }, { 'whitespace', ' ' },
  { 'keyword', 'do' }, { 'whitespace', ' ' },
  { 'keyword', 'else' }, { 'whitespace', ' ' },
  { 'keyword', 'elseif' }, { 'whitespace', ' ' },
  { 'keyword', 'end' }, { 'whitespace', ' ' },
  { 'keyword', 'for' }, { 'whitespace', ' ' },
  { 'keyword', 'function' }, { 'whitespace', ' ' },
  { 'keyword', 'if' }, { 'whitespace', ' ' },
  { 'keyword', 'in' }, { 'whitespace', ' ' },
  { 'keyword', 'local' }, { 'whitespace', ' ' },
  { 'keyword', 'repeat' }, { 'whitespace', ' ' },
  { 'keyword', 'return' }, { 'whitespace', ' ' },
  { 'keyword', 'then' }, { 'whitespace', ' ' },
  { 'keyword', 'until' }, { 'whitespace', ' ' },
  { 'keyword', 'while' },
})

-- Tests for the C lexer. {{{1

local c_lexer = require 'lxsh.lexers.c'

-- Whitespace characters. {{{2
check_tokens(c_lexer.gmatch '\r\n\f\t\v ', {
  { 'whitespace', '\r\n\f\t\v ' },
})

-- Identifiers. {{{2
check_tokens(c_lexer.gmatch 'variable=value', {
  { 'identifier', 'variable' },
  { 'operator', '=' },
  { 'identifier', 'value' },
})

-- Preprocessor instructions. {{{2
check_tokens(c_lexer.gmatch [[
#if
#else
#endif
#define foo bar
#define \
  foo \
  bar
]], {
  { 'preprocessor', '#if\n' },
  { 'preprocessor', '#else\n' },
  { 'preprocessor', '#endif\n' },
  { 'preprocessor', '#define foo bar\n' },
  { 'preprocessor', '#define \\\n  foo \\\n  bar\n' },
})

-- Character and string literals. {{{2
check_tokens(c_lexer.gmatch [[
'c'
'\n'
'\000'
'\xFF'
"string literal"
"multi line\
string literal"
]], {
  { 'constant', "'c'" },
  { 'whitespace', '\n' },
  { 'constant', "'\\n'" },
  { 'whitespace', '\n' },
  { 'constant', "'\\000'" },
  { 'whitespace', '\n' },
  { 'constant', "'\\xFF'" },
  { 'whitespace', '\n' },
  { 'constant', '"string literal"' },
  { 'whitespace', '\n' },
  { 'constant', '"multi line\\\nstring literal"' },
  { 'whitespace', '\n' },
})

-- Comments. {{{2
check_tokens(c_lexer.gmatch [[
// single line comment
/* multi
   line
   comment */
]], {
  { 'comment', '// single line comment\n' },
  { 'comment', '/* multi\n   line\n   comment */' },
  { 'whitespace', '\n' },
})

-- Operators. {{{2
check_tokens(c_lexer.gmatch [[
>>=
<<=
--
>>
>=
/=
==
<=
+=
<<
*=
++
&&
|=
||
!=
&=
-=
^=
%=
->
,
)
*
%
+
&
(
-
~
/
^
]
{
}
|
.
[
>
!
?
:
=
<
;
]], {
  { 'operator', '>>=' },
  { 'whitespace', '\n' },
  { 'operator', '<<=' },
  { 'whitespace', '\n' },
  { 'operator', '--' },
  { 'whitespace', '\n' },
  { 'operator', '>>' },
  { 'whitespace', '\n' },
  { 'operator', '>=' },
  { 'whitespace', '\n' },
  { 'operator', '/=' },
  { 'whitespace', '\n' },
  { 'operator', '==' },
  { 'whitespace', '\n' },
  { 'operator', '<=' },
  { 'whitespace', '\n' },
  { 'operator', '+=' },
  { 'whitespace', '\n' },
  { 'operator', '<<' },
  { 'whitespace', '\n' },
  { 'operator', '*=' },
  { 'whitespace', '\n' },
  { 'operator', '++' },
  { 'whitespace', '\n' },
  { 'operator', '&&' },
  { 'whitespace', '\n' },
  { 'operator', '|=' },
  { 'whitespace', '\n' },
  { 'operator', '||' },
  { 'whitespace', '\n' },
  { 'operator', '!=' },
  { 'whitespace', '\n' },
  { 'operator', '&=' },
  { 'whitespace', '\n' },
  { 'operator', '-=' },
  { 'whitespace', '\n' },
  { 'operator', '^=' },
  { 'whitespace', '\n' },
  { 'operator', '%=' },
  { 'whitespace', '\n' },
  { 'operator', '->' },
  { 'whitespace', '\n' },
  { 'operator', ',' },
  { 'whitespace', '\n' },
  { 'operator', ')' },
  { 'whitespace', '\n' },
  { 'operator', '*' },
  { 'whitespace', '\n' },
  { 'operator', '%' },
  { 'whitespace', '\n' },
  { 'operator', '+' },
  { 'whitespace', '\n' },
  { 'operator', '&' },
  { 'whitespace', '\n' },
  { 'operator', '(' },
  { 'whitespace', '\n' },
  { 'operator', '-' },
  { 'whitespace', '\n' },
  { 'operator', '~' },
  { 'whitespace', '\n' },
  { 'operator', '/' },
  { 'whitespace', '\n' },
  { 'operator', '^' },
  { 'whitespace', '\n' },
  { 'operator', ']' },
  { 'whitespace', '\n' },
  { 'operator', '{' },
  { 'whitespace', '\n' },
  { 'operator', '}' },
  { 'whitespace', '\n' },
  { 'operator', '|' },
  { 'whitespace', '\n' },
  { 'operator', '.' },
  { 'whitespace', '\n' },
  { 'operator', '[' },
  { 'whitespace', '\n' },
  { 'operator', '>' },
  { 'whitespace', '\n' },
  { 'operator', '!' },
  { 'whitespace', '\n' },
  { 'operator', '?' },
  { 'whitespace', '\n' },
  { 'operator', ':' },
  { 'whitespace', '\n' },
  { 'operator', '=' },
  { 'whitespace', '\n' },
  { 'operator', '<' },
  { 'whitespace', '\n' },
  { 'operator', ';' },
  { 'whitespace', '\n' },
})

-- Numbers. {{{2
check_tokens(c_lexer.gmatch [[
0x0123456789ABCDEFabcdef
123456789
01234567
0x1l
500LL
1.0
1.
.1
1f
]], {
  { 'number', '0x0123456789ABCDEFabcdef' },
  { 'whitespace', '\n' },
  { 'number', '123456789' },
  { 'whitespace', '\n' },
  { 'number', '01234567' },
  { 'whitespace', '\n' },
  { 'number', '0x1l' },
  { 'whitespace', '\n' },
  { 'number', '500LL' },
  { 'whitespace', '\n' },
  { 'number', '1.0' },
  { 'whitespace', '\n' },
  { 'number', '1.' },
  { 'whitespace', '\n' },
  { 'number', '.1' },
  { 'whitespace', '\n' },
  { 'number', '1f' },
  { 'whitespace', '\n' },
})

-- Keywords. {{{2
check_tokens(c_lexer.gmatch [[
auto
break
case
char
const
continue
default
do
double
else
enum
extern
float
for
goto
if
int
long
register
return
short
signed
sizeof
static
struct
switch
typedef
union
unsigned
void
volatile
while
]], {
  { 'keyword', 'auto' }, { 'whitespace', '\n' },
  { 'keyword', 'break' }, { 'whitespace', '\n' },
  { 'keyword', 'case' }, { 'whitespace', '\n' },
  { 'keyword', 'char' }, { 'whitespace', '\n' },
  { 'keyword', 'const' }, { 'whitespace', '\n' },
  { 'keyword', 'continue' }, { 'whitespace', '\n' },
  { 'keyword', 'default' }, { 'whitespace', '\n' },
  { 'keyword', 'do' }, { 'whitespace', '\n' },
  { 'keyword', 'double' }, { 'whitespace', '\n' },
  { 'keyword', 'else' }, { 'whitespace', '\n' },
  { 'keyword', 'enum' }, { 'whitespace', '\n' },
  { 'keyword', 'extern' }, { 'whitespace', '\n' },
  { 'keyword', 'float' }, { 'whitespace', '\n' },
  { 'keyword', 'for' }, { 'whitespace', '\n' },
  { 'keyword', 'goto' }, { 'whitespace', '\n' },
  { 'keyword', 'if' }, { 'whitespace', '\n' },
  { 'keyword', 'int' }, { 'whitespace', '\n' },
  { 'keyword', 'long' }, { 'whitespace', '\n' },
  { 'keyword', 'register' }, { 'whitespace', '\n' },
  { 'keyword', 'return' }, { 'whitespace', '\n' },
  { 'keyword', 'short' }, { 'whitespace', '\n' },
  { 'keyword', 'signed' }, { 'whitespace', '\n' },
  { 'keyword', 'sizeof' }, { 'whitespace', '\n' },
  { 'keyword', 'static' }, { 'whitespace', '\n' },
  { 'keyword', 'struct' }, { 'whitespace', '\n' },
  { 'keyword', 'switch' }, { 'whitespace', '\n' },
  { 'keyword', 'typedef' }, { 'whitespace', '\n' },
  { 'keyword', 'union' }, { 'whitespace', '\n' },
  { 'keyword', 'unsigned' }, { 'whitespace', '\n' },
  { 'keyword', 'void' }, { 'whitespace', '\n' },
  { 'keyword', 'volatile' }, { 'whitespace', '\n' },
  { 'keyword', 'while' }, { 'whitespace', '\n' },
})
