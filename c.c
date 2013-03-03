#include "hc.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include "config.h"

char *id_name[MAX_ID];
double id_val[MAX_ID];
char *intxt;
int intxtptr,intxtlen;
int rval;

#ifdef YYDEBUG
 extern int yydebug;
#endif
#ifdef LEXDEBUG
 int debug;
#endif

extern void yyparse(void);

#define min(a,b) (((b)<(a))?(b):(a))

int yyerror()
{
 fprintf(stderr,"Syntax error\n");
 return 0;
}

char my_input()
{
 char c;
 if (intxt)
 {
  if (intxtptr<intxtlen)
    c=intxt[intxtptr++];
  else
    c=0;
 }
 else
 {
   if ((c=getchar())==-1)
     c=0;
 }
 return c;
}

void my_yy_input(char *buf, int *n, int max_size)
{
  int i;
  for (i=0;i<max_size;i++)
    if ((buf[i]=my_input())==0)
      break;
  *n=i;
}

int unput(char c)
{
 if (intxt)
 {
  if (intxtptr>0)
    intxt[--intxtptr]=c;
 }
 else
 {
   ungetc(c,stdin);
 }
 return 0;
}

char *func_name[]={"&sin","&cos","&sqrt","&tan","&atan","&log","&ln","&log2"};
#define KNOWN_FUNCS ((sizeof(func_name)) / (sizeof(char*)))
#define F_SIN	0
#define F_COS	1
#define F_SQRT	2
#define F_TAN	3
#define F_ATAN	4
#define F_LOG	5
#define F_LN	6
#define F_LOG2	7

int known_funcs()
{
  return KNOWN_FUNCS;
}

double func(int index,double value)
{
  /*  fprintf(stderr,"[func(%d,%g)]\n",index,value);*/
  switch (index)
    {
    case F_SIN: return sin(value);
    case F_COS: return cos(value);
    case F_SQRT: return sqrt(value);
    case F_TAN: return tan(value);
    case F_ATAN: return atan(value);
    case F_LOG: return log10(value);
    case F_LN: return log(value);
    case F_LOG2: return log(value)/log(2);
    }
  return value;
}

int main(int argc,char *argv[])
{
 int i;
 int nextvar;
 FILE *varfile;
 char inbuf[80],*p1;
 intxtlen=2;
 intxt=NULL;
 rval=0;

#ifdef YYDEBUG
 yydebug=1;
#endif
#ifdef LEXDEBUG
 debug=1;
#endif

 if (argc>1)
 {
  for (i=1;i<argc;i++)
   intxtlen+=1+strlen(argv[i]);
  if (!(intxt=(char*)malloc(intxtlen+1)))
  {
   fprintf(stderr,"Command line too long...\n");
   exit(1);
  }
  intxt[0]='\0';
  for (i=1;i<argc;i++)
  {
   strcat(intxt,argv[i]);
   strcat(intxt," ");
  }
  strcat(intxt,"\n");
  intxtlen=strlen(intxt);
  intxtptr=0;
 }
 for (i=0; i<MAX_ID; i++)
 {
  id_name[i] = 0;
  id_val[i] = 0;
 }
 nextvar=0;
 if ((varfile=fopen(VARFILE,"r"))!=NULL)
   {
     if (fgets(inbuf,80,varfile) != NULL) {
       while (!feof(varfile) && (nextvar<MAX_ID))
	 {
	   p1=(char*)strchr(inbuf,'=');
	   if (p1)
	     {
	       *(p1++)='\0';
	       id_name[nextvar]=(char *)malloc(strlen(inbuf)+1);
	       strcpy(id_name[nextvar],inbuf);
	       sscanf(p1,"%lf",&(id_val[nextvar]));
	       nextvar++;
	     }
	   if (!fgets(inbuf,80,varfile))
	     perror("reading from " VARFILE);
	 }
     } else perror("reading from " VARFILE);
     fclose(varfile);
   }
 yyparse();
 if ((varfile=fopen(VARFILE,"w"))!=NULL)
   {
     for (i=0;i<MAX_ID;i++)
       if (id_name[i]!=NULL)
       {
	 if (id_val[i]!=0)
	   fprintf(varfile,"%s=%f\n",id_name[i],id_val[i]);
	 free(id_name[i]);
       }
     fclose(varfile);
   }
 if (intxt)
  free(intxt);
 return rval;
}
