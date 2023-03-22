%{
#include <assert.h>

// Conditional
#define TOK_IF              258
#define TOK_THEN            259
#define TOK_ELSE            260
#define TOK_ELSEIF          261
#define TOK_ENDIF           262

#define TOK_NOT             263
#define TOK_AND             264
#define TOK_OR              265

// I/O
#define TOK_READ            266
#define TOK_PRINT           267

// While loop
#define TOK_WHILE           268
#define TOK_DO              269
#define TOK_ENDWHILE        270

// Control flow
#define TOK_CONTINUE        271
#define TOK_BREAK           272
#define TOK_END             273

// Boolean literals
#define TOK_TRUE            274
#define TOK_FALSE           275

// Comparison operators
#define TOK_EQ              276
#define TOK_GT              277
#define TOK_LT              278
#define TOK_GTE             279
#define TOK_LTE             280

// Arithmetic operators
#define TOK_PLUS            281
#define TOK_MINUS           282
#define TOK_MULT            283
#define TOK_DIV             284
#define TOK_MOD             285

// Assignment operator
#define TOK_ASSIGN          286

// Other
#define TOK_LPAREN          287
#define TOK_RPAREN          288

// Identifier
#define TOK_IDENTIFIER      289

// Number
#define TOK_NUMBER          290
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

[a-zA-Z][a-zA-Z0-9]* {
  assert(printf("identifier '%s' token found", yytext));
  return TOK_IDENTIFIER;
}

[0-9]+ {
  assert(printf("number '%d' token found", atoi(yytext)));
  return TOK_NUMBER;
}

[ab]*a[ab]*b[ab]*b[ab]*a assert(printf("'abba' token found")); return yytext[0];

%%