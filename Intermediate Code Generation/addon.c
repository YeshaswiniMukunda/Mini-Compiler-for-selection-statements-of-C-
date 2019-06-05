#include<stdio.h>
int yywrap(void)
{
return 1;
}

void yyerror(char const *s)
{
	//fprintf(stderr,"%d %s\n",yylineno,s);
	printf("%s",stderr);
}