%{
#include "parser.h"

%}

DOCUMENTCLASS \\documentclass\{.*\}
DOCUMENTCLASS1 \\documentclass\[.*\]\{.*\}
USEPACKAGE \\usepackage\{.*\}
USEPACKAGE1 \\usepackage\[.*\]\{.*\}
AUTHOR \\author\{.*\}

NEWLINE [\n]
WHITESPACE [ \r\t]+
STRING [a-zA-Z0-9_\.,-/$]+
ANY_CHAR .

%%
{DOCUMENTCLASS}      /* ignore */ ;
{DOCUMENTCLASS1}     /* ignore */ ;
{USEPACKAGE}        /* ignore */ ;
{USEPACKAGE1}       /* ignore */ ;
{AUTHOR}             /* ignore */ ;

"\\title" 				{return T_TITLE;}
"\\begin" 				{return T_BEGIN;}
"\\end"					{return T_END;}
"\\maketitle"			{return T_MAKETITLE;}
"\\textbf"				{return T_TEXTBF;}
"\\textit"				{return T_TEXTIT;}
"\\includegraphics"		{return T_IMG;}
"\\cite"				{return T_CITE;}
"\\bibitem"				{return T_BBITEM;}
"\\item"				{return T_ITEM;}
"document"				{return T_DOCUMENT;}
"itemize"				{return T_ITEMIZE;}
"thebibliography"		{return T_THEBIB;}

"\\$"	{return T_CIFRAO;}
"["		{return '[';}
"]"		{return ']';}
"("		{return '(';}
")"		{return ')';} 
"{"		{return '{';}
"}"		{return '}';}
"," 	{return ',';}
";"		{return ';';}
"*"		{return '*';}

{WHITESPACE} {
	yylval.str = (char *) strdup(yytext);
	return T_WHITESPACE;
} ;

{NEWLINE} { return T_ENDLINE; }

{STRING} {
	yylval.str = (char *) strdup(yytext);
	return T_STRING;
}

{ANY_CHAR} {
	printf ("Caracter %c (ASCII=%d) inesperado\n", yytext[0], yytext[0]);
}


