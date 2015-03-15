%{
#include "parser.h"
%}

DOCUMENTCLASS \\documentclass\[.*\]\{.*\}
USERPACKAGE \\userpackage\[.*\]\{.*\}
AUTHOR \\athor\{.*\}

PHRASE [A-z0-9_ \.\,-]+
STRING [A-z0-9_ ]+
WHITESPACE [ \r\t]+
ANY_CHAR .

%%

{WHITESPACE}         /* ignore */ ;
{DOCUMENTCLASS}      /* ignore */ ;
{USERPACKAGE}        /* ignore */ ;
{AUTHOR}             /* ignore */ ;

"\\title" {	
	yylval.title = (char *) strdup(yytext);
	return T_TITLE;
}

"\\begin" 			{return T_BEGIN; }
"\\end"				{return T_END;}
"\\maketitle"			{return T_MAKETITLE;}
"\\textbf"			{return T_TEXTBF;}
"\\textit"			{return T_TEXTIT;}
"\\includegraphics"		{return T_IMG;}
"\\cite"			{return T_CITE;}
"\\bibitem"			{return T_BBITEM;}
"\\item"			{return T_ITEM;}
"document"			{return T_DOCUMENT;}
"itemize"			{return T_ITEMIZE;}
"thebibliography"		{return T_THEBIB;}

"\\$"	{return T_CIFRAO;}
"\\n"	{return T_NEWLINE;}

"("		{return '(';}
")"		{return ')';} 
"{"		{return '{';}
"}"		{return '}';}
"," 		{return ',';}
";"		{return ';';}
"*"		{return '*';}

{PHRASE} {
	yylval.str = (char *) strdup(yytext);
	return T_PHRASE;
}

{STRING} {
	yylval.str = (char *) strdup(yytext);
	return T_STRING;
}

{ANY_CHAR} {
	printf ("Caracter %c (ASCII=%d) inesperado\n", yytext[0], yytext[0]);
}


