%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern void yyerror(const char *msg);
%}

%token TOK_IF
%token TOK_THEN
%token TOK_ELSE
%token TOK_ELSEIF
%token TOK_ENDIF

%token TOK_NOT
%token TOK_AND
%token TOK_OR

%token TOK_PRINT
%token TOK_READ

%token TOK_WHILE
%token TOK_DO
%token TOK_ENDWHILE

%token TOK_CONTINUE
%token TOK_BREAK
%token TOK_END

%token TOK_ASSIGN

%token TOK_IDENTIFIER
%token TOK_NUMBER

%token TOK_PLUS
%token TOK_MINUS
%token TOK_MULT
%token TOK_DIV
%token TOK_MOD

%token TOK_TRUE
%token TOK_FALSE

%token TOK_LT
%token TOK_GT
%token TOK_LTE
%token TOK_GTE
%token TOK_EQ

%token TOK_LPAREN
%token TOK_RPAREN

%%

program: code;

code: code statement | ;

statement: assignement ;

assignement:
  identifier TOK_ASSIGN expression ;

expression:
  identifier |
  number ;

identifier:
  TOK_IDENTIFIER ;

number:
  TOK_NUMBER ;

%%

void yyerror(const char *msg)
{
  fprintf(stderr, "[ERROR] %s : ", msg);
}

int main(int argc, char **argv)
{
  yyparse();
  return 0;
}