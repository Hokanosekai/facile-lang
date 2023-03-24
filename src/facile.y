%{
#include <stdio.h>
#include <stdlib.h>

extern int yylineno;

int yylex();
void yyerror(const char *msg);

int symbol_table[52];

int compute(char *symbol)

int symbol_lookup(char *symbol);
int symbol_insert(char *symbol, int value);

%}

%union {
  char   *id;
  int    num;
}

%start line

%token              TOK_IF             
%token              TOK_THEN           
%token              TOK_ELSE           
%token              TOK_ELSEIF         
%token              TOK_ENDIF          

%token              TOK_NOT            
%token              TOK_AND            
%token              TOK_OR             

%token              TOK_PRINT          
%token              TOK_READ           

%token              TOK_WHILE          
%token              TOK_DO             
%token              TOK_ENDWHILE       

%token              TOK_CONTINUE       
%token              TOK_BREAK          
%token              TOK_END            

%token              TOK_ASSIGN         

%token<id>          IDENTIFIER
%token<num>         NUMBER

%left               TOK_PLUS           
%left               TOK_MINUS          
%left               TOK_MULT           
%left               TOK_DIV            
%left               TOK_MOD            

%token              TOK_TRUE           
%token              TOK_FALSE          

%token              TOK_LT
%token              TOK_GT             
%token              TOK_LTE            
%token              TOK_GTE            
%token              TOK_EQ             

%token              TOK_LPAREN         
%token              TOK_RPAREN         

%type<num> line expression litteral arithmetic logical comparison
%type<id> statement assignement read print

%%

line:
  print         {;} |
  read          {;} |
  assignement   {;} |
  statement     {;} |
  expression    {;}
;

assignement:
  identifier TOK_ASSIGN expression {symbol_insert($1, $3);}
;

print:
  TOK_PRINT expression {printf("%d\n", $2);}
;

read:
  TOK_READ identifier {int value; scanf("%d", &value); symbol_insert($2, value);}
;


statement:
  if        {;} |
  while     {;}
;

if:
  TOK_IF expression TOK_THEN statement {;}
;

while:
  TOK_WHILE expression TOK_DO statement {;}
;

expression:
  litteral                          { $$ = $1; } |
  arithmetic                        { $$ = $1; } |
  logical                           { $$ = $1; } |
  comparison                        { $$ = $1; } |
;

arithmetic:
  expression TOK_PLUS   expression  { $$ = $1 + $3; } |
  expression TOK_MINUS  expression  { $$ = $1 - $3; } |
  expression TOK_MULT   expression  { $$ = $1 * $3; } |
  expression TOK_DIV    expression  { $$ = $1 / $3; } |
  expression TOK_MOD    expression  { $$ = $1 % $3; }
;

logical:
  expression TOK_AND  expression    { $$ = $1 && $3;} |
  expression TOK_OR   expression    { $$ = $1 || $3;} |
  TOK_NOT expression                { $$ = !$2; }
;

comparison:
  expression TOK_LT   expression    { $$ = $1 < $3; }   |
  expression TOK_GT   expression    { $$ = $1 > $3; }   |
  expression TOK_LTE  expression    { $$ = $1 <= $3; }  |
  expression TOK_GTE  expression    { $$ = $1 >= $3; }  |
  expression TOK_EQ   expression    { $$ = $1 == $3; }
;

litteral:
  identifier  { $$ = symbol_lookup($1);}  |
  number      { $$ = $1; }                |
  TOK_TRUE    { $$ = 1; }                 |
  TOK_FALSE   { $$ = 0; }
;

%%

void yyerror(const char *msg)
{
  fprintf(stderr, "[ERROR] Line %d: %s : ", yylineno, msg);
}

int compute(char *symbol)
{
  int idx = -1;
  if (isupper(symbol[0])) {
    idx = symbol[0] - 'A';
  } else if (islower(symbol[0])) {
    idx = symbol[0] - 'a' + 26;
  }
  return idx;
}

int symbol_lookup(char *symbol)
{
  int bucket = compute(symbol);
  if (bucket == -1) {
    fprintf(stderr, "Invalid symbol: %s\n", symbol);
    return -1;
  }

  return symbol_table[bucket];
}

int symbol_insert(char *symbol, int value)
{
  int bucket = compute(symbol);
  if (bucket == -1) {
    fprintf(stderr, "Invalid symbol: %s\n", symbol);
    return -1;
  }

  symbol_table[bucket] = value;
  return 0;
}

int main(int argc, char **argv)
{
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
    return EXIT_FAILURE;
  }

  // Check if the file ext is .ez
  char *ext = strrchr(argv[1], '.');
  if (ext == NULL || strcmp(ext, ".ez") != 0) {
    fprintf(stderr, "Invalid file extension: %s\n", ext);
    return EXIT_FAILURE;
  }

  // Open the file
  FILE *file = fopen(argv[1], "r");
  if (file == NULL) {
    fprintf(stderr, "Unable to open file: %s\n", argv[1]);
    return EXIT_FAILURE;
  }

  size_t i;
  for (i = 0; i < 52; i++) {
    symbol_table[i] = 0;
  }

  // Parse the file
  yyparse();

  // Close the file
  fclose(file);
}