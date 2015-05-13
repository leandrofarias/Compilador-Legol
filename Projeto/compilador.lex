%{

#define YYSTYPE char*
#include "compilador.tab.h"

%}

%option yylineno

ESPACO			[ \t\r]+
ENTER			[\n]
LETRA			[a-zA-Z]
DIGITO			[0-9]
COMENTARIO		"//".*
ALGORITMO		algoritmo
VAR			var
INICIO			inicio
FIMALGORITMO		fimalgoritmo
INTEIRO			inteiro
REAL			real
CARACTERE		caractere
LOGICO			logico
VETOR			vetor
LEIA			leia
ESCREVA			escreva[l]?
SE			se
ENTAO			entao
SENAO			senao
FIMSE			fimse
PARA			para
DE			de
ATE			ate
FACA			faca
PASSO			passo
FIMPARA			fimpara
REPITA			repita
ENQUANTO		enquanto
FIMENQUANTO		fimenquanto
ESCOLHA			escolha
CASO			caso
OUTROCASO		outrocaso
FIMESCOLHA		fimescolha
FUNCAO			funcao
FIMFUNCAO		fimfuncao
RETORNE			retorne
NAO			nao
E			e
OU			ou
XOU			xou
VERDADEIRO		verdadeiro
FALSO			falso
MOD			mod
RAIZQ			raizq
PROCEDIMENTO		procedimento
FIMPROCEDIMENTO		fimprocedimento
STRING			\"[^\"\n]*\"
NUMERO_INTEIRO		{DIGITO}+
NUMERO_REAL		{DIGITO}+("."{DIGITO}+)
VARIAVEL		{LETRA}([a-zA-Z0-9_])*

%%

{ESPACO}		{ }
{COMENTARIO}		{ }
{ENTER}			return ENTER;
{ALGORITMO}		return ALGORITMO;
{VAR}			return VAR;
{INICIO}		return INICIO;
{FIMALGORITMO}		return FIMALGORITMO;
{INTEIRO}		return INTEIRO;
{REAL}			return REAL;
{CARACTERE}		return CARACTERE;
{LOGICO}		return LOGICO;
{VETOR}			return VETOR;
{LEIA}			return LEIA;
{ESCREVA}		return ESCREVA;
{SE}			return SE;
{ENTAO}			return ENTAO;
{SENAO}			return SENAO;
{FIMSE}			return FIMSE;
{PARA}			return PARA;
{DE}			return DE;
{ATE}			return ATE;
{FACA}			return FACA;
{PASSO}			return PASSO;
{FIMPARA}		return FIMPARA;
{REPITA}		return REPITA;
{ENQUANTO}		return ENQUANTO;
{FIMENQUANTO}		return FIMENQUANTO;
{ESCOLHA}		return ESCOLHA;
{CASO}			return CASO;
{OUTROCASO}		return OUTROCASO;
{FIMESCOLHA}		return FIMESCOLHA;
{FUNCAO}		return FUNCAO;
{FIMFUNCAO}		return FIMFUNCAO;
{RETORNE}		return RETORNE;
{NAO}			return NAO;
{E}			return E;
{OU}			return OU;
{XOU}			return XOU;
{MOD}			return MOD;
{RAIZQ}			return RAIZQ;
{PROCEDIMENTO}		return PROCEDIMENTO;
{FIMPROCEDIMENTO}	return FIMPROCEDIMENTO;
{VERDADEIRO}		return VERDADEIRO;
{FALSO}			return FALSO;
{STRING}		return STRING;
{NUMERO_INTEIRO}	return NUMERO_INTEIRO;
{NUMERO_REAL}		return NUMERO_REAL;
"<-"			return ATRIBUICAO;
"+"			return MAIS;
"-"			return MENOS;
"*"			return MULTIPLICACAO;
"/"			return DIVISAO;
"^"			return POTENCIA;
"<="			return MENOR_IGUAL;
">="			return MAIOR_IGUAL;
"<>"			return DIFERENTE;
"="			return IGUAL;
">"			return MAIOR;
"<"			return MENOR;
":"			return DOIS_PONTOS;
"("			return PARENTESE_E;
")"			return PARENTESE_D;
"["			return COLCHETE_E;
"]"			return COLCHETE_D;
".."			return INTERVALO;
","			return VIRGULA;
{VARIAVEL}		return VARIAVEL;
.			printf("ERRO: Caractere inválido! NÃO ESPERADO: %s - LINHA DO ERRO: %d\n", yytext, yylineno); return ERRO;
