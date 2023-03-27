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
void emit_code(GNode* node);

void emit_locals(int n);

void emit_label(int label);
void emit_instruction();

void emit_ret();
void emit_nop();

void emit_statement(GNode* node);
void emit_assignement(GNode* node);
void emit_print(GNode* node);
void emit_read(GNode* node);
void emit_if(GNode* node);
void emit_if_else(GNode* node);

void emit_expression(GNode* node);
void emit_binary_expression(GNode* node);
void emit_unary_expression(GNode* node);
void emit_identifier(GNode* node);
void emit_number(GNode* node);

void begin_code();
void end_code();

int maxstack = 0;

int instr = 0;
int label = 0;

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
%type               <node> if
%type               <node> statement
%type               <node> identifier
%type               <node> number
%type               <node> binary
%type               <node> unary


%start program

%%


program: code {
  printf("Program\n");
  begin_code();
  emit_code($1);
  end_code();
  g_node_destroy($1);
}

code:
  code statement {
    $$ = g_node_new("code");
    g_node_append($$, $1);
    g_node_append($$, $2);
  } |
  statement {
    $$ = g_node_new("code");
    g_node_append($$, $1);
  } |
  {
    $$ = g_node_new("");
  }
;

statement:
  assignement  {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  } |
  print        {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  } |
  read         {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  } |
  if            {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  }
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

if:
  TOK_IF expression TOK_THEN code TOK_ENDIF {
    $$ = g_node_new("if");
    g_node_append($$, $2);
    g_node_append($$, $4);
  } |
  TOK_IF expression TOK_THEN code TOK_ELSE code TOK_ENDIF {
    $$ = g_node_new("if");
    g_node_append($$, $2);
    g_node_append($$, $4);
    g_node_append($$, $6);
  }
;


expression:
  binary                            {
    $$ = g_node_new("binary");
    g_node_append($$, $1);
  } |
  unary                            {
    $$ = g_node_new("unary");
    g_node_append($$, $1);
  } |
  identifier                        {;} |
  number                            {;}
;

binary:
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
  } |
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
  }  |
  expression TOK_GTE  expression    {
    $$ = g_node_new("gte");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }  |
  expression TOK_EQ   expression    {
    $$ = g_node_new("eq");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }
;

unary:
  TOK_MINUS expression {
    $$ = g_node_new("neg");
    g_node_append($$, $2);
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

void emit_locals(int n)
{
  fprintf(yyout, "\t.locals init (");
  for (int i = 1; i <= n; i++) {
    fprintf(yyout, "int32");
    if (i < n) {
      fprintf(yyout, ", ");
    }
  }
  fprintf(yyout, ")\n");
}

void begin_code()
{
  fprintf(yyout, ".assembly extern mscorlib {}\n");
  fprintf(yyout, ".assembly program {}\n");
  fprintf(yyout, ".method static void Main()\n");
  fprintf(yyout, "{\n");
  fprintf(yyout, "\t.entrypoint\n");
  fprintf(yyout, "\t.maxstack %d\n", g_hash_table_size(table) + 1); // +1 for comparison return value
  emit_locals(g_hash_table_size(table));
}

void end_code()
{
  emit_instruction();
  fprintf(yyout, "\tret\n");
  fprintf(yyout, "}\n");
}

void emit_instruction()
{
  // Print the instr number in hex like IL_xxxx
  fprintf(yyout, "\tIL_%04x: ", instr++);
}

void emit_label(int label)
{
  fprintf(yyout, "LB_%04x:\n", label);
}

void emit_nop()
{
  emit_instruction();
  fprintf(yyout, "\tnop\n");
}

void emit_ret()
{
  emit_instruction();
  fprintf(yyout, "\tret\n");
}

void emit_code(GNode *node)
{
  if (node == NULL) {
    printf("Node is NULL\n");
    return;
  }

  printf("Emitting code for node %s\n", (char *)node->data);

  if (strcmp(node->data, "code") == 0) {
    emit_code(g_node_nth_child(node, 0));
    emit_code(g_node_nth_child(node, 1));

  } else if (strcmp(node->data, "statement") == 0) {
    emit_statement(g_node_nth_child(node, 0));

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_statement(GNode *node)
{
  printf("Emitting statement for node %s\n", (char *)node->data);
  if (strcmp(node->data, "assignement") == 0) {
    emit_assignement(node);

  } else if (strcmp(node->data, "print") == 0) {
    emit_print(node);

  } else if (strcmp(node->data, "read") == 0) {
    emit_read(node);

  } else if (strcmp(node->data, "if") == 0) {
    if (g_node_n_children(node) == 2) {
        emit_if(node);
    } else if (g_node_n_children(node) == 3) {
        emit_if_else(node);
    } else {
        fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
    }
  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_assignement(GNode *node)
{
  emit_expression(g_node_nth_child(node, 1));

  emit_instruction();
  fprintf(yyout, "\tstloc %ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
}

void emit_read(GNode *node)
{
  printf("Emitting read for node %s\n", (char *)node->data);
  printf("\tNode child %s\n", g_node_nth_child(node, 0)->data);

  emit_instruction();
  fprintf(yyout, "\tldstr \"%s\"\n", "> ");
  emit_instruction();
  fprintf(yyout, "\tcall void class [mscorlib]System.Console::Write(string)\n");

  emit_instruction();
  fprintf(yyout, "\tcall string class [mscorlib]System.Console::ReadLine()\n");
  emit_instruction();
  fprintf(yyout, "\tcall int32 int32::Parse(string)\n");
  emit_instruction();
  fprintf(yyout, "\tstloc %ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
}

void emit_print(GNode *node)
{
  printf("Emitting print for node %s\n", node->data);
  printf("\tNode child %s\n", g_node_nth_child(node, 0)->data);
  emit_expression(g_node_nth_child(node, 0));

  emit_instruction();
  fprintf(yyout, "\tcall void class [mscorlib]System.Console::WriteLine(int32)\n");
}

void emit_if(GNode *node)
{
  // The condition
  emit_expression(g_node_nth_child(node, 0));

  // Label
  int end_label = label++;

  // The jump
  emit_instruction();
  fprintf(yyout, "\tbrfalse LB_%04x\n", end_label);

  // The code
  emit_code(g_node_nth_child(node, 1));

  // The label
  emit_label(end_label);
}

void emit_if_else(GNode *node)
{
  // The condition
  emit_expression(g_node_nth_child(node, 0));

  // Label
  int end_label = label++;
  int else_label = label++;

  // The jump
  emit_instruction();
  fprintf(yyout, "\tbrfalse LB_%04x\n", else_label);

  // The code
  emit_code(g_node_nth_child(node, 1));

  // The jump
  emit_instruction();
  fprintf(yyout, "\tbr LB_%04x\n", end_label);

  // The Else Label
  emit_label(else_label);

  // The else
  emit_code(g_node_nth_child(node, 2));

  // The Label
  emit_label(end_label);
}

void emit_expression(GNode *node)
{
  printf("Emitting expression for node %s\n", (char*)node->data);

  if (strcmp(node->data, "binary") == 0) {
    emit_binary(node);

  } else if (strcmp(node->data, "unary") == 0) {
    emit_unary(node);

  } else if (strcmp(node->data, "number") == 0) {
    emit_number(node);

  } else if (strcmp(node->data, "identifier") == 0) {
    emit_identifier(node);

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_binary(GNode *node)
{
  printf("Emitting binary for node %s\n", (char*)node->data);
  // Emit a nop before the binary expression
  emit_nop();

  // The left
  emit_expression(g_node_nth_child(node, 0));

  // The right
  emit_expression(g_node_nth_child(node, 1));

  // The operator
  if (strcmp(node->data, "add") == 0) {
    emit_instruction();
    fprintf(yyout, "\tadd\n");

  } else if (strcmp(node->data, "sub") == 0) {
    emit_instruction();
    fprintf(yyout, "\tsub\n");

  } else if (strcmp(node->data, "mul") == 0) {
    emit_instruction();
    fprintf(yyout, "\tmul\n");

  } else if (strcmp(node->data, "div") == 0) {
    emit_instruction();
    fprintf(yyout, "\tdiv\n");

  } else if (strcmp(node->data, "lt") == 0) {
    emit_instruction();
    fprintf(yyout, "\tclt\n");

  } else if (strcmp(node->data, "gt") == 0) {
    emit_instruction();
    fprintf(yyout, "\tcgt\n");

  } else if (strcmp(node->data, "eq") == 0) {
    emit_instruction();
    fprintf(yyout, "\tceq\n");

  } else if (strcmp(node->data, "lte") == 0) {
    emit_instruction();
    fprintf(yyout, "\tclt\n");

  } else if (strcmp(node->data, "gte") == 0) {
    emit_instruction();
    fprintf(yyout, "\tcgt\n");

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_unary(GNode *node)
{

}

void emit_number(GNode *node)
{
  emit_instruction();
  fprintf(yyout, "\tldc.i4 0x%x\n", (long)g_node_nth_child(node, 0)->data);
}

void emit_identifier(GNode *node)
{
  printf("Emitting identifier for node %s\n", (char*)node->data);

  emit_instruction();
  fprintf(yyout, "\tldloc %ld\n", (long)g_node_nth_child(node, 0)->data - 1);
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
