
%{

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "lang.h"
#include "hc.h"


#undef input
#undef unput
int do_real();
static int hex2dec();
int do_rhex();
int do_dec();
int do_hex();
int do_oct();
int do_bin();
int do_id();
int do_func();
%}


AND	[aA]+[nN]+[dD]
OR	[oO]+[rR]
NOT	[nN]+[oO]+[tT]
REAL	[0-9]+[.][0-9]*([Ee][+-]*[0-9]+)?
REAL2	[0-9]+[Ee][+-]*[0-9]+
RHEX	0x[0-9a-fA-F]*[.][0-9a-fA-F]*
DEC	[1-9][0-9]*
OCT	0[0-9]*
HEX	0x[0-9A-Fa-f]+
BIN	0b[0-1]*

ID	[a-zA-Z_][a-zA-Z0-9_]*
FUNC	&[a-zA-Z0-9_]*

%%

{REAL}			return do_real();
{REAL2}			return do_real();
{RHEX}			return do_rhex();
{DEC}			return do_dec();
{HEX}			return do_hex();
{OCT}			return do_oct();
{BIN}			return do_bin();

e			{ yylval.d = M_E; return INUM; }
pi			{ yylval.d = M_PI; return INUM; }

{OR}			return OR;
{AND}			return AND;
{NOT}			return NOT;

{ID}			return do_id();
{FUNC}			return do_func();

\>\>			return '>';
\<\<			return '<';
\004			return 0;
\[	      return '(';
\]	      return ')';
:=	return ASSIGN;

\n     { return ENDOFLINE; }

[ \t]+ ;

.			return yytext[0];

%%

int do_real()
{
  sscanf(yytext, "%lf", &yylval.d);
  return INUM;
}

static int hex2dec(c)
char c;
{
  switch (c)
  {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      return c-'0';
    case 'a':
    case 'b':
    case 'c':
    case 'd':
    case 'e':
    case 'f':
      return c-'a'+10;
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case 'F':
      return c-'A'+10;
  }
  return 0;
}

int do_rhex()
{
  double scale;
  char *cp = yytext + 2;
  yylval.d = 0.0;
  while (*cp != '.')
  {
    yylval.d *= 10.0;
    yylval.d += hex2dec(*cp);
    cp++;
  }
  cp++;
  scale = 1.0 / 16.0;
  while (*cp)
  {
    yylval.d += scale * hex2dec(*cp);
    scale /= 16.0;
    cp++;
  }
  return INUM;
}

int do_dec()
{
  int tmp;
  sscanf(yytext, "%d", &tmp);
  yylval.d = tmp;
  return INUM;
}

int do_hex()
{
  unsigned tmp;
  sscanf(yytext+2, "%x", &tmp);
  yylval.d = tmp;
  return INUM;
}

int do_oct()
{
  unsigned tmp;
  sscanf(yytext, "%o", &tmp);
  yylval.d = tmp;
  return INUM;
}

int do_bin()
{
  int rv=0;
  char *yp;
  for (yp = yytext+2; *yp; yp++)
  {
    rv <<= 1;
    rv += *yp - '0';
  }
  yylval.d = rv;
  return INUM;
}

int do_id()
{
  int i;
  for (i=0; i<MAX_ID; i++)
  {
    if (id_name[i] == 0)
    {
      id_name[i] = strdup(yytext);
      yylval.i = i;
      return ID;
    }
    if (strcmp(id_name[i], yytext) == 0)
    {
      yylval.i = i;
      return ID;
    }
  }
  printf("Too many ID's (max=%d)\n", MAX_ID);
  return 1; /* forced error */
}

int do_func()
{
  int i;
  for (i=0; i < known_funcs(); i++)
    if (!strcasecmp(func_name[i], yytext))
    {
      yylval.i = i;
      return FUNC;
    }
  printf("Unimplemented function %s\n", yytext);
  return 1; /* forced error */
}
