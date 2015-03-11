%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);
void init_vector(char* buffer, int size);
%}
 
%union{
	char *str;
	int  *intval;
}

%token <str> T_STRING
%token T_SELECT
%token T_FROM
%token T_CREATE
%token T_TABLE
%token T_INSERT
%token T_INTO
%token T_VALUES

%type <str> create_stmt insert_stmt select_stmt col_list col_select_list values_list 

%start stmt_list

%error-verbose
 
%%

stmt_list: 	stmt_list stmt 
	 |	stmt 
;

stmt:
		create_stmt ';'	{printf("%s",$1);}
	|	insert_stmt ';'	{printf("%s",$1);}
	|	select_stmt ';' {printf("%s",$1);}

;

create_stmt:
	   T_CREATE T_TABLE T_STRING '(' col_list ')' 	{	FILE *F = fopen($3, "w"); 
								fprintf(F, "%s\n", $5);
								fclose(F);
								$$ = concat(5, "\nCREATE TABLE: ", $3, "\nCOL_NAME: ", $5, "\n\n");
							}
;

col_list:
		T_STRING 		{ $$ = $1; }
	| 	col_list ',' T_STRING 	{ $$ = concat(3, $1, ";", $3); }
;
 
%%
 
char* concat(int count, ...)
{
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}

void init_vector(char* string, int size){
	int i = 0;
	for(i=0;i<size;i++){
		string[i] = 0;
	}
}

int yyerror(const char* errmsg)
{
	printf("\n*** Erro: %s\n", errmsg);
}
 
int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
     yyparse();
     return 0;
}


