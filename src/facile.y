%{
#include <stdio.h>
#include <stdlib.h>

#include <glib.h>

extern int yylineno;
extern FILE *yyin;
extern FILE *yyout;

int yylex();
void yyerror(const char *msg);

GHashTable* table;
void produce_code(GNode* node);

void begin_code();
void end_code();

int maxstack = 0;

char *locals = NULL;

%}

%union {
  gchar   *id;
  gulong  num;
  GNode   *node;
}

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

%type               <node> code
%type               <node> expression
%type               <node> assignement
%type               <node> print
%type               <node> read
%type               <node> statement
%type               <node> identifier
%type               <node> number
%type               <node> arithmetic
%type               <node> comparison


%start program

%%


program: code {
  printf("Program\n");
  begin_code();
  produce_code($1);
  end_code();
  g_node_destroy($1);
}

code:
  code statement {
    $$ = g_node_new("code");
    g_node_append($$, $1);
    g_node_append($$, $2);
  } |
  {
    $$ = g_node_new("");
  }

statement:
  assignement  {;} |
  print        {;} |
  read         {;}
;


assignement:
  identifier TOK_ASSIGN expression {
    $$ = g_node_new("assignement");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }
;

print:
  TOK_PRINT expression {
    $$ = g_node_new("print");
    g_node_append($$, $2);
  }
;

read:
  TOK_READ identifier {
    $$ = g_node_new("read");
    g_node_append($$, $2);
  }
;

expression:
  arithmetic                        {;} |
  comparison                        {;} |
  identifier                        {;} |
  number                            {;}
;

arithmetic:
  expression TOK_PLUS   expression  {
    $$ = g_node_new("add");
    g_node_append($$, $1);
    g_node_append($$, $3);
  } |
  expression TOK_MINUS  expression  {
    $$ = g_node_new("sub");
    g_node_append($$, $1);
    g_node_append($$, $3);
  } |
  expression TOK_MULT   expression  {
    $$ = g_node_new("mul");
    g_node_append($$, $1);
    g_node_append($$, $3);
  } |
  expression TOK_DIV    expression  {
    $$ = g_node_new("div");
    g_node_append($$, $1);
    g_node_append($$, $3);
  } |
  expression TOK_MOD    expression  {
    $$ = g_node_new("mod");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }
;

comparison:
  expression TOK_LT   expression    {
    $$ = g_node_new("lt");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }   |
  expression TOK_GT   expression    {
    $$ = g_node_new("gt");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }   |
  expression TOK_LTE  expression    {
    $$ = g_node_new("lte");
    g_node_append($$, $1);
    g_node_append($$, $3);
    printf(" clt\n");
    printf(" ldc.i4.0\n");
    printf(" ceq\n");
  }  |
  expression TOK_GTE  expression    {
    $$ = g_node_new("gte");
    g_node_append($$, $1);
    g_node_append($$, $3);
    printf(" cgt\n");
    printf(" ldc.i4.0\n");
    printf(" ceq\n");
  }  |
  expression TOK_EQ   expression    {
    $$ = g_node_new("eq");
    g_node_append($$, $1);
    g_node_append($$, $3);
    printf(" ceq\n");
  }
;

identifier:
  IDENTIFIER  {
    $$ = g_node_new("identifier");
    if (table == NULL) {
      printf("Creating symbol hash table\n");
      table = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, NULL);
    }
    printf("Checking symbol %s in hash table\n", $1);

    gulong val = (gulong) g_hash_table_lookup(table, strdup($1));
    printf("Symbol %s has value %d\n", $1, val);

    if (!val) {
      val = g_hash_table_size(table) + 1;
      g_hash_table_insert(table, strdup($1), (gpointer) val);
      printf("Adding symbol %s to hash table at %d\n", $1, val);
    } else {
      printf("Symbol %s already in hash table at %d\n", $1, val);
    }

    g_node_append_data($$, (gpointer) val);
    printf("\n");
  }
;

number:
  NUMBER      { 
    $$ = g_node_new("number");
    g_node_append_data($$, (gpointer)$1);
  }
;

%%

void yyerror(const char *msg)
{
  fprintf(stderr, "[ERROR] Line %d: %s : ", yylineno, msg);
}

void begin_code()
{
  fprintf(yyout, ".assembly extern mscorlib {}\n");
  fprintf(yyout, ".assembly program {}\n");
  fprintf(yyout, ".method static void Main()\n");
  fprintf(yyout, "{\n");
  fprintf(yyout, "\t.entrypoint\n");
  fprintf(yyout, "\t.maxstack %d\n", 10);
  fprintf(yyout, "\t.locals init (\n");
  fprintf(yyout, "\t\tint32, int32, int32\n");
  fprintf(yyout, "\t)\n");
}

void end_code()
{
  fprintf(yyout, "\tret\n");  
  fprintf(yyout, "}\n");
}

void produce_code(GNode *node)
{
  if (node == NULL) {
    printf("Node is NULL\n");
    return;
  }

  printf("Producing code for node %s\n", (char*)node->data);

  if (strcmp(node->data, "code") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));

  } else if (strcmp(node->data, "assignement") == 0) {
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tstloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    //TODO : jai besoin de .locals
  } else if (strcmp(node->data, "print") == 0) {
    produce_code(g_node_nth_child(node, 0));
    fprintf(yyout, "\tcall void class [mscorlib]System.Console::WriteLine(int32)\n");

  } else if (strcmp(node->data, "number") == 0) {
    fprintf(yyout, "\tldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);

  } else if (strcmp(node->data, "identifier") == 0) {
    fprintf(yyout, "\tldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);

  } else if (strcmp(node->data, "add") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tadd\n");

  } else if (strcmp(node->data, "sub") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tsub\n");

  } else if (strcmp(node->data, "mul") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tmul\n");

  } else if (strcmp(node->data, "div") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tdiv\n");

  } else if (strcmp(node->data, "read") == 0) {
    fprintf(yyout, "\tcall string class [mscorlib]System.Console::ReadLine()\n");
    fprintf(yyout, "\tcall int32 int32::Parse(string)\n");
    fprintf(yyout, "\tstloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    // TODO : jai besoin de .locals

  } else if (strcmp(node->data, "lt") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tclt\n");

  } else if (strcmp(node->data, "gt") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tcgt\n");

  } else if (strcmp(node->data, "eq") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tceq\n");

  } else if (strcmp(node->data, "lte") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tclt\n");
    fprintf(yyout, "\txor\tbool\ttrue\t\t// bool::op_Inequality(bool, bool)\n");
  
  } else if (strcmp(node->data, "gte") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\tcgt\n");
    fprintf(yyout, "\txor\tbool\ttrue\t\t// bool::op_Inequality(bool, bool)\n");
  
  }
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

  // Set the file as the input
  yyin = file;
  yyout = fopen("output.il", "w");

  // Parse the file
  yyparse();

  // Close the file
  fclose(file);
}

int finsert (FILE* file, const char *buffer, int line) {
  char *pos;
  char *file_buffer;
  int offset;

  if (file == NULL || buffer == NULL) {
    return -1;
  }

  // Allocate memory for the file buffer as the size of the file
  fseek(file, 0, SEEK_END);
  file_buffer = malloc(ftell(file));
  if (file_buffer == NULL) {
    return -1;
  }

  pos = file_buffer;
  for (int i = 1; i < line; i++) {
    pos = strchr(pos, '\n');
    if (pos == NULL) {
      return -1;
    }

    pos++;
  }

  offset = strlen(buffer) + strlen(file_buffer) + 1;

  // Move the file buffer to the end of the buffer
  memmove(pos + strlen(buffer), pos, strlen(pos) + 1);
  strncpy(pos, buffer, strlen(buffer));

  // Move the file pointer to the beginning of the file
  fseek(file, 0, SEEK_SET);

  // Write the file buffer to the file
  fwrite(file_buffer, offset, 1, file);

  return 0;
}
