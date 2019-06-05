%{
#include <stdio.h>
#include <stdlib.h>
#include "done.h"

extern int count;
extern char* yytext;
extern struct symT sym[1000];
extern int yylineno;


int type=0;
int className[26] ={0};
char stack[100][10];
int top=0;
char i_[4]="0";
char temp[5]="t";
char lhs[50];
char rhs[50];
char temp1[15];
int label[50];
char oper1[10]="*";
char oper2[10]="+";
char oper3[10]="-";
char oper4[10]="/";
char zero[2]="0";
int tempvalue[100][2];
int tempvaluecount=0;
int lnum=0;
int ltop=0;
int value=0;
int elseif_label[50];
int elseiflabelcount = 0;
int ifelse_label[10];
int ifelse_label_count=0;
int next[50];
int next_count=0;
int pro;
int n1,n2;
char switch_const[5][10];
int switch_count =0;
int case_label[20];
int case_label_count =0;
int switch_next[10];
int switch_next_count =0;
int switch_value=0;

%}

%union {
  int num;
  char* strtype;
}

%token t_NUM t_IF t_ELSE t_LE t_GE t_EQ t_NE t_OR t_AND t_SWITCH t_CASE t_DEFAULT t_BREAK t_INT t_FLOAT t_CHAR t_DOUBLE t_INCLUDE 
%token t_VOID t_COUT t_CIN t_COUTOP t_CINOP t_COUTSTR t_ENDL t_ACCESS t_CLASS
%token <num> t_ID 

%type <strtype> Exp
%type <strtype> Assign
%right '='
%left t_AND t_OR
%left '<' '>' t_LE t_GE t_EQ t_NE
%left '+''-'
%left '*''/'
%right UMINUS
%left '!'
%%
start:include stmt {printf("Input accepted.\n");};
stmt :Assign ';' stmt| decl stmt|Function stmt|ClassStmt ';' stmt|; 
stmt1 :	 if {onlyif();} stmt1| if_else stmt1 | else_if stmt1 |switch stmt1|coutstatement stmt1|cinstatement stmt1 |Assign ';' stmt1 
	|decl stmt1  |  ;

block: ';' |  '{'  stmt1 '}' ;
include: t_INCLUDE include |  ;

if  : t_IF '(' R_Exp ')'{ifcond();} block {value=1;} ;
if_else:  if t_ELSE{ifstmt();} block {elsestmt();};
else_if: if  else_if1 ;
else_if1: t_ELSE {if(value==1){next[next_count++]=lnum;initialifelse();value=0;}else{ifelse();}} t_IF '(' R_Exp ')' {ifcond();next[next_count++]=lnum;} block else_if2;
else_if2: else_if1 | t_ELSE {ifelse();}block {ifelse_else();} ;

switch : t_SWITCH '(' t_ID {switch_value=1;strcpy(switch_const[switch_count++],sym[$3].name);}')' switch1;
switch1: ';' | '{' case '}' 
case: case1 {switch_laststmt_nodefault();}|case1 default {switch_laststmt();};
case1:  case2 case1 | ;
case2:  t_CASE t_NUM {push(); if(switch_value==1){initial_case_cond();switch_value=0;}else{case_cond();}} ':' stmt1 | t_BREAK ';' {breakstmt();} ;
default: t_DEFAULT {defaultstmt();} ':' stmt1 break ; 
break : | t_BREAK';';

decl : type var ';' ;
type : t_INT {type=1;}| t_FLOAT {type=2;} | t_CHAR {type=3;}| t_DOUBLE {type=4;} | t_VOID {type=5;};
var : t_ID ',' var {sym[$1].type = type;}|t_ID{sym[$1].type = type;} ;

Assign : t_ID {push1($1);}'='{push();}Exp {codegen_assign();int t=$1;sym[t].lat_seen=sym[t].line_no;sym[t].line_no=yylineno;}

ClassStmt : t_CLASS t_ID '{'  t_ACCESS ':' stmt  t_ACCESS ':' stmt '}' { strcpy(sym[$2].prop,"CLASS");}
	   | t_CLASS t_ID ':' t_ACCESS t_ID '{'  t_ACCESS ':' stmt  t_ACCESS ':' stmt '}'{strcpy(sym[$2].prop,"CLASS"); } ;
			

Function: type t_ID {sym[$2].type=type; strcpy(sym[$2].prop,"FUNC"); }'('ArgListOpt')' block  ;	
ArgListOpt: ArgList|;
ArgList:  ArgList ',' Arg| Arg;
Arg: type var1 ;
var1 :t_ID;

coutstatement:t_COUT t_COUTOP t_COUTSTR t_COUTOP t_ENDL ';';

cinstatement: t_CIN t_CINOP t_ID ';';
	
Exp   : t_ID{push1($1);}'='{push();}Exp {codegen_assign();int t=$1;sym[t].lat_seen=sym[t].line_no;sym[t].line_no=yylineno;}
    | Exp'+' {push();}Exp {codegen();}
    | Exp'-' {push();}Exp {codegen();}
    | Exp'*' {push();}Exp {codegen();}
    | Exp'/' {push();}Exp {codegen();}
    | R_Exp
    | t_ID	{push1($1);}
    | t_NUM {push();}
    ;
R_Exp  : Exp'<' {push();}Exp{codegen();}
    | Exp'>' {push();}Exp{codegen();}
    | Exp t_LE {push();}Exp{codegen();}
    | Exp t_GE {push();}Exp{codegen();}
    | Exp t_EQ {push();}Exp{codegen();}
    | Exp t_NE {push();}Exp{codegen();}
    | Exp t_OR {push();}Exp{codegen();}
    | Exp t_AND{push();} Exp{codegen();}
    ;
%%

#include "lex.yy.c"
#include "addon.c"

void main()
{
yyin=fopen("file.c","r+");
yyout=fopen("out.txt","w");
yyparse();
int i;
for(i=0;i<count;i++){
if(!sym[i].scope)
	sym[i].scope=0;
printf("index: %2d, name: %10s, property: %3s, type: %d, value : %s, line_no: %d ,prev: %d , scope: %d\n",i,sym[i].name,sym[i].prop,sym[i].type,sym[i].value,sym[i].line_no,sym[i].lat_seen, sym[i].scope);
}

return;
}   


push(){
strcpy(stack[++top],yytext);
}

push1(id){
strcpy(stack[++top],sym[id].name);
}

codegen()
 {
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = %s %s %s\n",temp,stack[top-2],stack[top-1],stack[top]);
 for(int kgh=0;kgh<count;kgh++)
 {
	if((strcmp(stack[top-2],sym[kgh].name)==0))
	{
		strcpy(lhs,sym[kgh].value);
	}
	else if((strcmp(stack[top],sym[kgh].name)==0))
	{
		strcpy(rhs,sym[kgh].value);
	}
 }
 char ans[10];
 if(strcmp(stack[top-1],oper1)==0)
 {
	
	if(((strcmp(lhs,zero)==0)||(strcmp(rhs,zero)==0)))
	{
		strcpy(ans,zero);
		printf("%s = %s\n",temp,zero);
		
		tempvalue[tempvaluecount][0]=atoi(i_);
		tempvalue[tempvaluecount][1]=0;
		tempvaluecount++;
		
	}
	else
	{
		printf("%s = %s %s %s\n",temp,lhs,oper1,rhs);
		n1=atoi(lhs);
		n2=atoi(rhs);
		pro=n1*n2;
		itoa(pro,ans,10);
		printf("%s = %s\n",temp,ans);
		tempvalue[tempvaluecount][0]=atoi(i_);
		tempvalue[tempvaluecount][1]=pro;
		tempvaluecount++;
	}
 }
 if(strcmp(stack[top-1],oper2)==0)
 {
		
		printf("%s = %s %s %s\n",temp,lhs,oper2,rhs);
		n1=atoi(lhs);
		n2=atoi(rhs);
		pro=n1+n2;
		itoa(pro,ans,10);
		printf("%s = %s\n",temp,ans);
		tempvalue[tempvaluecount][0]=atoi(i_);
		tempvalue[tempvaluecount][1]=pro;
		tempvaluecount++;
		 }
 if(strcmp(stack[top-1],oper3)==0)
 {
		
		printf("%s = %s %s %s\n",temp,lhs,oper3,rhs);
		n1=atoi(lhs);
		n2=atoi(rhs);
		pro=n1-n2;
		itoa(pro,ans,10);
		printf("%s = %s\n",temp,ans);
		
		tempvalue[tempvaluecount][0]=atoi(i_);
		tempvalue[tempvaluecount][1]=pro;
		tempvaluecount++;
 }
 if(strcmp(stack[top-1],oper4)==0)
 {
	if(strcmp(rhs,zero)==0)
	{
		strcpy(ans,zero);
		printf("%s =%s ",temp,zero);
		
		tempvalue[tempvaluecount][0]=atoi(i_);
		tempvalue[tempvaluecount][1]=0;
		tempvaluecount++;
	}
	else
	{
		
		printf("%s = %s %s %s\n",temp,lhs,oper4,rhs);
		n1=atoi(lhs);
		n2=atoi(rhs);
		pro=n1/n2;
		itoa(pro,ans,10);
		printf("%s = %s\n",temp,ans);
		
		tempvalue[tempvaluecount][0]=atoi(i_);
		tempvalue[tempvaluecount][1]=pro;
		tempvaluecount++;
	}
 }
 top-=2;
 strcpy(stack[top],temp);

 int s= atoi(i_);
 s++;
 itoa(s,i_,10);
 }
 
 codegen_assign()
 {
 printf("%s = %s\n",stack[top-2],stack[top]);
 int id;
 for(int lmn=0;lmn<count;lmn++)
 {
	if(strcmp(sym[lmn].name,stack[top-2])==0)
	{
		strcpy(sym[lmn].value,stack[top]);
	}
	else
	{
		for(int hfj=0;hfj<tempvaluecount;hfj++)
		{
			char a[10];
			char b[10];
			char c[10];
			char g[3];
			strcpy(g,"t");
			itoa(tempvalue[hfj][0],a,10);
			strcat(g,a);
			if(strcmp(sym[lmn].value,g)==0)
			{
				itoa(tempvalue[hfj][1],b,10);
				strcpy(sym[lmn].value,b);
			}
		}
	}
 }
 top-=2;
 }
 
ifcond()
{
 lnum++;
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = not %s\n",temp,stack[top]);
 printf("if %s goto L%d\n",temp,lnum);
 int s= atoi(i_);
 s++;
 itoa(s,i_,10);
 label[++ltop]=lnum;
}

onlyif(){
int x;
lnum++;
x=label[ltop--];
printf("L%d: \n",x);
label[++ltop]=lnum;
}

ifstmt(){
int x;
lnum++;
x=label[ltop--];
printf("goto L%d\n",lnum);
printf("L%d: \n",x);
elseiflabelcount=elseiflabelcount+1;
elseif_label[elseiflabelcount]=lnum;
label[++ltop]=lnum;
}

elsestmt()
{
int y;
y=elseif_label[elseiflabelcount--];
printf("L%d: \n",y);
}

initialifelse(){
int x;
lnum++;
x=label[ltop--];
printf("goto L%d\n",lnum);
printf("L%d: \n",next[--next_count]);
ifelse_label[ifelse_label_count++] = lnum;
label[++ltop]=lnum;
}

ifelse(){
lnum++;
printf("goto L%d\n",ifelse_label[ifelse_label_count-1]);
printf("L%d: \n",next[--next_count]);
label[++ltop]=lnum;
}

ifelse_else(){
printf("L%d: \n",ifelse_label[--ifelse_label_count]);
}

initial_case_cond(){
 lnum++;
 switch_next[switch_next_count++]=lnum;
 lnum++;
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = %s == %s\n",temp,switch_const[switch_count-1],stack[top]);
 char temp2[5];
 strcpy(temp2,temp);
 int s= atoi(i_);
 s++;
 itoa(s,i_,10);
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = not %s\n",temp,temp2);
 printf("if %s goto L%d\n",temp,lnum);
 s= atoi(i_);
 s++;
 itoa(s,i_,10);
 case_label[case_label_count++]=lnum;
 label[++ltop]=lnum;
}

case_cond(){
 lnum++;
 printf("L%d: \n",case_label[--case_label_count]);
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = %s == %s\n",temp,switch_const[switch_count-1],stack[top]);
 char temp2[5];
 strcpy(temp2,temp);
 int s= atoi(i_);
 s++;
 itoa(s,i_,10);
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = not %s\n",temp,temp2);
 printf("if %s goto L%d\n",temp,lnum);
 s= atoi(i_);
 s++;
 itoa(s,i_,10);
 case_label[case_label_count++]=lnum;
 label[++ltop]=lnum;
 }
 
 breakstmt(){
 printf("goto L%d \n",switch_next[switch_next_count-1]);
 }
 
 switch_laststmt_nodefault(){
 printf("L%d: \n",case_label[--case_label_count]);
 printf("L%d: \n",switch_next[--switch_next_count]);
 }
 
 switch_laststmt(){
  printf("L%d: \n",switch_next[--switch_next_count]);
 }
 
defaultstmt(){
 printf("L%d: \n",case_label[--case_label_count]);
 }