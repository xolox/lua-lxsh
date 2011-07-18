Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> -- Load the LXSH module.
> require 'lxsh'
> -- Run the lexer on a string of source code.
> for kind, text in lxsh.lexers.lua.gmatch 'i = i + 1 -- example' do
>>  print(kind, text)
>> end
identifier  i
whitespace   
operator    =
whitespace   
identifier  i
whitespace   
operator    +
whitespace   
number      1
whitespace   
comment     -- example
