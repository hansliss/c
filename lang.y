%{

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "hc.h"

extern char *yytext;

extern void yyerror(char *);

%}

%union {
	char *s;
	double d;
	int i;
	char c;
}

%token <d> INUM
%token <i> ID
%token <i> FUNC
%token <c> CHAR
%token ENDOFLINE
%token '?'

%type <d> expr
%type <d> stmt

%left ASSIGN
%left OR AND
%left '<' '>'
%left '='
%left '+' '-'
%left '*' '/' 
%left UNARYMINUS
%left NOT

%start lines

%% /***********************************************************************/

lines
	:
  | lines stmt
	;

stmt : expr ENDOFLINE  { printf("%g\n",$1); }
  | '?' ENDOFLINE { printf("Calcer version 2.00 - Hans Liss 1994 - 2000\n"); }
  | error ENDOFLINE { printf("Syntax error\n"); }
     ;
expr
	: INUM { $$ = $1; }
	| FUNC '(' expr ')' { $$ = func($1,$3); }
	| ID { $$ = id_val[$1]; }
	| expr '+' expr { $$ = $1 + $3; }
	| expr '-' expr { $$ = $1 - $3; }
	| expr '*' expr {  $$ = $1 * $3; }
	| expr '/' expr {  $$ = $1 / $3; }
	| expr '<' expr { $$ = $1 < $3; }
	| expr '>' expr { $$ = $1 > $3; }
	| expr '=' expr { $$ = $1 == $3; }
	| expr OR expr { $$ = $1 || $3; }
	| expr AND expr { $$ = $1 && $3; }
	| '-' expr %prec UNARYMINUS {  $$ = - $2; }
	| NOT expr {  $$ = ! $2; }
	| '(' expr ')' { $$ = $2; }
	| ID ASSIGN expr { $$ = (id_val[$1] = $3); }
	;

%%


