%{
#include <stdio.h>
#include <stdlib.h>

#include <glib.h>

extern int yylineno;

int yylex();
void yyerror(const char *msg);

GHashTable* symbol_hash_table;

void produce_code(GNode* node);

void begin_code();
void end_code();

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
  printf(".assembly extern mscorlib {}\n");
  printf(".assembly program {}\n");
  printf(".module program.exe\n");
  printf(".class public program\n");
  printf("{\n");
  printf(".method public static void main()\n");
  printf("{\n");
  printf(".entrypoint\n");
  printf(".maxstack 100\n");
}

void end_code()
{
  printf("ret\n");  
  printf("}\n");
  printf("}\n");
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
    printf(" stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data);
  } else if (strcmp(node->data, "print") == 0) {
    produce_code(g_node_nth_child(node, 0));
    printf(" call void class [mscorlib]System.Console::WriteLine(int32)\n");
  } else if (node->data == "number") {
    printf(" ldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);
  } else if (node->data == "identifier") {
    printf(" ldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);
  } else if (node->data == "add") {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    printf(" add\n");
  } else if (node->data == "sub") {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    printf(" sub\n");
  } else if (node->data == "mul") {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    printf(" mul\n");
  } else if (node->data == "div") {
    produce_code(g_node_nth_child(node, 0));
    produce_code(g_node_nth_child(node, 1));
    printf(" div\n");
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

  // Parse the file
  yyparse();

  // Close the file
  fclose(file);
}

