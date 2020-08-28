flex Lexer.l
bison -dy Parser.y
gcc SymbolTable.c lex.yy.c y.tab.c -o lex.exe
lex.exe < input.txt
pause