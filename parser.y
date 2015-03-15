%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);
char *title;
void init_vector(char* buffer, int size);

%}
 
%union{
	char *str;
	char *title;
	int  *intval;
}

%token <str> T_STRING
%token <str> T_PHRASE

%token T_TITLE
%token T_BEGIN
%token T_END
%token T_MAKETITLE
%token T_TEXTBF
%token T_TEXTIT
%token T_IMG
%token T_CITE
%token T_BBITEM
%token T_ITEM
%token T_DOCUMENT
%token T_ITEMIZE
%token T_THEBIB
%token T_CIFRAO
%token T_NEWLINE

%type <str> title_stmt textbf_stmt textit_stmt maketitle_stmt

%start stmt_list

%error-verbose
 
%%

stmt_list: 	stmt_list stmt 
	 |	stmt 
;

stmt:
		title_stmt 
	|	maketitle_stmt
	|	textbf_stmt 
	|	textit_stmt
	
;
 
title_stmt:
	T_TITLE '{' T_PHRASE '}' {
		title = (char *)malloc(T_PHRASE); 
		title = $3;
	}
;

maketitle_stmt:
	T_MAKETITLE {
		printf("%s", title);
		
	}
;

textbf_stmt:
	T_TEXTBF '{' T_PHRASE '}' {
		printf("<b> %s </b>", $3);
	}
;

textit_stmt:
	T_TEXTIT '{' T_PHRASE '}' {
		printf("<i> %s </i>", $3);
	}
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


