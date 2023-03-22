%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyerror(const char *msg);
extern int yylineno;
%}

%define parse.error verbose

%token TOK_IF             "if"
%token TOK_THEN           "then"
%token TOK_ELSE           "else"
%token TOK_ELSEIF         "elseif"
%token TOK_ENDIF          "endif"

%token TOK_NOT            "not"
%token TOK_AND            "and"
%token TOK_OR             "or"

%token TOK_PRINT          "print"
%token TOK_READ           "read"

%token TOK_WHILE          "while"
%token TOK_DO             "do"
%token TOK_ENDWHILE       "endwhile"

%token TOK_CONTINUE       "continue"
%token TOK_BREAK          "break"
%token TOK_END            "end"

%token TOK_ASSIGN         ":="

%token TOK_IDENTIFIER     "identifier"
%token TOK_NUMBER         "number"

%token TOK_PLUS           "+"
%token TOK_MINUS          "-"
%token TOK_MULT           "*"
%token TOK_DIV            "/"
%token TOK_MOD            "%"

%token TOK_TRUE           "true"
%token TOK_FALSE          "false"

%token TOK_LT             "<"
%token TOK_GT             ">"
%token TOK_LTE            "<="
%token TOK_GTE            ">="
%token TOK_EQ             "=="

%token TOK_LPAREN         "("
%token TOK_RPAREN         ")"

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

int yyerror(const char *msg)
{
  fprintf(stderr, "[ERROR] Line %d: %s : ", yylineno, msg);
}

int main(int argc, char **argv)
{
  yyparse();
  return 0;
}