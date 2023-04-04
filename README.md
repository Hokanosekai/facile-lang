<div align="center">

![Logo de mon projet](https://i.imgur.com/20BnGq1.png)

### Auteurs
*Bash62*
*Hokanosekai*

Projet de compilation : FLEX/BISON
=========


![Licence](https://img.shields.io/badge/licence-MIT-green.svg)
![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)
[![Open in Visual Studio Code](https://img.shields.io/badge/Open%20in-VS%20Code-blue?logo=visual-studio-code)](https://vscode.dev/github.com/Hokanosekai/facile-lang/tree/feature/readme)

</div>

- [Introduction](#introduction)
- [Spécificité du language](#fonctionnement)
- [Fonctionnement du compilateur](#fonctionnement-du-compilateur)
  - [Analyseur lexical](#analyseur-lexical)
  - [Analyseur syntaxique](#analyseur-syntaxique)
  - [Analyseur sémantique](#analyseur-sémantique)
  - [Générateur de code](#générateur-de-code)
  - [Approfondissement](#approfondissement)
    - [Transpilation	Arbre -> CIL](#transpilation-arbre---cil)
    - [Gestion des erreurs](#gestion-des-erreurs)
- [Installation](#installation)
  - [Prérequis](#prérequis)
  - [Installation](#installation-1)
  - [Utilisation](#utilisation)
- [Exemple de code](#exemple-de-code)
  - [Commentaires](#commentaires)
  - [I/O](#io)
    - [Read](#read)
    - [Print](#print)
  - [Variables](#variables)
  - [Conditions](#conditions)
    - [If](#if)
    - [Else](#else)
    - [Elif](#elif)
  - [Opérations](#opérations)
  - [Boucles](#boucles)
    - [While](#while)
    - [For](#for)
  - [PGCD](#pgcd)
  - [Fibonacci](#fibonacci)
  - [Nombre premier](#nombre-premier)
- [Exercicse](#exercices)
  - [Exercice 4 (Gestion des tests simples)](#exercice-4-gestion-des-tests-simples)
  - [Exercice 5 (Gestion des tests complexes)](#exercice-5-gestion-des-tests-complexes)
  - [Exercice 6 (Gestion des tests imbriqués)](#exercice-6-gestion-des-tests-imbriqués)
  - [Exercice 7 (Gestion des boucles simples)](#exercice-7-gestion-des-boucles-simples)
  - [Exercice 8 (Gestion des boucles complexes)](#exercice-8-gestion-des-boucles-complexes)
  - [Exercice 9 (Gestion des boucles imbriquées)](#exercice-9-gestion-des-boucles-imbriquées)
  - [Exercice 10 (Le pgcd)](#exercice-10-le-pgcd)
  - [Exercice Bonus (Fibonacci, nombre premier)](#exercice-bonus-fibonacci-nombre-premier)
- [Resources](#resources)
- [License](#license)

# Introduction

Ce projet à été réalisé dans le cadre du cours de compilation. Il a pour but de nous faire coder un compilateur pour un langage de programmation haut niveau basic, le `facile` (`ez`). Ce langage sera ensuite compilé en langage intermédiaire `CIL` (Common Intermediate Language) grâce à notre compilateur, puis en langage machine grâce à `Mono`.

# Spécificité du language

Le language `facile` est un langage de programmation basique, il permet de manipuler des nombres entiers, des booléens, leurs opérations habituelles et les structures algorithmiques classiques que sont les tests et les répétitions. Il est possible de déclarer des variables, de les initialiser, de les lire et d'écrire leur contenu.

Le principe est de traduire le code source en language `CIL` qui est un langage assembleur intermédiaire. Notre programme compilé sera ensuite éxécutable sur n'importe quel système d'exploitation implémentant les spécifications `CIL`.

# Fonctionnement du compilateur

Le compilateur est composé de 4 parties :
  - L'analyseur lexical
  - L'analyseur syntaxique
  - L'analyseur sémantique
  - Le générateur de code

## Analyseur lexical

L'analyseur lexical est un programme qui prend en entrée un fichier source et qui en extrait les différents tokens. Nous avons utilisé `Flex` pour réaliser cet analyseur lexical. Il est écrit dans le fichier `facile.l`.

Dans ce fichier nous avons défini les différents tokens du langage `facile` ainsi que les expressions régulières qui les définissent.

Nous avons dans notre langage les tokens suivants:
  - `TOK_IF` : `if`
  - `TOK_ELSE` : `else`
  - `TOK_ELIF` : `elif`
  - `TOK_ENDIF` : `endif`
  - `TOK_WHILE` : `while`
  - `TOK_DO` : `do`
  - `TOK_ENDWHILE` : `endwhile`
  - `TOK_FOR` : `for`
  - `TOK_READ` : `read`
  - `TOK_PRINT` : `print`
  - `TOK_BREAK` : `break`
  - `TOK_CONTINUE` : `continue`
  - `TOK_THEN` : `then`
  - `TOK_TO` : `to`
  - `TOK_STEP` : `step`
  - `TOK_ENDFOR` : `endfor`
  - `TOK_NOT` : `not`
  - `TOK_AND` : `and`
  - `TOK_OR` : `or`
  - `TOK_TRUE` : `true`
  - `TOK_FALSE` : `false`

Ensuite nous avons les tokens basés sur des expressions régulières :
  - `IDENTIFIER` : `[a-zA-Z][a-zA-Z0-9_]*`
  - `NUMBER` : `[0-9]+`
  - `STRING` : `\".*\"`
  - `COMMENT` : `"//".*` (commentaire sur une ligne)
  - `[ \t\n]` : `[\t\n ]+` (espace, tabulation, retour à la ligne)
  - `TOK_PLUS` : `+`
  - `TOK_MINUS` : `-`
  - `TOK_MULT` : `*`
  - `TOK_DIV` : `/`
  - `TOK_MOD` : `%`
  - `TOK_LT` : `<`
  - `TOK_LTE` : `<=`
  - `TOK_GT` : `>`
  - `TOK_GTE` : `>=`
  - `TOK_EQEQ` : `==`
  - `TOK_NEQ` : `!=`
  - `TOK_ASSIGN` : `:=`
  - `TOK_LPAREN` : `\(`
  - `TOK_RPAREN` : `\)`

## Analyseur syntaxique

L'analyseur syntaxique est un programme qui prend en entrée les tokens générés par l'analyseur lexical et qui vérifie que la syntaxe du code source est correcte. Nous avons utilisé `Bison` pour réaliser cet analyseur syntaxique. Il est écrit dans le fichier `facile.y`.

Dans ce fichier nous avons défini les règles de syntaxe du langage `facile` ainsi que les actions à effectuer lors de la détection d'un token. Nous avons utilisé la librairie `Glib` pour créer notre arbre syntaxique. Chaque noeud de l'arbre correspond à une règle de syntaxe.

Par exemple nous avons défini la règle suivante :

```yacc
program: code {
  begin_code();
  emit_code($1);
  end_code();
  g_node_destroy($1);
}
```

Cette règle defini notre point d'entrée dans notre arbre syntaxique.

Nous avons ensuite défini les règles de syntaxe pour les différentes structures de notre langage. Par exemple pour la structure `if` nous avons défini la règle suivante :

```yacc
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
```

Cette règle définit la structure `if` et ses différentes possibilités. On peut voir que nous avons défini 4 règles différentes pour la structure `if`. Chaque règle est définie par une expression régulière. Par exemple la première règle est définie par l'expression régulière suivante :

```yacc
TOK_IF expression TOK_THEN code elif else TOK_ENDIF
```

Cette expression régulière définit que la structure `if` doit commencer par le token `TOK_IF` suivi d'une expression, d'un token `TOK_THEN` suivi d'un code, d'un token `elif` suivi d'un token `else` et d'un token `TOK_ENDIF`.

Cela equivaut au code suivant en langage `facile` :

```c
if a == 1 then 
  print "a == 1"
elif a == 2 then
  print "a == 2"
else
  print "a != 1 and a != 2"
endif
```

Une des particularité de cette règle est que nous avons défini une sous règle nommée `elif` qui est définie par l'expression régulière suivante :

```yacc
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
```

La première règle de cette permet à notre analyseur syntaxique de détecter par récursivité l'ensemble des `elif` présents dans notre structure `if`. Par exemple le code suivant est valide :

```c
if a == 1 then 
  print "a == 1"
elif a == 2 then
  print "a == 2"
elif a == 3 then
  print "a == 3"
elif a == 4 then
  print "a == 4"
else
  print "a != 1 and a != 2 and a != 3 and a != 4"
endif
```

Cela permet de définir un nombre arbitraire de `elif` dans notre structure `if`.

L'ensemble des autres règles de syntaxe sont définies de la même manière.

## Analyseur sémantique

L'analyseur sémantique est directement implémenté par Yacc.


## Génération de code

La génération de code est implémentée dans le fichier `facile.y` dans la partie C de la grammaire Yacc. Comme vu précédemment, chaque règle de syntaxe est associée à une action. 

Nous avons découpé notre génération de code en plusieurs fonctions. Chaque fonction correspond à une règle de syntaxe. Par exemple dans la règle de syntaxe du program nous avons appelé la fonction `begin_code` qui permet de générer le code de début de programme. 

```c
void begin_code()
{
  fprintf(yyout, ".assembly extern mscorlib {}\n");
  fprintf(yyout, ".assembly %s {}\n", output_name);
  fprintf(yyout, ".method static void Main()\n");
  fprintf(yyout, "{\n");
  fprintf(yyout, "\t.entrypoint\n");
  fprintf(yyout, "\t.maxstack %d\n", g_hash_table_size(table) + 1); // +1 for comparison return value
  emit_locals(g_hash_table_size(table));
}
```

Le code généré par cette fonction est le suivant :

```csharp
.assembly extern mscorlib {}
.assembly facile {}
.method static void Main()
{
  .entrypoint
  .maxstack 2
  .locals init (
    int32,
    int32
  )
```

Ensuite nous faisons appel à la fonction `emit_code` qui permet de générer le code du programme. Cette fonction prend en paramètre le noeud racine de notre arbre syntaxique. 
Elle génère le code en parcourant l'arbre syntaxique en profondeur. Grâce à la librairie `Glib` nous pouvons facilement parcourir l'arbre syntaxique. 

```c
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

  } else {
    fprintf(stderr, "Unknown node: %s\n", (char *)node->data);
  }
}
```

De cette manière nous pouvons facilement générer le code en fonction de la règle de syntaxe rencontrée.

## Approfondissement

### Transpilation	Arbre -> CIL

La transpilation est le processus de traduction d'un langage source vers un langage cible. Dans notre cas nous traduisons un langage source `facile` vers un langage cible `CIL`.

Il nous a fallu dans un premier temps nous renseigner sur le langage `CIL` et son fonctionnement. Nous avons notamment recherché toutes les instructions spécifique au langage `CIL` et comment les utiliser.

Cela permet comme vu précédemment de définir des fonctions `emit` qui permettent de générer le code `CIL` en fonction de la règle de syntaxe rencontrée.

### Gestion des erreurs

La gestion des erreurs est une partie importante d'un compilateur cependant nous n'avons pas eu à nous en occuper dans le cadre de ce projet. En effet, Yacc permet de gérer les erreurs de syntaxe.

# Installation

## Prérequis

- [Flex](https://github.com/westes/flex)
- [Bison](https://www.gnu.org/software/bison/)
- [GCC](https://gcc.gnu.org/)
- [Glib](https://docs.gtk.org/glib/)
- [Mono](https://www.mono-project.com/docs/getting-started/install/linux/)
- [ILASM](https://learn.microsoft.com/en-us/dotnet/framework/tools/ilasm-exe-il-assembler)

```bash
sudo apt-get install flex bison gcc libglib2.0-dev mono-mcs mono-utils mono-devel -y
```

## Installation

```bash
git clone
cd facile-lang
./build.sh
```

## Utilisation

```bash
./facile <input_file>
```

Cela va générer un fichier `.il` dans le dossier `output`.

Il faudra ensuite utiliser le compilateur `ilasm` pour générer un fichier `.exe` qui pourra être exécuté.

```bash
ilasm output/<input_file>.il
```

### Linux / Mac

```bash
mono output/<input_file>.exe
```

### Windows

```bash
output/<input_file>.exe
```

# Exemple de code

## Commentaires

Les commentaires sont définis par les symboles `//` et sont ignorés par le compilateur.

```c
// comment.ez
// Ceci est un commentaire
```

## I/O

### Read

La fonction `read` permet de lire une valeur depuis l'entrée standard.

```c
// read.ez
read a
```

Par défaut, la fonction `read` affiche le symbole `>` sur la sortie standard. Il est possible de changer ce symbole en passant une chaîne de caractères en paramètre.

```c
// read_symbol.ez
read ">" a
```

### Print

La fonction `print` permet d'afficher une valeur sur la sortie standard. Elle permet d'afficher des chaînes de caractères et des variables.

```c
// print_var.ez
a := 1
print a
```

```c
// print_string.ez
print "Hello World"
```

Elle permet également d'afficher des valeurs calculées.

```c
// print_calc.ez
print 1 + 1
```

De plus, elle permet d'afficher des chaînes de caractères et des valeurs calculées.

```c
// print_string_calc.ez
print "Hello " 1 + 1
```

## Variables

Les variables peuvent être déclarées de deux manières différentes.

La première manière est de déclarer une variable avec un `TOK_ASSIGN` (symbole `:=`) qui permet d'assigner une valeur à la variable.

```c
// print_var.ez
a := 1
print a
```

La seconde manière est de déclarer une variable en lisant une valeur depuis l'entrée standard.

```c
// read.ez
read a
```

## Conditions

### If

La structure `if` permet d'exécuter du code si une condition est vérifiée.

```c
// if.ez
read a

if a == 1 then
  print "a == 1"
endif
```

### Else

La structure `else` permet d'exécuter du code si une condition n'est pas vérifiée.

```c
// else.ez
read a

if a == 1 then
  print "a == 1"
else
  print "a != 1"
endif
```

### Elif

La structure `elif` permet d'exécuter du code si une condition est vérifiée.

```c
// elif.ez
read a

if a == 1 then
  print "a == 1"
elif a == 2 then
  print "a == 2"
elif a == 3 then
  print "a == 3"
elif a == 4 then
  print "a == 4"
else
  print "a != 1 and a != 2 and a != 3 and a != 4"
endif
```

## Opérations

Les opérations sont définies par les symboles suivants :

- `+` : Addition
- `-` : Soustraction
- `*` : Multiplication
- `/` : Division
- `%` : Modulo

```c
// operations.ez
a := 1 + 1
b := 2 - 1
c := 3 * 2
d := 4 / 2
e := 5 % 2

print a // 2
print b // 1
print c // 6
print d // 2
print e // 1
```

Il est également possible d'effectuer des opérations sur des variables.

```c
// operations_var.ez
a := 1

a := a + 1
// ou
a++

print a
```

## Boucles

### While

La boucle `while` permet d'exécuter du code tant qu'une condition est vérifiée.

```c
// while.ez
read a

while a != 0 do
  print a
  a := a - 1
endwhile
```

### For

La boucle `for` permet d'exécuter du code un nombre défini de fois.

```c
// for.ez
for i := 0 to 10 do
  print i
endfor
```

Il est également possible de définir un pas pour la boucle.

```c
// for_step.ez
for i := 0 to 10 step 2 do
  print i
endfor
```

## PGCD

```c
// pgcd.ez

read "Premier nombre ? " a
read "Deuxième nombre ? " b

while b != 0 do
    c := a
    a := b
    b := c % b
endwhile

print "PGCD : " a + b
```

## Fibonacci

> Note : Nous utilisons le while pour la boucle car la boucle for n'était pas encore implémentée.

```c
// fibonacci.ez
read "Nombre ? " n

a := 0
b := 1

i := 0
while i < n do
    print a
    c := a
    a := b
    b := c + b
    i := i + 1
endwhile
```

## Nombre premier

```c
// nombre_premier.ez
read "Nombre ? " n

isprime := 0

i := 2
while i < n do
    c := n % i
    if c == 0 then
        is_prime := 1
        break
    endif
    i := i + 1
endwhile

if is_prime == 0 then
    print "Nombre premier"
else
    print "Nombre non premier"
endif
```

## Exercices

### Exercice 4 (Gestion des tests simples)

Ajoutez des régles au langage facile pour qu'il puisse gérer les instructions if sans l'utilisation des mots-clés else et elif et sans tests imbriqués.

Voir le fichier [examples/Conditions/if.ez](examples/Conditions/if.ez) pour un exemple de code source.

### Exercice 5 (Gestion des tests complexes)

Ajoutez des régles au langage facile pour qu'il puisse gérer les instructions if avec l'utilisation des mots-clés else et elif.

Voir le fichier [examples/Conditions/elif.ez](examples/Conditions/elif.ez) pour un exemple de code source.

### Exercice 6 (Gestion des tests imbriqués)

Ajoutez des regles au langage facile pour qu'il puisse gérer les instructions if avec des tests imbriqués.

```c
// nested_if.ez
read a

if a >= 18 then
  print "Vous êtes majeur"
  if a >= 21 then
    print "Vous pouvez boire de l'alcool"
  else
    print "Vous pouvez boire de l'alcool en France"
  endif
endif
```

### Exercice 7 (Gestion des boucles simples)

Ajoutez des régles au langage facile pourqu'il puisse gérer les instructions while sans l'utilisation des mot-clés break et continue et sans boucles imbriquées.

Voir le fichier [examples/Boucles/while.ez](examples/Boucles/while.ez) pour un exemple de code source.

### Exercice 8 (Gestion des boucles complexes)

Ajoutez des régles au langage facile pour qu'il puisse gérer les instructions while avec l'utilisation des mot-clés break et continue.

```c
// while_break.ez
read a

while a != 0 do
  print a
  a := a - 1
  if a == 5 then
    break
  endif
endwhile
```

```c
// while_continue.ez
read a

while a != 0 do
  a := a - 1
  if a == 5 then
    continue
  endif
  print a
endwhile
```

### Exercice 9 (Gestion des boucles imbriquées)

Ajoutez des régles au langage facile pour qu'il puisse gérer les instructions while avec des boucles imbriquées.

```c
// nested_while.ez
read a

while a != 0 do
  print a
  a := a - 1
  b := 10
  while b != 0 do
    print "\t" b
    b := b - 1
  endwhile
endwhile
```

### Exercice 10 (Le pgcd)

Écrivez un programme dans Ie langage facile permettant de calculer le plus grand commun diviseur de deux nombres saisis au clavier.

Voir le fichier [examples/pgcd.ez](examples/pgcd.ez) pour un exemple de code source.

### Exercice Bonus (Fibonacci, nombre premier)

Voir les fichiers [examples/fibonacci.ez](examples/fibonacci.ez) et [examples/nombre_premier.ez](examples/nombre_premier.ez) pour des exemples de code source.

## Ressources

- [Common Intermediate Language](https://en.wikipedia.org/wiki/Common_Intermediate_Language)
- [List of CIL instructions](https://en.wikipedia.org/wiki/List_of_CIL_instructions)
- [Understanding Common Intermediate Language (CIL)](https://www.codeproject.com/articles/362076/understanding-common-intermediate-language-cil)
- [Glib](https://docs.gtk.org/glib/struct.Node.html)

## Auteurs

- [**Hokanosekai**](https://github.com/Hokanosekai)
- [**Bash62**](https://github.com/bash62)

## Licence

Ce projet est sous licence [MIT](LICENSE).