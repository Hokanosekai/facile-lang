%{
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <glib.h>

#include "facile.y.h"

void yyerror(const char *msg);
int yylex();

void begin_code();
void end_code();

%}

%option yylineno

%%

"if"                        {return TOK_IF;}
"then"                      {return TOK_THEN;}
"else"                      {return TOK_ELSE;}
"elif"                      {return TOK_ELIF;}
"endif"                     {return TOK_ENDIF;}

"not"                       {return TOK_NOT;}
"and"                       {return TOK_AND;}
"or"                        {return TOK_OR;}

"read"                      {return TOK_READ;}
"print"                     {return TOK_PRINT;}

"while"                     {return TOK_WHILE;}
"do"                        {return TOK_DO;}
"endwhile"                  {return TOK_ENDWHILE;}

"for"                       {return TOK_FOR;}
"to"                        {return TOK_TO;}
"step"                      {return TOK_STEP;}
"endfor"                    {return TOK_ENDFOR;}

"continue"                  {return TOK_CONTINUE;}
"break"                     {return TOK_BREAK;}
"exit"                      {return TOK_EXIT;}

"true"                      {return TOK_TRUE;}
"false"                     {return TOK_FALSE;}

"=="                        {return TOK_EQEQ;}
">"                         {return TOK_GT;}
"<"                         {return TOK_LT;}
">="                        {return TOK_GTE;}
"<="                        {return TOK_LTE;}
"!="                        {return TOK_NEQ;}
"="                         {return TOK_EQ;}

"+"                         {return TOK_PLUS;}
"-"                         {return TOK_MINUS;}
"*"                         {return TOK_MULT;}
"/"                         {return TOK_DIV;}
"%"                         {return TOK_MOD;}

":="                        {return TOK_ASSIGN;}

"("                         {return TOK_LPAREN;}
")"                         {return TOK_RPAREN;}

[a-zA-Z][a-zA-Z0-9_]*       {yylval.id = yytext;return IDENTIFIER;}
[0-9]+                      {yylval.num = atoi(yytext);return NUMBER;}

\".*\"                      {yylval.str = strdup(yytext);return STRING;}

"//".*                      ;

[ \t\n]                     ;
.                           {ECHO; yyerror("Unexpected character");}

%%

int yywrap (void) {return 1;}