%{

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "config.h"
#include "hc.h"

extern char *yytext;
extern void yyerror(char *);
double last_val;
int decimals=4;
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
%left NEQ LEQ GEQ
%left '='
%left '+' '-'
%left '*' '/' '%'
%left UNARYMINUS
%left NOT
%left PREC

%start lines

%% /***********************************************************************/

lines
	:
  | lines stmt
	;

stmt : expr ENDOFLINE  { printf("%.*f\n", decimals, $1); last_val=$1; }
     | '?' ENDOFLINE { printf("Calcer version 2.00 - Hans Liss 1994 - 2000\n"); }
     | error ENDOFLINE { printf("Syntax error\n"); }
     ;
expr
        : INUM { $$ = $1; }
        | PREC '(' expr ',' expr ')' { decimals = $3; $$ = $5; }
	| FUNC '(' expr ')' { $$ = func($1,$3); }
	| ID { $$ = id_val[$1]; }
	| expr '+' expr { $$ = $1 + $3; }
	| expr '-' expr { $$ = $1 - $3; }
	| expr '*' expr {  $$ = $1 * $3; }
	| expr '/' expr {  $$ = $1 / $3; }
        | expr '%' expr {  $$ = (long)$1 % (long)$3; }
	| expr '<' expr { $$ = $1 < $3; }
	| expr '>' expr { $$ = $1 > $3; }
	| expr '=' expr { $$ = $1 == $3; }
	| expr OR expr { $$ = $1 || $3; }
	| expr AND expr { $$ = $1 && $3; }
	| expr NEQ expr { $$ = $1 != $3; }
	| expr LEQ expr { $$ = $1 <= $3; }
	| expr GEQ expr { $$ = $1 >= $3; }
	| '-' expr %prec UNARYMINUS {  $$ = - $2; }
	| NOT expr {  $$ = ! $2; }
	| '(' expr ')' { $$ = $2; }
	| ID ASSIGN expr { $$ = (id_val[$1] = $3); }
	;

%%


