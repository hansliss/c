typedef union {
	char *s;
	double d;
	int i;
	char c;
} YYSTYPE;
#define	INUM	257
#define	ID	258
#define	FUNC	259
#define	CHAR	260
#define	ENDOFLINE	261
#define	ASSIGN	262
#define	OR	263
#define	AND	264
#define	UNARYMINUS	265
#define	NOT	266


extern YYSTYPE yylval;
