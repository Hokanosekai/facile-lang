%{
#include <stdio.h>
#include <stdlib.h>

#include <glib.h>

extern int yylineno;
extern FILE *yyin;
extern FILE *yyout;

int yylex();
void yyerror(const char *msg);

GHashTable* symbol_hash_table;

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
%type               <node> litteral

%%

program: code {
  begin_code();
  produce_code($1);
  end_code();
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
  assignement |
  print       |
  read
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
  litteral                          {;} |
  arithmetic                        {;} |
  comparison                        {;}
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
    printf(" clt\n");
  }   |
  expression TOK_GT   expression    {
    printf(" cgt\n");
  }   |
  expression TOK_LTE  expression    {
    printf(" clt\n");
    printf(" ldc.i4.0\n");
    printf(" ceq\n");
  }  |
  expression TOK_GTE  expression    {
    printf(" cgt\n");
    printf(" ldc.i4.0\n");
    printf(" ceq\n");
  }  |
  expression TOK_EQ   expression    {
    printf(" ceq\n");
  }
;

litteral:
  identifier  {;}                         |
  number      {;}
;

identifier:
  IDENTIFIER  {
    $$ = g_node_new("identifier");
    if (!symbol_hash_table) {
      printf("Creating symbol hash table\n");
      symbol_hash_table = g_hash_table_new(g_str_hash, g_str_equal);
    }
    gulong value = (gulong) g_hash_table_lookup(symbol_hash_table, $1);
    if (!value) {
      value = g_hash_table_size(symbol_hash_table) + 1;
      g_hash_table_insert(symbol_hash_table, strdup($1), (gpointer) value);
    }
    g_node_append_data($$, (gpointer)value);
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
  fprintf(yyout, ".module program.exe\n");
  fprintf(yyout, ".class public program\n");
  fprintf(yyout, "{\n");
  fprintf(yyout, "\t.method public static void main()\n");
  fprintf(yyout, "\t{\n");
  fprintf(yyout, "\t\t.entrypoint\n");
  fprintf(yyout, "\t\t.maxstack %d\n", maxstack);
  fprintf(yyout, "\t\t.locals init (\n");
  fprintf(yyout, "\t\t)\n");

}

void poduce_locals_variables()
{
  GHashTableIter iter;
  gpointer key, value;
  g_hash_table_iter_init(&iter, symbol_hash_table);
  while (g_hash_table_iter_next(&iter, &key, &value)) {
    // Check if the node is a assignement or a read

  }
}

void end_code()
{
  fprintf(yyout, "\tret\n");  
  fprintf(yyout, "\t}\n");
  fprintf(yyout, "}\n");
}

void produce_code(GNode *node)
{
  if (node == NULL) {
    printf("Node is NULL\n");
    return;
  }

  /**printf("Node name: %s, data: %p, children: %d, parent: %p, next: %p, prev: %p\n",
         (char *) node->data, node->data, g_node_n_children(node), node->parent, node->next, node->prev);
*/
  if (strcmp(node->data, "code") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));

  } else if (strcmp(node->data, "assignement") == 0) {
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\t\tstloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data);
    //TODO : jai besoin de .locals

    maxstack += 1;

  } else if (strcmp(node->data, "print") == 0) {
    produce_code(g_node_nth_child(node, 0));
    fprintf(yyout, "\t\tcall void class [mscorlib]System.Console::WriteLine(int32)\n");

  } else if (strcmp(node->data, "number") == 0) {
    fprintf(yyout, "\t\tldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);

  } else if (strcmp(node->data, "identifier") == 0) {
    fprintf(yyout, "\t\tldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);

  } else if (strcmp(node->data, "add") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\t\tadd\n");

  } else if (strcmp(node->data, "sub") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\t\tsub\n");

  } else if (strcmp(node->data, "mul") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\t\tmul\n");

  } else if (strcmp(node->data, "div") == 0) {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    fprintf(yyout, "\t\tdiv\n");

  } else if (strcmp(node->data, "read") == 0) {
    fprintf(yyout, "\t\tcall int32 class [mscorlib]System.Console::ReadLine()\n");
    fprintf(yyout, "\t\tcall int32 int32::Parse(string)\n");
    fprintf(yyout, "\t\tstloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data);
    // TODO : jai besoin de .locals

    maxstack += 1;
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

  locals = g_array_new(FALSE, FALSE, sizeof(gchar *));

  // Set the file as the input
  yyin = file;
  yyout = fopen("output.il", "w");

  // Parse the file
  yyparse();

  // Close the file
  fclose(file);
}

