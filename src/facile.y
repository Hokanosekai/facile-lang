%{
#include <stdio.h>
#include <stdlib.h>

#include <glib.h>

extern int yylineno;
extern FILE *yyin;
extern FILE *yyout;

int yylex();
void yyerror(const char *msg);

int count_nodes(GNode *node, char *data);

GHashTable* table;
void emit_code(GNode* node);

void emit_locals(int n);

void emit_label(int label);
void emit_instruction();

void emit_ret();
void emit_nop();

// Statements
void emit_statement(GNode* node);
void emit_assignement(GNode* node);
void emit_print(GNode* node);
void emit_read(GNode* node);
void emit_if(GNode* node);
void emit_while(GNode* node);
void emit_continue();
void emit_break();
void emit_exit();
void emit_for(GNode* node);

// Expressions
void emit_expression(GNode* node);
void emit_binary(GNode* node);
void emit_unary(GNode* node);

// Literals
void emit_identifier(GNode* node);
void emit_number(GNode* node);
void emit_string(GNode* node);

void begin_code();
void end_code();

int maxstack = 0;

int instr = 0;
int label = 0;

int exit_label = 0;

int global_scope = 0;
int current_scope = 0;
int *global_labels = NULL;

char *output_name;

%}

%union {
  gchar   *id;
  gulong  num;
  gchar   *str;
  GNode   *node;
}

%token              TOK_IF
%token              TOK_THEN
%token              TOK_ELSE
%token              TOK_ELIF
%token              TOK_ENDIF

%token              TOK_NOT
%token              TOK_AND
%token              TOK_OR

%token              TOK_PRINT
%token              TOK_READ

%token              TOK_WHILE
%token              TOK_DO
%token              TOK_ENDWHILE

%token              TOK_FOR
%token              TOK_TO
%token              TOK_STEP
%token              TOK_ENDFOR

%token              TOK_CONTINUE
%token              TOK_BREAK
%token              TOK_EXIT

%token              TOK_ASSIGN

%token<id>          IDENTIFIER
%token<num>         NUMBER
%token<str>         STRING

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
%token              TOK_EQEQ
%token              TOK_NEQ
%token              TOK_EQ

%token              TOK_PLUSPLUS
%token              TOK_MINUSMINUS

%token              TOK_LPAREN
%token              TOK_RPAREN

%type               <node> code
%type               <node> expression
%type               <node> assignement
%type               <node> print
%type               <node> read
%type               <node> if
%type               <node> elif
%type               <node> else
%type               <node> while
%type               <node> for
%type               <node> statement
%type               <node> identifier
%type               <node> number
%type               <node> string
%type               <node> binary
%type               <node> unary

%start program

%%


program: code {
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
  expression {
    $$ = g_node_new("statement_expression");
    g_node_append($$, $1);
  } |
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
  if           {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  } |
  while        {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  } |
  for          {
    $$ = g_node_new("statement");
    g_node_append($$, $1);
  } |
  TOK_CONTINUE {
    $$ = g_node_new("continue");
  } |
  TOK_BREAK    {
    $$ = g_node_new("break");
  } |
  TOK_EXIT     {
    $$ = g_node_new("exit");
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
  } |
  TOK_PRINT string expression {
    $$ = g_node_new("print");
    g_node_append($$, $2);
    g_node_append($$, $3);
  } |
  TOK_PRINT string {
    $$ = g_node_new("print");
    g_node_append($$, $2);
  }
;

read:
  TOK_READ identifier {
    $$ = g_node_new("read");
    g_node_append($$, $2);
  } |
  TOK_READ string identifier {
    $$ = g_node_new("read");
    g_node_append($$, $2);
    g_node_append($$, $3);
  }
;

if:
  TOK_IF expression TOK_THEN code elif else TOK_ENDIF {
    $$ = g_node_new("if");
    g_node_append($$, $2);
    g_node_append($$, $4);
    g_node_append($$, $5);
    g_node_append($$, $6);
  } |
  TOK_IF expression TOK_THEN code elif TOK_ENDIF {
    $$ = g_node_new("if");
    g_node_append($$, $2);
    g_node_append($$, $4);
    g_node_append($$, $5);
  } |
  TOK_IF expression TOK_THEN code else TOK_ENDIF {
    $$ = g_node_new("if");
    g_node_append($$, $2);
    g_node_append($$, $4);
    g_node_append($$, $5);
  } |
  TOK_IF expression TOK_THEN code TOK_ENDIF {
    $$ = g_node_new("if");
    g_node_append($$, $2);
    g_node_append($$, $4);
  }
;

elif:
  TOK_ELIF expression TOK_THEN code elif {
    $$ = g_node_new("elif");
    g_node_append($$, $2);
    g_node_append($$, $4);
    g_node_append($$, $5);
  } |
  TOK_ELIF expression TOK_THEN code {
    $$ = g_node_new("elif");
    g_node_append($$, $2);
    g_node_append($$, $4);
  }
;

else:
  TOK_ELSE code {
    $$ = g_node_new("else");
    g_node_append($$, $2);
  }
;

while:
  TOK_WHILE expression TOK_DO code TOK_ENDWHILE {
    $$ = g_node_new("while");
    g_node_append($$, $2);
    g_node_append($$, $4);
  }
;

for:
  TOK_FOR identifier TOK_EQ expression TOK_TO expression TOK_DO code TOK_ENDFOR {
    $$ = g_node_new("for");
    g_node_append($$, $2);
    g_node_append($$, $4);
    g_node_append($$, $6);
    g_node_append($$, $8);
  }
;

expression:
  unary                             {
    $$ = g_node_new("unary");
    g_node_append($$, $1);
  } |
  binary                            {
    $$ = g_node_new("binary");
    g_node_append($$, $1);
  } |
  identifier                        {;} |
  number                            {;} |
  TOK_LPAREN expression TOK_RPAREN  {
    $$ = $2;
  }
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
  expression TOK_EQEQ expression    {
    $$ = g_node_new("eq");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }  |
  expression TOK_NEQ  expression    {
    $$ = g_node_new("neq");
    g_node_append($$, $1);
    g_node_append($$, $3);
  } |
  expression TOK_AND  expression    {
    $$ = g_node_new("and");
    g_node_append($$, $1);
    g_node_append($$, $3);
  } |
  expression TOK_OR   expression    {
    $$ = g_node_new("or");
    g_node_append($$, $1);
    g_node_append($$, $3);
  }
;

unary:
  TOK_MINUS expression {
    $$ = g_node_new("neg");
    g_node_append($$, $2);
  } |
  identifier TOK_PLUS TOK_PLUS {
    $$ = g_node_new("inc");
    g_node_append($$, $1);
  } |
  identifier TOK_MINUS TOK_MINUS {
    $$ = g_node_new("dec");
    g_node_append($$, $1);
  } 
;

identifier:
  IDENTIFIER  {
    $$ = g_node_new("identifier");
    if (table == NULL) {
      table = g_hash_table_new_full(g_str_hash, g_str_equal, NULL, NULL);
    }

    gulong val = (gulong) g_hash_table_lookup(table, strdup($1));

    if (!val) {
      val = g_hash_table_size(table) + 1;
      g_hash_table_insert(table, strdup($1), (gpointer) val);
    }

    g_node_append_data($$, (gpointer) val);
  }
;

number:
  NUMBER      { 
    $$ = g_node_new("number");
    g_node_append_data($$, (gpointer)$1);
  }
;

string:
  STRING      {
    $$ = g_node_new("string");
    g_node_append($$, g_node_new($1));
  }

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
  exit_label = label++;

  fprintf(yyout, ".assembly extern mscorlib {}\n");
  fprintf(yyout, ".assembly %s {}\n", output_name);
  fprintf(yyout, ".method static void Main()\n");
  fprintf(yyout, "{\n");
  fprintf(yyout, "\t.entrypoint\n");
  fprintf(yyout, "\t.maxstack %d\n", g_hash_table_size(table) + 1); // +1 for comparison return value
  emit_locals(g_hash_table_size(table));
}

void end_code()
{
  emit_label(exit_label);
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

void emit_exit()
{
  emit_instruction();
  fprintf(yyout, "\tbr LB_%04x\n", exit_label);
}

void emit_code(GNode *node)
{
  if (node == NULL) {
    return;
  }

  if (strcmp(node->data, "code") == 0) {
    emit_code(g_node_nth_child(node, 0));
    emit_code(g_node_nth_child(node, 1));

  } else if (strcmp(node->data, "statement_expression") == 0) {
    emit_expression(g_node_nth_child(node, 0)); 

  } else if (strcmp(node->data, "statement") == 0) {
    emit_statement(g_node_nth_child(node, 0));

  } else if (strcmp(node->data, "continue") == 0) {
    emit_continue();

  } else if (strcmp(node->data, "break") == 0) {
    emit_break();

  } else if (strcmp(node->data, "exit") == 0) {
    emit_exit();

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_statement(GNode *node)
{
  if (strcmp(node->data, "assignement") == 0) {
    emit_assignement(node);

  } else if (strcmp(node->data, "print") == 0) {
    emit_print(node);

  } else if (strcmp(node->data, "read") == 0) {
    emit_read(node);

  } else if (strcmp(node->data, "if") == 0) {
    emit_if(node);

  } else if (strcmp(node->data, "while") == 0) {
    emit_while(node);

  } else if (strcmp(node->data, "for") == 0) {
    emit_for(node);

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_assignement(GNode *node)
{
  emit_nop();

  emit_expression(g_node_nth_child(node, 1));

  emit_instruction();
  fprintf(yyout, "\tstloc %ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
}

void emit_read(GNode *node)
{
  GNode *string = g_node_n_children(node) == 2
    ? g_node_nth_child(node, 0)
    : NULL;

  GNode *identifier = g_node_n_children(node) == 2
    ? g_node_nth_child(node, 1)
    : g_node_nth_child(node, 0);

  emit_nop();

  if (string != NULL) {
    emit_string(string);
    emit_instruction();
    fprintf(yyout, "\tcall void class [mscorlib]System.Console::Write(string)\n");
  } else {
    emit_instruction();
    fprintf(yyout, "\tldstr \"%s\"\n", "> ");
    emit_instruction();
    fprintf(yyout, "\tcall void class [mscorlib]System.Console::Write(string)\n");
  }

  emit_instruction();
  fprintf(yyout, "\tcall string class [mscorlib]System.Console::ReadLine()\n");
  emit_instruction();
  fprintf(yyout, "\tcall int32 int32::Parse(string)\n");
  emit_instruction();
  fprintf(yyout, "\tstloc %ld\n", (long)g_node_nth_child(identifier, 0)->data - 1);
}

void emit_print(GNode *node)
{
  GNode *expression = g_node_n_children(node) == 2
    ? g_node_nth_child(node, 1)
    : strcmp(g_node_nth_child(node, 0)->data, "string") == 0
      ? NULL
      : g_node_nth_child(node, 0);

  GNode *string = g_node_n_children(node) == 2
    ? g_node_nth_child(node, 0)
    : strcmp(g_node_nth_child(node, 0)->data, "string") == 0
      ? g_node_nth_child(node, 0)
      : NULL;

  if (string != NULL) {
    emit_string(string);
    emit_instruction();
    fprintf(yyout, "\tcall void class [mscorlib]System.Console::Write(string)\n");
  }

  if (expression != NULL) {
    emit_expression(expression);
    emit_instruction();
    fprintf(yyout, "\tcall void class [mscorlib]System.Console::WriteLine(int32)\n");
  }
}

void emit_if(GNode *node)
{
  GNode *condition = g_node_nth_child(node, 0);
  GNode *code = g_node_nth_child(node, 1);
  GNode *else_node = g_node_n_children(node) == 4
    ? g_node_nth_child(node, 3)
    : g_node_n_children(node) == 3 && strcmp(g_node_nth_child(node, 2)->data, "else") == 0
      ? g_node_nth_child(node, 2)
      : NULL;

  printf("There is %d children\n", g_node_n_children(node));
  
  GNode *elif_node = g_node_n_children(node) == 4
    ? g_node_nth_child(node, 2)
    : g_node_n_children(node) == 3 && strcmp(g_node_nth_child(node, 2)->data, "elif") == 0
      ? g_node_nth_child(node, 2)
      : NULL;

  if (elif_node == NULL) {
    printf("There is no elif\n");
  } else {
    printf("There is an elif\n");
  }

  if (else_node == NULL) {
    printf("There is no else\n");
  } else {
    printf("There is an else\n");
  }

  // The condition
  emit_expression(condition);

  // Label
  int end_label = label++;
  int else_label;
  int *elif_labels = NULL;
  int n = 0;

  // If there is an else increase the label
  if (else_node != NULL) {
    else_label = label++;
  }

  // If there is an elif we count them and allocate the labels
  if (elif_node != NULL) {
    printf("Elif node: %s\n", (char *)elif_node->data);
    n = count_nodes(elif_node, "elif");
    printf("There are %d elifs\n", n);
    elif_labels = malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
      elif_labels[i] = label++;
    }
  }

  int next_label = else_node != NULL
    ? elif_node != NULL
      ? elif_labels[0]
      : else_label
    : end_label;

  emit_instruction();
  fprintf(yyout, "\tbrfalse LB_%04x\n", next_label);

  // The code
  emit_code(code);

  // Branch to the end of the if
  emit_instruction();
  fprintf(yyout, "\tbr LB_%04x\n", end_label);

  // The elif blocks
  for (int i = 0; i < n; i++) {
    emit_label(elif_labels[i]);
    emit_expression(g_node_nth_child(elif_node, 0));

    next_label = i + 1 < n
      ? elif_labels[i + 1]
      : else_node != NULL
        ? else_label
        : end_label;

    // Branch the next elif block if the condition is false
    emit_instruction();
    fprintf(yyout, "\tbrfalse LB_%04x\n", next_label);
    // The code
    emit_code(g_node_nth_child(elif_node, 1));

    // Branch to the end of the if
    emit_instruction();
    fprintf(yyout, "\tbr LB_%04x\n", end_label);

    // If the elif_node has a next elif_node
    if (g_node_n_children(elif_node) == 3) {
      elif_node = g_node_nth_child(elif_node, 2);
    }
    /*if (g_node_nth_child(elif_node, 2) != NULL && strcmp(g_node_nth_child(elif_node, 2)->data, "elif") == 0) {
      elif_node = g_node_nth_child(elif_node, 2);
    }*/
  }

  // The else block
  if (else_node != NULL) {
    emit_label(else_label);
    emit_code(g_node_nth_child(else_node, 0));
  }

  // The Label
  emit_label(end_label);

  // Free the labels
  if (elif_labels != NULL) {
    free(elif_labels);
  }
}

void emit_while(GNode *node)
{
  // Scope
  int scope = global_scope + 2;

  // If the global_labels array is null, allocate it
  if (global_labels == NULL) {
    global_labels = malloc(2 * sizeof(int));
  }

  // Check if the global_labels array is big enough
  if (scope >= global_scope) {
    global_scope += 2;
    realloc(global_labels, global_scope * sizeof(int));
  }

  // Save the labels in the array
  global_labels[scope]     = label++;
  global_labels[scope + 1] = label++;

  int while_start_label = global_labels[scope];
  int while_end_label   = global_labels[scope + 1];

  // The Label
  emit_label(while_start_label);

  // The condition
  emit_expression(g_node_nth_child(node, 0));

  // The jump
  emit_instruction();
  fprintf(yyout, "\tbrfalse LB_%04x\n", while_end_label);

  // The code
  emit_code(g_node_nth_child(node, 1));

  // Reset the current while
  current_scope = scope;

  // The jump
  emit_instruction();
  fprintf(yyout, "\tbr LB_%04x\n", while_start_label);

  // The Label
  emit_label(while_end_label);

  // Reset the current while
  global_scope -= 2;
  realloc(global_labels, global_scope * sizeof(int));
}

void emit_for(GNode *node)
{
  
}

void emit_continue()
{
  emit_instruction();
  fprintf(yyout, "\tbr LB_%04x\n", global_labels[global_scope]);
}

void emit_break()
{
  emit_instruction();
  fprintf(yyout, "\tbr LB_%04x\n", global_labels[global_scope + 1]);
}

void emit_expression(GNode *node)
{
  if (strcmp(node->data, "binary") == 0) {
    emit_binary(g_node_nth_child(node, 0));

  } else if (strcmp(node->data, "unary") == 0) {
    emit_unary(g_node_nth_child(node, 0));

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

  } else if (strcmp(node->data, "mod") == 0) {
    emit_instruction();
    fprintf(yyout, "\trem\n");

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

  } else if (strcmp(node->data, "and") == 0) {
    emit_instruction();
    fprintf(yyout, "\tand\n");

  } else if (strcmp(node->data, "or") == 0) {
    emit_instruction();
    fprintf(yyout, "\tor\n");

  // neq => !=
  } else if (strcmp(node->data, "neq") == 0) {
    emit_instruction();
    fprintf(yyout, "\tceq\n");
    emit_instruction();
    fprintf(yyout, "\tldc.i4.0\n");
    emit_instruction();
    fprintf(yyout, "\tceq\n");
  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_unary(GNode *node)
{
  GNode *child = g_node_nth_child(node, 0);
  printf("Data: %s\n", (char *)child->data);

  // Emit a nop before the unary expression
  emit_nop();
  emit_expression(child);

  if (strcmp(node->data, "neg") == 0) {
    emit_instruction();
    fprintf(yyout, "\tneg\n");

  } else if (strcmp(node->data, "inc") == 0) {
    emit_instruction();
    fprintf(yyout, "\tldc.i4.1\n");
    emit_instruction();
    fprintf(yyout, "\tadd\n");

    // Store the result
    emit_instruction();
    fprintf(yyout, "\tstloc %ld\n", (long)g_node_nth_child(child, 0)->data - 1);

  } else if (strcmp(node->data, "dec") == 0) {
    emit_instruction();
    fprintf(yyout, "\tldc.i4.1\n");
    emit_instruction();
    fprintf(yyout, "\tsub\n");

    // Store the result
    emit_instruction();
    fprintf(yyout, "\tstloc %ld\n", (long)g_node_nth_child(child, 0)->data - 1);

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}

void emit_number(GNode *node)
{
  emit_instruction();
  fprintf(yyout, "\tldc.i4 %ld\n", (long)g_node_nth_child(node, 0)->data);
}

void emit_identifier(GNode *node)
{
  emit_instruction();
  fprintf(yyout, "\tldloc %ld\n", (long)g_node_nth_child(node, 0)->data - 1);
}

void emit_string(GNode *node)
{
  emit_instruction();
  fprintf(yyout, "\tldstr %s\n", (char *)g_node_nth_child(node, 0)->data);
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

  // Set the output_name from the filename
  char *filename = strrchr(argv[1], '/');
  if (filename == NULL) {
    filename = argv[1];
  } else {
    filename++;
  }

  // Remove the .ez
  filename[strlen(filename) - 3] = '\0';
  output_name = malloc(strlen(filename) + 1);
  strcpy(output_name, filename);

  // Create a output directory
  char *c1 = malloc(strlen(filename) + 20);
  strcpy(c1, "mkdir -p output");

  system(c1);

  // Create the IL filename from the filename and the output directory 
  char *il_filename = malloc(strlen(filename) + 20);
  strcpy(il_filename, "output/");
  strcat(il_filename, filename);
  strcat(il_filename, ".il");

  // Set the file as the input
  yyin = file;
  // Set the output file to the output directory with the same name and .il
  yyout = fopen(il_filename, "w");

  // Parse the file
  yyparse();

  // Close the file
  fclose(file);
}

int count_nodes(GNode *node, char *data)
{
  int count = 0;

  if (strcmp(node->data, data) == 0) {
    count++;
    if (g_node_n_children(node) == 3) {
      count += count_nodes(g_node_nth_child(node, 2), data);
    }
  }

  return count;
} 