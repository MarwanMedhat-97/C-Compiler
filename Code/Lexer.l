%{   
	#include <stdlib.h>
	#include <stdio.h>
	#include "y.tab.h"
	#include<string.h>
	void yyerror (char *s);
	int yylineno=1;
	int yylex();
%}

%%	
"+"												return PLUS;
"-"												return MINUS;
"*"												return MULTIPLY;
"/"												return DIVIDE;
"="												return ASSIGN;
"&&"											return AND;
"||"											return OR;
"!"												return NOT;
"++"			                        		return INC;
"--"	                         				return DEC;
"+="											return PLUSEQUAL;
"-="											return MINUSEQUAL;
"*="											return MULTIPLYEQUAL;
"/="											return DIVIDEEQUAL;
"print"        									return PRINT;
"int"											return INT;
"float"											return FLOAT;
"char"											return CHAR;
"string"										return STRING;
"bool"				    						return BOOL;
"const"                 						return CONST;
"true"											return TRUE;
"false"											return FALSE;	
">"         	 								return GREATERTHAN;
"<"         	 								return LESSTHAN;
">="         	 								return GREATERTHANOREQUAL;
"<="             								return LESSTHANOREQUAL;
"=="             								return EQUALEQUAL;
"!="             								return NOTEQUAL;
"{"                      						return OBRACE;   
"}"                      						return CBRACE;
"("												return OBRACKET;
")"												return CBRACKET;
";"                       						return SEMICOLON;
"while"          								return WHILE;
"for"          									return FOR;
"if"             								return IF;
"else"           								return ELSE;		



[0-9]+											{yylval.IntgerValue = atoi(yytext); return INTEGERNUMBER;}
[0-9]+\.[0-9]+									{yylval.FloatValue = atof(yytext); return FLOATNUMBER;}
\".*\"											{yylval.StringValue=strdup(yytext);return TEXT;}
\'.?\'											{yylval.StringValue=strdup(yytext);return CHARACTER;}
[a-zA-Z][_a-zA-Z0-9]*							{yylval.StringValue=strdup(yytext);return Var_Name;} 
[\t  ]+											/* ignore whitespace */;
[\n]											{yylineno = yylineno+1;}
.                                               {yyerror("UnExpectedToken");}
%% 

int yywrap (void) {
	return 1;
}