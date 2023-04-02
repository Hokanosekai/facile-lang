<div align="center">

![Logo de mon projet](./img/logo_univ.png)
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
- [Exemple de code](#exemple-de-code)
  - [Commentaires](#commentaires)
  - [Variables](#variables)
  - [Conditions](#conditions)
    - [If](#if)
    - [Else](#else)
    - [Elif](#elif)
  - [I/O](#io)
    - [Read](#read)
    - [Print](#print)
  - [Opérations](#opérations)
  - [Boucles](#boucles)
    - [While](#while)
    - [For](#for)
  - [PGCD](#pgcd)
  - [Fibonacci](#fibonacci)
- [Exercice](#exercice)
  - [Exercice 1](#exercice-1)
  - [Exercice 2](#exercice-2)
  - [Exercice 3](#exercice-3)
  - [Exercice 4](#exercice-4)
- [Authors](#authors)
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
  - 




