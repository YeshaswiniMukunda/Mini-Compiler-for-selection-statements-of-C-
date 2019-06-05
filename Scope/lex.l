%option yylineno
%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "head2.tab.h"

int InstallId(char a[]);
int InstallNum(char a[]);
void updatecount();
void reducecount();
int max(int a[]);
struct symT sym[1000];
int count=0;
int line=1;
int sco =0;
int scopes[20];
int scopes_count=0;
int recent_scope[20];
int recent_scope_count=0;
%}

single ("//".*)
comment ("/*"([^\*]|[\r\n])*"*/")
ALPHA [A-Za-z]
DIGIT [0-9]
space [ \t]
emptyline [\n]
start "{"
end "}"
%%
({comment}(\n)+) 			{fprintf(yyout,"");};
({single}(\n)+)  			fprintf(yyout,"");
{space}+   					fprintf(yyout," ");
{start}						fprintf(yyout," %s",yytext);updatecount();return yytext[0];
{end}						fprintf(yyout," %s",yytext);reducecount();return yytext[0];
[\n]+ 						{fprintf(yyout,"\n");line = line+yyleng;};
if                			{fprintf(yyout,"if");return t_IF;};
else                		{fprintf(yyout,"else");return t_ELSE;};
switch 						{fprintf(yyout,"switch");return t_SWITCH;};
break						{fprintf(yyout,"break");return t_BREAK;};
default						{fprintf(yyout,"default");return t_DEFAULT;};
case 						{fprintf(yyout,"case");return t_CASE;};
int							{fprintf(yyout,"int");return t_INT;};
float						{fprintf(yyout,"float");return t_FLOAT;};
char						{fprintf(yyout,"char");return t_CHAR;};
double						{fprintf(yyout,"double");return t_DOUBLE;};
void						{fprintf(yyout,"void");return t_VOID;};
^"#include"<\".+\.h\">		{fprintf(yyout,"%s",yytext);return t_INCLUDE;};
cout 						{ fprintf(yyout,"cout"); return t_COUT; }
endl						{ fprintf(yyout,"endl"); return t_ENDL; }
cin 						{ fprintf(yyout,"cin"); return t_CIN; }
class 						{ fprintf(yyout,"class");return t_CLASS;}
public|private|protected 	{ fprintf(yyout,"%s",yytext);return t_ACCESS;}
[0-9]+            			{fprintf(yyout,"%s",yytext);yylval.num=InstallNum(yytext);return t_NUM;};
\"({ALPHA}|{DIGIT}|[ ])*\"  { fprintf(yyout,"%s",yytext); return t_COUTSTR; }
{ALPHA}({ALPHA}|{DIGIT})*   {fprintf(yyout,"%s",yytext);yylval.num=InstallId(yytext);return t_ID;};
"<<"						{ fprintf(yyout,"<<"); return t_COUTOP; }
">>" 						{ fprintf(yyout,">>"); return t_CINOP; }
"<="                		{fprintf(yyout,"<="); return t_LE;};
">="                		{fprintf(yyout,">="); return t_GE;};
"=="                		{fprintf(yyout,"=="); return t_EQ;};
"!="                		{fprintf(yyout,"!="); return t_NE;};
"||"                		{fprintf(yyout,"||"); return t_OR;};
"&&"                		{fprintf(yyout,"&&"); return t_AND;};
.                			{fprintf(yyout,"%s",yytext); return yytext[0];};
%%
void updatecount()
{
	if(scopes_count==0)
		scopes[scopes_count++]=sco;
	int m = max(scopes);
	recent_scope[recent_scope_count++]=sco;
	sco = m+1;
	scopes[scopes_count++]=sco;
}

void reducecount(){
	int i;
	sco = recent_scope[--recent_scope_count];
}

int max( int a[])
{
 int i;
 if(scopes_count==0)
	return 0;
 int max1 = a[0];
 for(i=1;i<scopes_count;i++)
 {
	if(a[i]>max1){
		max1 = a[i];
	}
 }
 return max1;
}

int InstallId(char new[])
{
	for(int i =0;i<count;i++)
	{
		if(strcmp(new,sym[i].name)==0)
		{
			if(sym[i].scope==sco)
				return i;
			if(sym[i].scope<sco)
			{
				int ind=count;
	strcpy(sym[ind].name,new);
	strcpy(sym[ind].prop,"ID");
	sym[ind].line_no = yylineno;
	sym[ind].lat_seen = yylineno;
	sym[ind].scope=sco;
	count = count+1;
	strcpy(sym[ind].value,sym[i].value);return ind;
	
			}
			
		}
	}
	int ind=count;
	strcpy(sym[ind].name,new);
	strcpy(sym[ind].prop,"ID");
	strcpy(sym[ind].value,"0");
	sym[ind].line_no = yylineno;
	sym[ind].lat_seen = yylineno;
	sym[ind].scope=sco;
	count = count+1;
	return ind;
}

int InstallNum(char new[])
{
	
	for(int i =0;i<count;i++)
	{
		if(strcmp(new,sym[i].value)==0)
		{return i;}
	}
	int ind=count;
	strcpy(sym[ind].name,"---");
	strcpy(sym[ind].value,new);
	strcpy(sym[ind].prop,"NUM");
	sym[ind].scope=0;
	count = count+1;
	return ind;
}


