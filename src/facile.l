%{
#include <assert.h>

#include "facile.y.h"
%}

%%

if {
  assert(printf("if token found"));
  return TOK_IF;
}

then {
  assert(printf("then token found"));
  return TOK_THEN;
}

else {
  assert(printf("else token found"));
  return TOK_ELSE;
}

elseif {
  assert(printf("elseif token found"));
  return TOK_ELSEIF;
}

endif {
  assert(printf("endif token found"));
  return TOK_ENDIF;
}

not {
  assert(printf("not token found"));
  return TOK_NOT;
}

and {
  assert(printf("and token found"));
  return TOK_AND;
}

or {
  assert(printf("or token found"));
  return TOK_OR;
}

read {
  assert(printf("read token found"));
  return TOK_READ;
}

print {
  assert(printf("print token found"));
  return TOK_PRINT;
}

while {
  assert(printf("while token found"));
  return TOK_WHILE;
}

do {
  assert(printf("do token found"));
  return TOK_DO;
}

endwhile {
  assert(printf("endwhile token found"));
  return TOK_ENDWHILE;
}

continue {
  assert(printf("continue token found"));
  return TOK_CONTINUE;
}

break {
  assert(printf("break token found"));
  return TOK_BREAK;
}

end {
  assert(printf("end token found"));
  return TOK_END;
}

true {
  assert(printf("true token found"));
  return TOK_TRUE;
}

false {
  assert(printf("false token found"));
  return TOK_FALSE;
}

"==" {
  assert(printf("== token found"));
  return TOK_EQ;
}

">" {
  assert(printf("> token found"));
  return TOK_GT;
}

"<" {
  assert(printf("< token found"));
  return TOK_LT;
}

">=" {
  assert(printf(">= token found"));
  return TOK_GTE;
}

"<=" {
  assert(printf("<= token found"));
  return TOK_LTE;
}

"+" {
  assert(printf("+ token found"));
  return TOK_PLUS;
}

"-" {
  assert(printf("- token found"));
  return TOK_MINUS;
}

"*" {
  assert(printf("* token found"));
  return TOK_MULT;
}

"/" {
  assert(printf("/ token found"));
  return TOK_DIV;
}

"%" {
  assert(printf("%% token found"));
  return TOK_MOD;
}

":=" {
  assert(printf("= token found"));
  return TOK_ASSIGN;
}

"(" {
  assert(printf("( token found"));
  return TOK_LPAREN;
}

")" {
  assert(printf(") token found"));
  return TOK_RPAREN;
}

[a-zA-Z][a-zA-Z0-9_]* {
  assert(printf("identifier '%s' token found", yytext));
  return TOK_IDENTIFIER;
}

[0-9]+ {
  assert(printf("number '%d' token found", atoi(yytext)));
  return TOK_NUMBER;
}

[ \t\n] ;

. {
  ECHO;
}
%%