#define VARFILE "/etc/cvar.val"
#define MAX_ID	200
extern char *id_name[MAX_ID];
extern double id_val[MAX_ID];
extern char *intxt;
extern int intxtptr;
extern int intxtlen;
extern int rval;
extern double func(int index,double value);
extern char *func_name[];
extern int known_funcs();
#undef unput
extern void my_yy_input(char *buf, int *n, int max_size);
#undef YY_INPUT
#define YY_INPUT(buf, n, max_size) my_yy_input((buf), &(n), (max_size))
#define YY_NO_UNPUT
