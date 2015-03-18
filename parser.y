%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);
char *title;
void init_vector(char* buffer, int size);
char **references = NULL; //vetor de referencias
int count = 0; // contador de referencias
void add_reference(char* string);
%}
 
%union{
	char *str;
	char *title;
	int  *intval;
}

%token <str> T_STRING
%token <str> T_WHITESPACE
%token <str> T_NEWLINE

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
%token <str> T_ENDLINE

%type <str> title_stmt textbf_stmt textit_stmt maketitle_stmt itemize_stmt item_stmt phrase_stmt word_stmt item_stmt_list stmt_list img_stmt stmt
%type <str> bib_stmt bib_stmt_list item_bib_stmt
%type <str> cite_stmt

%start init_list

%error-verbose
 
%%
init_list:
		init_list init
	|	init
;

init:
		title_stmt
	|	document
	|	T_NEWLINE
;

stmt_list: 	stmt_list stmt { $$ = concat(2,$1,$2); }
	 |	stmt 
;

stmt:
		maketitle_stmt
	|	textbf_stmt 
	|	textit_stmt
	|	itemize_stmt
	|	img_stmt
	|	bib_stmt
	|	cite_stmt
	|	phrase_stmt
	|	T_NEWLINE { $$ = concat(2, $$, "<br/>\n"); }
/* 	|	T_ENDLINE { $$ = concat(2,$$,"<br/>"); } */
;
/*
text_stmt:
	phrase_stmt T_ENDLINE { $$ = concat(2,$1,"<br>"); printf("show");}
;*/

phrase_stmt:
	phrase_stmt word_stmt { $$ = concat(2,$1,$2); /*printf("zzzz'%s'\n", $$);*/ }
	| word_stmt { /*printf("xxx'%s'\n", $$);*/ }
;

word_stmt:
	T_STRING	
	| T_WHITESPACE
	
/*	| T_ENDLINE { printf("lido:"); $$ = concat(2, $$, "<br/>\n");; }*/
;
 
title_stmt:
	T_TITLE '{' phrase_stmt '}' {
		title = (char *)malloc(sizeof($3)); 
		title = $3;
	}
;

document:
	T_BEGIN '{' T_DOCUMENT '}' stmt_list T_END '{' T_DOCUMENT '}' {
		printf("<html>\n<body>\n");
		printf("%s", $5);
		printf("\n</body>\n</html>\n");
	}
;

/* MAKETITLE STMT */
maketitle_stmt:
	T_MAKETITLE {
		$$ = title;
	}
;


/* TEXTBF STMT */
textbf_stmt:
	T_TEXTBF '{' phrase_stmt '}' {
		$$ = concat(3, "<b>", $3, "</b>\n");
	}
;

/* TEXTIT STMT */
textit_stmt:
	T_TEXTIT '{' phrase_stmt '}' {
		$$ = concat(3, "<i>", $3, "</i>\n");
	}
;

/* ITEMIZE STMT */
itemize_stmt:
	T_BEGIN '{' T_ITEMIZE '}' item_stmt_list T_END '{' T_ITEMIZE '}'{
		$$ = concat(3, "<ul>\n", $5, "</ul>\n");
	}
;

item_stmt_list:
	item_stmt_list item_stmt { $$ = concat(2, $1, $2); }
	| item_stmt
;

item_stmt:
	T_ITEM T_WHITESPACE phrase_stmt{
		$$ = concat(3, "<li>", $3, "</li>\n");
	}
	
	|	T_ITEM '[' phrase_stmt ']' T_WHITESPACE phrase_stmt{
		$$ = concat(5, "<li><b>", $3, "</b> " , $6, "</li>\n");
	}
;

/* BIBLIOGRAPHY STMT */
bib_stmt:
	T_BEGIN '{' T_THEBIB '}' bib_stmt_list T_END '{' T_THEBIB '}'{
		$$ = concat(3, "<ul>\n", $5, "</ul>\n");
	}
;

bib_stmt_list:
	bib_stmt_list item_bib_stmt { $$ = concat(2, $1, $2); }
	| item_bib_stmt
;

item_bib_stmt:
	T_BBITEM '{' phrase_stmt '}' T_WHITESPACE phrase_stmt{
		add_reference($3);
		$$ = concat(3, "<li>", $6, "</li>\n");
	}
;

/* CITE STMT */
cite_stmt:
	T_CITE '{' phrase_stmt '}' {
		int n = search_reference($3);
		if(n)
		  $$ = concat(4, $$, "[", n, "]");
	}
;

/* IMG STMT */
img_stmt:
	T_IMG '{' phrase_stmt '}'{
		$$ = concat(3, "<img src=\"", $3, "\"/>\n");
	}
;

%%
void add_reference(char* string){
  int i;
  int arraySize = (count+1)*sizeof(char*);
  references = realloc(references,arraySize);
  if(references==NULL){
	fprintf(stderr,"Realloc unsuccessful");
	exit(EXIT_FAILURE);
  }
  
  int stringSize = strlen(string)+1;
  references[count] = malloc(stringSize);
  if(references[count]==NULL){
	  fprintf(stderr,"Malloc unsuccessful");
	  exit(EXIT_FAILURE);
  }
  
  strcpy(references[count], string);
  count++;
  /*
  for(i=0; i<count;i++){
	printf("array: %s\n", references[i]);
  }*/
}

int search_reference(char* reference){
	int i;
	for(i=0;i<count;i++){
		if(strcmp(reference, references[i]) == 0)
			return i+1;
	}
	return 0;
}
 
char* concat(int count, ...){
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

int yyerror(const char* errmsg){
	printf("\n*** Erro: %s\n", errmsg);
}
 
int yywrap(void) { return 1; }
 
int main(int argc, char** argv){
     yyparse();
     return 0;
}


