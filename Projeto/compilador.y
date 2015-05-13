%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "fila.c"
#include "hash.c"

#define YYSTYPE char*

extern yylineno;
extern char *yytext;

int erros;
int inicio_linha = 0;
int retorne_habilitado = 0;
int primeiro_caso = 1;
int verificacao_indice1 = 1;
int verificacao_indice2 = 1;
int primeiro_indice = -1;
int segundo_indice = -1;
int terceiro_indice = -1;
int quarto_indice = -1;

int alg_correto = 0;
int nome_correto = 0;
int inicio_correto = 0;

char nome_alg[64];
char arquivo[64];
char escopo[8];
char nome_funcao[32];
char parametros[64];

char comando[10];
char auxiliar[64];
char tipo_retorno[10];
char tipo_escolha[10];
char var_escolha[32];

TipoTabela tabela_hash;
TipoItem elemento;
TipoFila *fila;

void inserir_variavel(TipoItem item, int linha) {
	strcpy(item.chave, item.variavel);
	strcat(item.chave, item.escopo);

	if (nome_funcao != NULL) {
		strcat(item.chave, nome_funcao);
	}

	if (!inserir_item(item, tabela_hash)) {
		erros++;
		printf("ERRO: Variável '%s' declarada mais de uma vez! LINHA DO ERRO: %d.\n", item.variavel, linha);
	}

	primeiro_indice = -1;
	segundo_indice = -1;
	terceiro_indice = -1;
	quarto_indice = -1;
}

void inserir_funcao(TipoItem item, int linha) {
	strcpy(item.chave, item.variavel);
	strcat(item.chave, item.escopo);

	if (!inserir_item(item, tabela_hash)) {
		erros++;

		if (!strcmp(item.tipo, "")) {
			printf("ERRO: Procedimento '%s' declarado mais de uma vez! LINHA DO ERRO: %d.\n", item.variavel, linha);
		} else {
			printf("ERRO: Função '%s' declarada mais de uma vez! LINHA DO ERRO: %d.\n", item.variavel, linha);
		}
	}
}

void verificar_variavel(TipoVariavel variavel, int linha) {
	char *var = strdup(variavel);
	char *chave = strdup(var);
	strcat(chave, escopo);

	if (nome_funcao != NULL) {
		strcat(chave, nome_funcao);
	}

	Ponteiro ponteiro = pesquisar(chave, tabela_hash);
	if (ponteiro == NULL) {
		if (!strcmp(escopo, "local")) {
			strcat(var, "global");
			ponteiro = pesquisar(var, tabela_hash);

			if (ponteiro == NULL) {
				erros++;
				printf("ERRO: Variável '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
			} else {
				if (ponteiro->proxima->item.dimensao.quarto_indice != -1) {
					erros++;
					printf("ERRO: Ausência do par ordenado válido da matriz '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
				} else if (ponteiro->proxima->item.dimensao.segundo_indice != -1) {
					erros++;
					printf("ERRO: Ausência do índice do vetor '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
				}
			}
		} else {
			erros++;
			printf("ERRO: Variável '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	} else {
		if (ponteiro->proxima->item.dimensao.quarto_indice != -1) {
			erros++;
			printf("ERRO: Ausência do par ordenado válido da matriz '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (ponteiro->proxima->item.dimensao.segundo_indice != -1) {
			erros++;
			printf("ERRO: Ausência do índice do vetor '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	}
}

void verificar_vetor(TipoVariavel variavel, int indice, int linha) {
	char *var = strdup(variavel);
	char *chave = strdup(var);
	strcat(chave, escopo);

	if (nome_funcao != NULL) {
		strcat(chave, nome_funcao);
	}
	
	Ponteiro ponteiro = pesquisar(chave, tabela_hash);
	if (ponteiro == NULL) {
		if (strcmp(escopo, "local") == 0) {
			strcat(var, "global");
			ponteiro = pesquisar(var, tabela_hash);

			if (ponteiro == NULL) {
				erros++;
				printf("ERRO: Variável '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
			} else {
				if (ponteiro->proxima->item.dimensao.quarto_indice != -1) {
					erros++;
					printf("ERRO: Ausência do par ordenado válido da matriz '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
				} else if (ponteiro->proxima->item.dimensao.segundo_indice == -1) {
					erros++;
					printf("ERRO: Variável '%s' não é um vetor! LINHA DO ERRO: %d.\n", variavel, linha);
				} else if (indice < ponteiro->proxima->item.dimensao.primeiro_indice || 
					indice > ponteiro->proxima->item.dimensao.segundo_indice) {
						erros++;
						printf("ERRO: Índice inválido do vetor '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
				}
			}
		} else {
			erros++;
			printf("ERRO: Variável '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	} else {
		if (ponteiro->proxima->item.dimensao.quarto_indice != -1) {
			erros++;
			printf("ERRO: Ausência do par ordenado válido da matriz '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (ponteiro->proxima->item.dimensao.segundo_indice == -1) {
			erros++;
			printf("ERRO: Variável '%s' não é um vetor! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (indice < ponteiro->proxima->item.dimensao.primeiro_indice || 
			indice > ponteiro->proxima->item.dimensao.segundo_indice) {
			erros++;
			printf("ERRO: Índice inválido do vetor '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	}
}

void verificar_matriz(TipoVariavel variavel, int indice_linha, int indice_coluna, int linha) {
	char *var = strdup(variavel);
	char *chave = strdup(var);
	strcat(chave, escopo);

	if (nome_funcao != NULL) {
		strcat(chave, nome_funcao);
	}
	
	Ponteiro ponteiro = pesquisar(chave, tabela_hash);
	if (ponteiro == NULL) {
		if (strcmp(escopo, "local") == 0) {
			strcat(var, "global");
			ponteiro = pesquisar(var, tabela_hash);

			if (ponteiro == NULL) {
				erros++;
				printf("ERRO: Variável '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
			} else {
				if(ponteiro->proxima->item.dimensao.quarto_indice == -1) {
					erros++;
					printf("ERRO: Variável '%s' não é uma matriz! LINHA DO ERRO: %d.\n", variavel, linha);
				} else if (indice_linha < ponteiro->proxima->item.dimensao.primeiro_indice || 
					indice_linha > ponteiro->proxima->item.dimensao.segundo_indice ||
					indice_coluna < ponteiro->proxima->item.dimensao.terceiro_indice ||
					indice_coluna > ponteiro->proxima->item.dimensao.quarto_indice) {
						erros++;
						printf("ERRO: Par ordenado inválido da matriz '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
				}
			}
		} else {
			erros++;
			printf("ERRO: Variável '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	} else {
		if(ponteiro->proxima->item.dimensao.quarto_indice == -1) {
			erros++;
			printf("ERRO: Variável '%s' não é uma matriz! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (indice_linha < ponteiro->proxima->item.dimensao.primeiro_indice || 
			indice_linha > ponteiro->proxima->item.dimensao.segundo_indice ||
			indice_coluna < ponteiro->proxima->item.dimensao.terceiro_indice ||
			indice_coluna > ponteiro->proxima->item.dimensao.quarto_indice) {
				erros++;
				printf("ERRO: Índices inválidos da matriz '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	}
}

void verificar_funcao(TipoVariavel variavel, char *param, int linha) {
	int tamanho = strlen(variavel) + 1;
	char chave[tamanho];
	strcpy(chave, variavel);
	strcat(chave, escopo);
	
	Ponteiro ponteiro = pesquisar(chave, tabela_hash);
	if (ponteiro == NULL) {
		erros++;
		printf("ERRO: '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
	} else {
		if (!strcmp(ponteiro->proxima->item.tipo, "sem")) {
			erros++;
			printf("ERRO: '%s' é um procedimento! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (!strcmp(ponteiro->proxima->item.parametros, "semparametros") && strcmp(param, "semparametros")) {
			erros++;
			printf("ERRO: A função '%s' não possui parâmetros! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (strcmp(ponteiro->proxima->item.parametros, param)) {
			erros++;
			printf("ERRO: Valores com tipos incompatíveis passados à função '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	}
}

void verificar_procedimento(TipoVariavel variavel, char *param, int linha) {
	char *chave = strdup(variavel);
	strcat(chave, escopo);

	Ponteiro ponteiro = pesquisar(chave, tabela_hash);
	if (ponteiro == NULL) {
		erros++;
		printf("ERRO: '%s' não foi declarada! LINHA DO ERRO: %d.\n", variavel, linha);
	} else {
		if (strcmp(ponteiro->proxima->item.tipo, "sem")) {
			erros++;
			printf("ERRO: '%s' é uma função! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (!strcmp(ponteiro->proxima->item.parametros, "semparametros") && strcmp(param, "semparametros")) {
			erros++;
			printf("ERRO: O procedimento '%s' não possui parâmetros! LINHA DO ERRO: %d.\n", variavel, linha);
		} else if (strcmp(ponteiro->proxima->item.parametros, param)) {
			erros++;
			printf("ERRO: Valores com tipos incompatíveis passados ao procedimento '%s'! LINHA DO ERRO: %d.\n", variavel, linha);
		}
	}
}

void verificar_indice(TipoPrimitivo tipo, int linha) {
	if (strcmp(tipo, "inteiro") != 0) {
		erros++;
		printf("ERRO: Índice de vetor deve ser do tipo INTEIRO! LINHA DO ERRO: %d.\n", linha);
	}
}

void verificar_var_para(TipoPrimitivo tipo, int linha) {
	if (strcmp(tipo, "inteiro") != 0) {
		erros++;
		printf("ERRO: Variável de controle de iteração deve ser do tipo INTEIRO! LINHA DO ERRO: %d.\n", linha);
	}
}

char* verificar_tipo(TipoVariavel variavel) {
	char *var = strdup(variavel);
	char *chave = strdup(variavel);
	strcat(chave, escopo);

	if (nome_funcao != NULL) {
		strcat(chave, nome_funcao);
	}

	Ponteiro ponteiro = pesquisar(chave, tabela_hash);

	if (ponteiro != NULL) {
		return ponteiro->proxima->item.tipo;
	} else {
		if (!strcmp(escopo, "local")) {
			strcat(var, "global");
			ponteiro = pesquisar(var, tabela_hash);

			if (ponteiro != NULL) {
				return ponteiro->proxima->item.tipo;
			} else {
				return "";
			}
		} else {
			return "";
		}
	}
}

char* calcular(char *expressao) {
	if (!strcmp(expressao, "logicoelogico")) {
		return "logico";
	} else if (!strcmp(expressao, "logicooulogico")) {
		return "logico";
	} else if (!strcmp(expressao, "logicoxoulogico")) {
		return "logico";
	} else if (!strcmp(expressao, "naologico")) {
		return "logico";
	} else if (!strcmp(expressao, "inteiro<inteiro")) {
		return "logico";
	} else if (!strcmp(expressao, "inteiro>inteiro")) {
		return "logico";
	} else if (!strcmp(expressao, "inteiro=inteiro")) {
		return "logico";
	} else if (!strcmp(expressao, "inteiro<>inteiro")) {
		return "logico";
	} else if (!strcmp(expressao, "inteiro<=inteiro")) {
		return "logico";
	} else if (!strcmp(expressao, "inteiro>=inteiro")) {
		return "logico";
	} else if (!strcmp(expressao, "real<real") ||
		!strcmp(expressao, "real<inteiro") ||
		!strcmp(expressao, "inteiro<real")) {
		return "logico";
	} else if (!strcmp(expressao, "real>real") ||
		!strcmp(expressao, "real>inteiro") ||
		!strcmp(expressao, "inteiro>real")) {
		return "logico";
	} else if (!strcmp(expressao, "real=real") ||
		!strcmp(expressao, "real=inteiro") ||
		!strcmp(expressao, "inteiro=real")) {
		return "logico";
	} else if (!strcmp(expressao, "real<>real") ||
		!strcmp(expressao, "real<>inteiro") ||
		!strcmp(expressao, "inteiro<>real")) {
		return "logico";
	} else if (!strcmp(expressao, "real<=real") ||
		!strcmp(expressao, "real<=inteiro") ||
		!strcmp(expressao, "inteiro<=real")) {
		return "logico";
	} else if (!strcmp(expressao, "real>=real") ||
		!strcmp(expressao, "real>=inteiro") ||
		!strcmp(expressao, "inteiro>=real")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere<caractere")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere>caractere")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere=caractere")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere<>caractere")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere<=caractere")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere>=caractere")) {
		return "logico";
	} else if (!strcmp(expressao, "logico<logico")) {
		return "logico";
	} else if (!strcmp(expressao, "logico>logico")) {
		return "logico";
	} else if (!strcmp(expressao, "logico=logico")) {
		return "logico";
	} else if (!strcmp(expressao, "logico<>logico")) {
		return "logico";
	} else if (!strcmp(expressao, "logico<=logico")) {
		return "logico";
	} else if (!strcmp(expressao, "logico>=logico")) {
		return "logico";
	} else if (!strcmp(expressao, "caractere+caractere")) {
		return "caractere";
	} else if (!strcmp(expressao, "inteiro+inteiro")) {
		return "inteiro";
	} else if (!strcmp(expressao, "inteiro-inteiro")) {
		return "inteiro";
	} else if (!strcmp(expressao, "inteiromodinteiro")) {
		return "inteiro";
	} else if (!strcmp(expressao, "inteiro/inteiro")) {
		return "real";
	} else if (!strcmp(expressao, "inteiro*inteiro")) {
		return "inteiro";
	} else if (!strcmp(expressao, "inteiro^inteiro")) {
		return "inteiro";
	} else if (!strcmp(expressao, "raizqinteiro") ||
		!strcmp(expressao, "raizqreal")) {
		return "real";
	} else if (!strcmp(expressao, "real+real") ||
	    !strcmp(expressao, "real+inteiro") ||
	    !strcmp(expressao, "inteiro+real")) {
		return "real";
	} else if (!strcmp(expressao, "real-real") ||
	    !strcmp(expressao, "real-inteiro") ||
	    !strcmp(expressao, "inteiro-real")) {
		return "real";
	} else if (!strcmp(expressao, "real/real") ||
	    !strcmp(expressao, "real/inteiro") ||
	    !strcmp(expressao, "inteiro/real")) {
		return "real";
	} else if (!strcmp(expressao, "real*real") ||
	    !strcmp(expressao, "real*inteiro") ||
	    !strcmp(expressao, "inteiro*real")) {
		return "real";
	} else if (!strcmp(expressao, "real^real") ||
	    !strcmp(expressao, "real^inteiro") ||
	    !strcmp(expressao, "inteiro^real")) {
		return "real";
	} else {
		return "incompativel";
	}
}

void inserir_comando(char *codigo_c) {
	if (!enfileirar(fila, fila->fim, codigo_c)) {
		erros++;
		printf("Erro na tradução de código!\n");
	}

	memset(&comando, 0, sizeof(comando));
	memset(&auxiliar, 0, sizeof(auxiliar));
}

char* obter_tipo(TipoVariavel variavel) {
	char tipo[10];
	strcpy(tipo, verificar_tipo(variavel));
	
	if (strcmp(tipo, "")) {
		if (!strcmp(tipo, "inteiro") || !strcmp(tipo, "logico")) {
			return "%d";
		} else if (!strcmp(tipo, "real")) {
			return "%f";
		} else if (!strcmp(tipo, "caractere")) {
			return "%s";
		}
	} else {
		erros++;
		return "";
	}
}

char* obter_formato_tipo(char *tipo) {
	if (strcmp(tipo, "")) {
		if (!strcmp(tipo, "inteiro") || !strcmp(tipo, "logico")) {
			return "%d";
		} else if (!strcmp(tipo, "real")) {
			return "%f";
		} else if (!strcmp(tipo, "caractere")) {
			return "%s";
		}
	} else {
		erros++;
		return "";
	}
}

void verificar_atribuicao(char *destino, char *origem) {
	if (strcmp(destino, "") && strcmp(origem, "")) {
		if (strcmp(destino, origem)) {
			if (strcmp(destino, "real") || strcmp(origem, "inteiro")) {
				erros++;
				printf("ERRO: Tipos incompatíveis no comando de atribuição! LINHA DO ERRO: %d.\n", inicio_linha);
			}
		}
	}
}

void verificar_condicional(char *origem) {
	if (strcmp(origem, "")) {
		if (strcmp("logico", origem)) {
			erros++;
			printf("ERRO: Expressão condicional não resulta no tipo lógico! LINHA DO ERRO: %d.\n", inicio_linha);
		}
	}
}

void verificar_limite(char *origem) {
	if (strcmp(origem, "")) {
		if (strcmp("inteiro", origem)) {
			erros++;
			printf("ERRO: O limite do comando PARA não é do tipo inteiro! LINHA DO ERRO: %d.\n", inicio_linha);
		}
	}
}

void verificar_passo(char *origem) {
	if (strcmp(origem, "")) {
		if (strcmp("inteiro", origem)) {
			erros++;
			printf("ERRO: O incremento do comando PARA não é do tipo inteiro! LINHA DO ERRO: %d.\n", inicio_linha);
		}
	}
}

void verificar_retorne(char *origem) {
	if (strcmp(tipo_retorno, "") && strcmp(origem, "")) {
		if (strcmp(tipo_retorno, origem)) {
			if (strcmp(tipo_retorno, "real") || strcmp(origem, "inteiro")) {
				erros++;
				printf("ERRO: Comando RETORNE contém expressão com tipo incompatível ao tipo de retorno da função! LINHA DO ERRO: %d.\n", inicio_linha);
			}
		}
	}

	memset(&tipo_retorno, 0, sizeof(tipo_retorno));
}

%}

%locations

%error-verbose

%token ENTER ALGORITMO VAR INICIO FIMALGORITMO
%token INTEIRO REAL CARACTERE LOGICO VETOR
%token LEIA ESCREVA SE ENTAO SENAO FIMSE
%token PARA DE ATE FACA PASSO FIMPARA REPITA
%token ENQUANTO FIMENQUANTO ESCOLHA CASO OUTROCASO
%token FIMESCOLHA FUNCAO FIMFUNCAO RETORNE NAO E OU MOD XOU
%token VERDADEIRO FALSO RAIZQ PROCEDIMENTO FIMPROCEDIMENTO
%token STRING NUMERO_INTEIRO NUMERO_REAL VARIAVEL
%token ATRIBUICAO MAIS MENOS MULTIPLICACAO DIVISAO
%token POTENCIA IGUAL MENOR_IGUAL
%token MAIOR_IGUAL DIFERENTE MAIOR MENOR DOIS_PONTOS
%token PARENTESE_E PARENTESE_D COLCHETE_E COLCHETE_D
%token INTERVALO VIRGULA ERRO

%left OU
%left E
%left XOU
%left NAO
%left MAIOR MENOR IGUAL DIFERENTE MAIOR_IGUAL MENOR_IGUAL
%left MAIS MENOS
%left MULTIPLICACAO DIVISAO MOD
%left NEG
%right POTENCIA RAIZQ

%start Entrada

%%

Entrada:
	Espaco Algoritmo
	| Algoritmo
	| error { yyclearin; erros++;}
;

Espaco:
	ENTER
	| Espaco ENTER
;

Algoritmo:
	Titulo Corpo_Algoritmo
;

Titulo:
	Token_Algoritmo Nome_Algoritmo Fim_Comando
;

Token_Algoritmo:
	ALGORITMO
	{
		alg_correto = 1;
		inserir_comando("#include <stdio.h>"); 
		inserir_comando("#include <stdlib.h>"); 
		inserir_comando("#include <string.h>");
		inserir_comando("#include <math.h>");
		inserir_comando("\ntypedef char String[256];");
		inserir_comando("\nchar* concat(char *s1, char *s2) {");
		inserir_comando("char *result = malloc(strlen(s1)+strlen(s2)+1);");
		inserir_comando("strcpy(result, s1);");
		inserir_comando("strcat(result, s2);");
		inserir_comando("return result;\n}");
	}
	| error
	{
		if (!alg_correto) {
			yyclearin;
			erros++;
			yyerror("Ausência da palavra reservada 'ALGORITMO'", yylineno, yytext);
		}
	}

;

Nome_Algoritmo:
	STRING
	{
		nome_correto = 1;
		$1 = strdup(yytext);
		strcpy(nome_alg,$1);
		
		int i;
		int tamanho = strlen(nome_alg) - 1; 

		for (i = 1; i < tamanho; i++) {
			arquivo[i - 1] = nome_alg[i];
		}
		printf("\nNome: %s\n", arquivo);
		strcat(arquivo,".c");
	}
	| error
	{
		if (!nome_correto) {
			yyclearin;
			erros++;
			yyerror("Nome do algoritmo escrito incorretamente", yylineno, yytext);
		}
	}
;

Corpo_Algoritmo:
	Bloco_Comandos
	| Procedimentos_e_Funcoes Bloco_Comandos
	| Var Declaracoes Bloco_Comandos
	| Var Declaracoes Procedimentos_e_Funcoes Bloco_Comandos
;

Var:
	VAR Fim_Comando { strcpy(escopo, "global"); }
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'VAR'", yylineno, yytext); }
;

Var_Funcao:
	VAR Fim_Comando { strcpy(escopo, "local"); }
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'VAR'", yylineno, yytext); }
;

Declaracoes:
	Declaracao
	| Declaracoes Declaracao
;

Declaracao:
	Variavel Token_Dois_Pontos Tipo_Variavel Fim_Comando
	{
		strcpy(elemento.variavel, $1);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, $3);
		elemento.dimensao.primeiro_indice = primeiro_indice;
		elemento.dimensao.segundo_indice = segundo_indice;
		elemento.dimensao.terceiro_indice = terceiro_indice;
		elemento.dimensao.quarto_indice = quarto_indice;
		inserir_variavel(elemento, yylineno);
		
		if (!strcmp(comando, "char ")) {
			strcpy(comando, "String ");
		}

		int tamanho = strlen(comando) + strlen($1) + 2;
		char declaracao[tamanho];
		strcpy(declaracao, comando);
		strcat(declaracao, $1);
		strcat(declaracao, ";");
		inserir_comando(declaracao);
	} 
	| Variavel Token_Dois_Pontos VETOR COLCHETE_E Dimensoes COLCHETE_D DE Tipo_Variavel Fim_Comando
	{
		strcpy(elemento.variavel, $1);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, $8);
		elemento.dimensao.primeiro_indice = primeiro_indice;
		elemento.dimensao.segundo_indice = segundo_indice;
		elemento.dimensao.terceiro_indice = terceiro_indice;
		elemento.dimensao.quarto_indice = quarto_indice;

		if (!strcmp(comando, "char ")) {
			strcpy(comando, "String ");
		}

		int tamanho = strlen(comando) + strlen($1) + 10;
		char declaracao[tamanho];
		strcpy(declaracao, comando);
		strcat(declaracao, $1);
		strcat(declaracao, "[");
		char aux[3];
		sprintf(aux, "%d", segundo_indice + 1);
		strcat(declaracao, aux);
		strcat(declaracao, "]");
		
		if (quarto_indice != -1) {
			strcat(declaracao, "[");

			sprintf(aux, "%d", quarto_indice + 1);
			strcat(declaracao, aux);

			strcat(declaracao, "]");
		}
		
		strcat(declaracao, ";");
		inserir_variavel(elemento, yylineno);
		inserir_comando(declaracao);
	}
	| error { yyclearin; erros++; yyerror("Declaração incorreta de variável", yylineno, yytext);}
;

Token_Dois_Pontos:
	DOIS_PONTOS
	| error { yyclearin; erros++; yyerror("Ausência de ':'", yylineno, yytext);}
;

Tipo_Variavel:
	LOGICO { $$ = strdup(yytext); strcpy(comando, "int "); }
	| CARACTERE { $$ = strdup(yytext); strcpy(comando, "char "); }
	| REAL { $$ = strdup(yytext); strcpy(comando, "float "); }
	| INTEIRO { $$ = strdup(yytext); strcpy(comando, "int "); }
	| error { $$ = strdup(""); strcpy(comando, ""); yyclearin; erros++; yyerror("Tipo inválido de variável", yylineno, yytext);}
;

Dimensoes:
	Numero_Inteiro INTERVALO Numero_Inteiro
	{
		primeiro_indice = atoi($1);

		if (primeiro_indice != 0) {
			erros++;
			printf("ERRO: O vetor deve iniciar com o índice igual a 0 (ZERO)! LINHA DO ERRO: %d.\n", yylineno);
		} else {
			segundo_indice = atoi($3);			
		}
	}
	| Numero_Inteiro INTERVALO Numero_Inteiro VIRGULA Numero_Inteiro INTERVALO Numero_Inteiro
	{
		primeiro_indice = atoi($1);
		terceiro_indice = atoi($5);
		
		if (primeiro_indice != 0) {
			erros++;
			printf("ERRO: A matriz deve iniciar com índice de linha igual a 0 (ZERO)! LINHA DO ERRO: %d.\n", yylineno);
		}
		
		if (terceiro_indice != 0) {
			erros++;
			printf("ERRO: A matriz deve iniciar com índice de coluna igual a 0 (ZERO)! LINHA DO ERRO: %d.\n", yylineno);
		} else {
			segundo_indice = atoi($3);
			quarto_indice = atoi($7);
		}
	}
	| error { yyclearin; erros++; yyerror("Dimensão inválida", yylineno, yytext);}
;

Numero_Inteiro:
	NUMERO_INTEIRO { $$ = strdup(yytext); }
;

/* Sintaxe de procedimentos e funções */

Procedimentos_e_Funcoes:
	Declaracao_Procedimento
	| Declaracao_Funcao
	| Procedimentos_e_Funcoes Declaracao_Procedimento
	| Procedimentos_e_Funcoes Declaracao_Funcao
;

/* Procedimento */
Declaracao_Procedimento:
	Assinatura_Procedimento Inicio Fim_Procedimento
	| Assinatura_Procedimento Var_Funcao Declaracoes Inicio Fim_Procedimento
	| Assinatura_Procedimento Inicio Comandos Fim_Procedimento
	| Assinatura_Procedimento Var_Funcao Declaracoes Inicio Comandos Fim_Procedimento
	
;

Assinatura_Procedimento:
	PROCEDIMENTO Variavel Parentese_E Parentese_D Fim_Comando
	{
		strcpy(nome_funcao, $2);
		strcpy(elemento.variavel, $2);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, "sem");
		strcpy(elemento.parametros, "semparametros");
		inserir_funcao(elemento, yylineno);

		int tamanho = strlen($2) + 12;
		char assinatura[tamanho];
		strcpy(assinatura, "\nvoid ");
		strcat(assinatura, $2);
		strcat(assinatura, "() {");
		inserir_comando(assinatura);
	}
	| PROCEDIMENTO Variavel Parentese_E { strcpy(escopo, "local"); strcpy(nome_funcao, $2); } 
	  Declaracao_Parametros Parentese_D { strcpy(escopo,"global"); } Fim_Comando
	{
		strcpy(elemento.variavel, $2);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, "sem");
		strcpy(elemento.parametros, parametros);
		inserir_funcao(elemento, yylineno);

		int tamanho = strlen($2) + strlen($5) + 12;
		char assinatura[tamanho];
		strcpy(assinatura, "\nvoid ");
		strcat(assinatura, $2);
		strcat(assinatura, "(");
		strcat(assinatura, $5);
		strcat(assinatura, ") {");
		inserir_comando(assinatura);
	}
;

Fim_Procedimento:
	FIMPROCEDIMENTO Fim_Comando
	{
		strcpy(escopo, "global");
		memset(&parametros, 0, sizeof(parametros));
		memset(&nome_funcao, 0, sizeof(nome_funcao));
		inserir_comando("}");
	}
	| error { erros++; yyerror("Ausência da palavra reserva 'FIMPROCEDIMENTO'", yylineno, yytext); }
;
/* Fim Procedimento */


/* Função */

Declaracao_Funcao:
	Assinatura_Funcao Inicio { retorne_habilitado = 1; } Fim_Funcao
	| Assinatura_Funcao Var_Funcao Declaracoes Inicio { retorne_habilitado = 1; } Fim_Funcao
	| Assinatura_Funcao Inicio { retorne_habilitado = 1; } Comandos Fim_Funcao
	| Assinatura_Funcao Var_Funcao Declaracoes Inicio { retorne_habilitado = 1; } Comandos Fim_Funcao
;

Assinatura_Funcao:
	FUNCAO Variavel Parentese_E Parentese_D Token_Dois_Pontos Tipo_Variavel Fim_Comando
	{
		strcpy(nome_funcao, $2);
		strcpy(elemento.variavel, $2);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, $6);
		strcpy(elemento.parametros, "semparametros");
		inserir_funcao(elemento, yylineno);

		strcpy(tipo_retorno, $6);
		
		if (strcmp(comando, "char ") == 0) {
			strcpy(comando, "char* ");
		}

		int tamanho = strlen(comando) + strlen($2) + 7;
		char assinatura[tamanho];
		strcpy(assinatura, "\n");
		strcat(assinatura, comando);
		strcat(assinatura, $2);
		strcat(assinatura, "() {");
		inserir_comando(assinatura);
	}
	| FUNCAO Variavel Parentese_E { strcpy(escopo, "local"); strcpy(nome_funcao, $2); }
	  Declaracao_Parametros Parentese_D { strcpy(escopo, "global"); } Token_Dois_Pontos Tipo_Variavel Fim_Comando
	{
		strcpy(elemento.variavel, $2);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, $9);
		strcpy(elemento.parametros, parametros);
		inserir_funcao(elemento, yylineno);

		strcpy(tipo_retorno, $9);

		if (strcmp(comando, "char ") == 0) {
			strcpy(comando, "char* ");
		}

		int tamanho = strlen(comando) + strlen($2) + strlen($5) + 7;
		char assinatura[tamanho];
		strcpy(assinatura, "\n");
		strcat(assinatura, comando);
		strcat(assinatura, $2);
		strcat(assinatura, "(");
		strcat(assinatura, $5);
		strcat(assinatura, ") {");
		inserir_comando(assinatura);
	}
;

Fim_Funcao:
	FIMFUNCAO Fim_Comando
	{
		strcpy(escopo, "global");
		retorne_habilitado = 0;
		memset(&parametros, 0, sizeof(parametros));
		memset(&nome_funcao, 0, sizeof(nome_funcao));
		inserir_comando("}");
	}
	| error { erros++; yyerror("Ausência da palavra reserva 'FIMFUNCAO'", yylineno, yytext); }
;

/* Fim Função*/

Inicio:
	INICIO Fim_Comando
	{
		strcpy(escopo, "local");
	}
	| error { erros++; yyerror("Ausência da palavra reservada 'INICIO'", yylineno, yytext);}
;

Parentese_E:
	PARENTESE_E
	| error { yyclearin; erros++; yyerror("Ausência de '('", yylineno, yytext); }
;

Parentese_D:
	PARENTESE_D
	| error { yyclearin; erros++; yyerror("Ausência de ')'", yylineno, yytext); }
;

Declaracao_Parametros:
	Declaracao_Parametro
	| Declaracao_Parametros Token_Virgula Declaracao_Parametro
	{
		strcpy($$, $1);
		strcat($$, ", ");
		strcat($$, $3);
	}
;

Token_Virgula:
	VIRGULA
	| error { erros++; yyerror("Ausência de ','", yylineno, yytext); }
;

Declaracao_Parametro:
	Variavel Token_Dois_Pontos Tipo_Variavel
	{
		strcpy(elemento.variavel, $1);
		strcpy(elemento.escopo, escopo);
		strcpy(elemento.tipo, $3);
		elemento.dimensao.primeiro_indice = primeiro_indice;
		elemento.dimensao.segundo_indice = segundo_indice;
		elemento.dimensao.terceiro_indice = terceiro_indice;
		elemento.dimensao.quarto_indice = quarto_indice;

		inserir_variavel(elemento, yylineno);

		if (parametros == NULL) {
			strcpy(parametros, $3);
		} else {
			strcat(parametros, $3);
		}

		if (!strcmp(comando, "char ")) {
			strcpy(comando, "String ");
		}

		int tamanho = strlen(comando) + strlen($1);
		char declaracao_parametro[tamanho];
		strcpy(declaracao_parametro, comando);
		strcat(declaracao_parametro, $1);
		strcpy($$, declaracao_parametro);
	}
;

/* Fim da sintaxe de procedimentos e funções */

Bloco_Comandos:
	Inicio_Algoritmo Fim_Algoritmo
	| Inicio_Algoritmo Comandos Fim_Algoritmo
;

Inicio_Algoritmo:
	INICIO Fim_Comando
	{
		inicio_correto = 1;
		strcpy(escopo, "global");
		inserir_comando("\nvoid main() {");
	}
	| error
	{
		if (!inicio_correto) {
			erros++;
			yyerror("Ausência da palavra reservada 'INICIO'", yylineno, yytext);
		}
	}
;

Comandos:
	Comando
	| Comandos Comando
;

Comando:
	Escreva Fim_Comando
	| Atribuicao Fim_Comando
	| Leia Fim_Comando
	| Se Fim_Comando
	| Escolha Fim_Comando
	| Para Fim_Comando
	| Enquanto Fim_Comando
	| Repita Fim_Comando
	| Retorne Fim_Comando
	| Procedimento Fim_Comando
;

Escreva:
	Token_Escreva PARENTESE_E PARENTESE_D
	{
		if (!strcmp($1, "escreval")) {
			inserir_comando("printf(\"\\n\");");
		} else {
			inserir_comando("printf(\" \");");
		}
	}
	| Token_Escreva PARENTESE_E Impressao PARENTESE_D
	{
		if (!strcmp($1, "escreval")) {
			strcat(auxiliar, "\"\\n\"");
		}

		int tamanho = strlen($1) + strlen($3) + strlen(auxiliar) + 12;
		char escreva[tamanho];
		strcpy(escreva, "printf(");
		strcat(escreva, auxiliar);
		strcat(escreva, ", ");
		strcat(escreva, $3);
		strcat(escreva, ");");
		inserir_comando(escreva);
	}
;

Token_Escreva:
	ESCREVA { $$ = strdup(yytext); }
;

Impressao:
	Expressao
	{
		int tamanho_expressao = strlen($1) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $1);
		int i, j = 0, marcador = 0;

		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		char tipo_c[3];
		strcpy(tipo_c, obter_formato_tipo(tipo_expressao));

		if (auxiliar == NULL) {
			strcpy(auxiliar, "\"");
			strcat(auxiliar, tipo_c);
			strcat(auxiliar, "\"");
		} else {
			strcat(auxiliar, "\"");
			strcat(auxiliar, tipo_c);
			strcat(auxiliar, "\"");
		}
		
		strcpy($$, expressao_original);
	}
	| Impressao VIRGULA Expressao
	{
		int tamanho_expressao = strlen($3) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $3);
		int i, j = 0, marcador = 0;

		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		char tipo_c[3];
		strcpy(tipo_c, obter_formato_tipo(tipo_expressao));

		if (auxiliar == NULL) {
			strcpy(auxiliar, "\"");
			strcat(auxiliar, tipo_c);
			strcat(auxiliar, "\"");
		} else {
			strcat(auxiliar, "\"");
			strcat(auxiliar, tipo_c);
			strcat(auxiliar, "\"");
		}

		strcpy($$, $1);
		strcat($$, ", ");
		strcat($$, expressao_original);
	}
	| error { yyclearin; erros++; yyerror("Sintaxe incorreta da saída de dados", yylineno, yytext); }
;

Atribuicao: 
	Variavel_Atribuicao Token_Atribuicao Expressao
	{
		int tamanho_expressao = strlen($3) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $3);

		char tipo_var[10];
		strcpy(tipo_var, verificar_tipo($1));

		int i, j = 0, marcador = 0;
		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		verificar_atribuicao(tipo_var, tipo_expressao);
		
		if (!strcmp(tipo_var, "caractere") && !strcmp(tipo_expressao, "caractere")) {
			int tamanho = strlen($1) + strlen(expressao_original) + 12;
			char atribuicao[tamanho];
			strcpy(atribuicao, "strcpy(");
			strcat(atribuicao, $1);
			strcat(atribuicao, ", ");
			strcat(atribuicao, expressao_original);
			strcat(atribuicao, ");");
			inserir_comando(atribuicao);
		} else {
			int tamanho = strlen($1) + strlen(expressao_original) + 5;
			char atribuicao[tamanho];
			strcpy(atribuicao, $1);
			strcat(atribuicao, " = ");
			strcat(atribuicao, expressao_original);
			strcat(atribuicao, ";");
			inserir_comando(atribuicao);

		}
	}
;

Token_Atribuicao:
	ATRIBUICAO
	| error { yyclearin; erros++; yyerror("Ausência de '<-'", yylineno, yytext); }
;

Variavel_Atribuicao:
	Variavel
	{
		verificar_variavel($1, yylineno);
		inicio_linha = yylineno;
	}
	| Vetor_Atribuicao
	{
		inicio_linha = yylineno;
	}
;

Variavel:
	VARIAVEL { $$ = strdup(yytext); } 
;

Vetor_Atribuicao:
	Variavel COLCHETE_E Indice_Vetor COLCHETE_D
	{
		int i = 0;
		if (verificacao_indice1) {
			i = atoi($3);
		} else {
			verificacao_indice1 = 1;
		}

		verificar_vetor($1, i, yylineno);
	}
	| Variavel COLCHETE_E Indice_Vetor VIRGULA Indice_Vetor COLCHETE_D
	{
		int i = 0;
		int j = 0;

		if (verificacao_indice1) {
			i = atoi($3);
		} else {
			verificacao_indice1 = 1;
		}

		if (verificacao_indice2) {
			j = atoi($5);
		} else {
			verificacao_indice2 = 1;
		}

		verificar_matriz($1, i, j, yylineno);	
	}
;

Expressao:
	Expressao_Aritmetica
	| Expressao_Relacional
	| Expressao_Logica
	| error
	{
		$$ = strdup("");
		yyclearin;
		erros++;
		yyerror("Sintaxe incorreta", yylineno, yytext);
	}
; 

Expressao_Logica:
	Expressao_Relacional
	| Expressao_Logica OU Expressao_Logica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "ou");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "||");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));	
	}
	| Expressao_Logica E Expressao_Logica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "e");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "&&");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));	
	}
	| Expressao_Logica XOU Expressao_Logica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "xou");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "^");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));	
	}
	| NAO Expressao_Logica
	{
		int tamanho = strlen($2) + 1;
		char copia[tamanho];
		strcpy(copia, $2);
		char tipo[10];
		char valor[tamanho];
		int i, j = 0;
		int marcador = 0;
		memset(&valor, 0, sizeof(valor));

		for (i = 0; i < tamanho; i++) {
			if (marcador) {
				tipo[j] = copia[i];
				j++;
			} else {
				if (copia[i] != '$') {
					valor[i] = copia[i];
				} else {
					marcador = 1;
				}
			}
		}

		char expressao_completa[14];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, "nao");
		strcat(expressao_completa, tipo);
		
		$$ = strdup("!");
		strcat($$, valor);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| PARENTESE_E Expressao_Logica PARENTESE_D
	{
		int tamanho = strlen($2) + 1;
		char copia[tamanho];
		strcpy(copia, $2);
		char nova_expressao[tamanho + 2];
		memset(&nova_expressao, 0, sizeof(nova_expressao));
		int i, j = 1, coloquei = 0;

		nova_expressao[0] = '(';
		for (i = 0; i < tamanho; i++) {
			if (copia[i] != '$') {
				nova_expressao[j] = copia[i];
				j++;
			} else {
				nova_expressao[j] = ')';
				j++;
				nova_expressao[j] = copia[i];
				j++;
			}
		}

		$$ = strdup(nova_expressao);
	}
;

Expressao_Relacional:
	Expressao_Aritmetica
	| Falso
	{
		strcat($$, "$logico");
	}
	| Verdadeiro
	{
		strcat($$, "$logico");
	}
	| Expressao_Relacional MENOR Expressao_Relacional
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "<");
		strcat(expressao_completa, tipo2);

		if (!strcmp(tipo1, "caractere") && !strcmp(tipo2, "caractere")) {
			$$ = strdup("strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") < 0$");
			strcat($$, calcular(expressao_completa));
		} else {
			strcpy($$, valor1);
			strcat($$, "<");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));	
		}
	}
	| Expressao_Relacional MAIOR Expressao_Relacional
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, ">");
		strcat(expressao_completa, tipo2);

		if (!strcmp(tipo1, "caractere") && !strcmp(tipo2, "caractere")) {
			$$ = strdup("strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") > 0$");
			strcat($$, calcular(expressao_completa));
		} else {
			strcpy($$, valor1);
			strcat($$, ">");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));	
		}
	}
	| Expressao_Relacional IGUAL Expressao_Relacional
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "=");
		strcat(expressao_completa, tipo2);

		if (!strcmp(tipo1, "caractere") && !strcmp(tipo2, "caractere")) {
			int tamanho_resultado = strlen(valor1) + strlen(valor2) + 27;
			char resultado[tamanho_resultado];
			strcpy(resultado, "strcmp(");
			strcat(resultado, valor1);
			strcat(resultado, ", ");
			strcat(resultado, valor2);
			strcat(resultado, ") == 0$");
			strcat(resultado, calcular(expressao_completa));
			strcpy($$, resultado);
		} else {
			strcpy($$, valor1);
			strcat($$, "==");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));	
		}
	}
	| Expressao_Relacional DIFERENTE Expressao_Relacional
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "<>");
		strcat(expressao_completa, tipo2);

		if (!strcmp(tipo1, "caractere") && !strcmp(tipo2, "caractere")) {
			$$ = strdup("strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") != 0$");
			strcat($$, calcular(expressao_completa));
		} else {
			strcpy($$, valor1);
			strcat($$, "!=");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));	
		}
	}
	| Expressao_Relacional MENOR_IGUAL Expressao_Relacional
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "<=");
		strcat(expressao_completa, tipo2);

		if (!strcmp(tipo1, "caractere") && !strcmp(tipo2, "caractere")) {
			$$ = strdup("(strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") < 0 || strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") == 0)$");
			strcat($$, calcular(expressao_completa));
		} else {
			strcpy($$, valor1);
			strcat($$, "<=");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));	
		}
	}
	| Expressao_Relacional MAIOR_IGUAL Expressao_Relacional
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, ">=");
		strcat(expressao_completa, tipo2);

		if (!strcmp(tipo1, "caractere") && !strcmp(tipo2, "caractere")) {
			$$ = strdup("(strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") > 0 || strcmp(");
			strcat($$, valor1);
			strcat($$, ", ");
			strcat($$, valor2);
			strcat($$, ") == 0)$");
			strcat($$, calcular(expressao_completa));
		} else {
			strcpy($$, valor1);
			strcat($$, ">=");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));	
		}
	}
	| PARENTESE_E Expressao_Relacional PARENTESE_D
	{
		int tamanho = strlen($2) + 1;
		char copia[tamanho];
		strcpy(copia, $2);
		char nova_expressao[tamanho + 2];
		memset(&nova_expressao, 0, sizeof(nova_expressao));
		int i, j = 1, coloquei = 0;

		nova_expressao[0] = '(';
		for (i = 0; i < tamanho; i++) {
			if (copia[i] != '$') {
				nova_expressao[j] = copia[i];
				j++;
			} else {
				nova_expressao[j] = ')';
				j++;
				nova_expressao[j] = copia[i];
				j++;
			}
		}

		$$ = strdup(nova_expressao);
	}
;

Expressao_Aritmetica:
	Variavel 
	{
		verificar_variavel($1, yylineno);
		int tamanho = strlen($1) + 1;
		char copia[tamanho];
		strcpy(copia, $1);
		strcpy($$, copia);
		strcat($$, "$");
		strcat($$, verificar_tipo(copia));
	}
	| Funcao
	| Vetor
	{
		memset(&parametros, 0, sizeof(parametros));
	}
	| Numero_Inteiro
	{
		strcat($$, "$inteiro");
	}
	| Numero_Real
	{
		strcat($$, "$real");
	}
	| String
	{
		strcat($$, "$caractere");
	}
	| Expressao_Aritmetica MENOS Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "-");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "-");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));	
	}
	| Expressao_Aritmetica MAIS Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0, string = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (i == 0 && copia1[i] == '"') {
				string = 1;
			}

			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			}

			if (!marcador && copia2[i] != '$') {
				valor2[i] = copia2[i];
			} else {
				marcador = 1;
			}
		}

		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "+");
		strcat(expressao_completa, tipo2);

		if (!strcmp(calcular(expressao_completa), "caractere")) {
			char comando_expressao[128];
			if (string) {
				strcpy(comando_expressao, "concat(strdup(");
				strcat(comando_expressao, valor1);
				strcat(comando_expressao, "), ");
				strcat(comando_expressao, valor2);
				strcat(comando_expressao, ")$");
				strcat(comando_expressao, calcular(expressao_completa));
				strcpy($$, comando_expressao);
			} else {
				strcpy(comando_expressao, "concat(");
				strcat(comando_expressao, valor1);
				strcat(comando_expressao, ", ");
				strcat(comando_expressao, valor2);
				strcat(comando_expressao, ")$");
				strcat(comando_expressao, calcular(expressao_completa));
				strcpy($$, comando_expressao);
			} 
			
		} else {
			strcpy($$, valor1);
			strcat($$, "+");
			strcat($$, valor2);
			strcat($$, "$");
			strcat($$, calcular(expressao_completa));
		}
	}
	| Expressao_Aritmetica MOD Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "mod");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "%");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));	
	}
	| Expressao_Aritmetica DIVISAO Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "/");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "/");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| Expressao_Aritmetica MULTIPLICACAO Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "*");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "*");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| Expressao_Aritmetica POTENCIA Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "^");
		strcat(expressao_completa, tipo2);

		strcpy($$, "pow(");
		strcat($$, valor1);
		strcat($$, ", ");
		strcat($$, valor2);
		strcat($$, ")");
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| MENOS Expressao_Aritmetica %prec NEG
	{
		int tamanho1 = strlen($2) + 2;
		char copia1[tamanho1];
		strcpy(copia1, $2);
		
		$$ = strdup("-");
		strcat($$, copia1);
	}
	| RAIZQ PARENTESE_E Expressao_Aritmetica PARENTESE_D
	{
		int tamanho = strlen($3) + 1;
		char copia[tamanho];
		strcpy(copia, $3);
		char tipo[10];
		char valor[tamanho];
		int i, j = 0;
		int marcador = 0;
		memset(&valor, 0, sizeof(valor));

		for (i = 0; i < tamanho; i++) {
			if (marcador) {
				tipo[j] = copia[i];
				j++;
			} else {
				if (copia[i] != '$') {
					valor[i] = copia[i];
				} else {
					marcador = 1;
				}
			}
		}

		char expressao_completa[16];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, "raizq");
		strcat(expressao_completa, tipo);

		$$ = strdup("sqrt(");
		strcat($$, valor);
		strcat($$, ")");
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| PARENTESE_E Expressao_Aritmetica PARENTESE_D
	{
		int tamanho = strlen($2) + 1;
		char copia[tamanho];
		strcpy(copia, $2);
		char nova_expressao[tamanho + 2];
		memset(&nova_expressao, 0, sizeof(nova_expressao));
		int i, j = 1, coloquei = 0;

		nova_expressao[0] = '(';
		for (i = 0; i < tamanho; i++) {
			if (copia[i] != '$') {
				nova_expressao[j] = copia[i];
				j++;
			} else {
				nova_expressao[j] = ')';
				j++;
				nova_expressao[j] = copia[i];
				j++;
			}
		}

		$$ = strdup(nova_expressao);
	}
;

Numero_Real:
	NUMERO_REAL { $$ = strdup(yytext); }
;

String:
	STRING { $$ = strdup(yytext); }
;

Vetor:
	Variavel COLCHETE_E Indice_Vetor COLCHETE_D
	{
		int i = 0;
		if (verificacao_indice1) {
			i = atoi($3);
		} else {
			verificacao_indice1 = 1;
		}

		verificar_vetor($1, i, yylineno);
		char tipo[10];
		strcpy(tipo, verificar_tipo($1));

		if (parametros == NULL) {
			strcpy(parametros, tipo);
		} else {
			strcat(parametros, tipo);
		}

		strcpy($$, $1);
		strcat($$, "[");
		strcat($$, $3);
		strcat($$, "]");
		strcat($$, "$");
		strcat($$, tipo);
	}
	| Variavel COLCHETE_E Indice_Vetor VIRGULA Indice_Vetor COLCHETE_D
	{
		int i = 0;
		int j = 0;

		if (verificacao_indice1) {
			i = atoi($3);
		} else {
			verificacao_indice1 = 1;
		}

		if (verificacao_indice2) {
			j = atoi($5);
		} else {
			verificacao_indice2 = 1;
		}

		verificar_matriz($1, i, j, yylineno);
		char tipo[10];
		strcpy(tipo, verificar_tipo($1));

		if (parametros == NULL) {
			strcpy(parametros, tipo);
		} else {
			strcat(parametros, tipo);
		}

		strcpy($$, $1);
		strcat($$, "[");
		strcat($$, $3);
		strcat($$, "]");
		strcat($$, "[");
		strcat($$, $5);
		strcat($$, "]");
		strcat($$, "$");
		strcat($$, tipo);
	}
;

Indice_Vetor:
	Indice
	| Indice Operacao_Aritmetica Indice
	{
		if (verificacao_indice1) {
			verificacao_indice1 = 0;
		}

		if (verificacao_indice2) {
			verificacao_indice2 = 0;
		}
		
		strcpy($$, $1);
		strcat($$, $2);
		strcat($$, $3);
	}
;

Indice:
	Variavel
	{
		verificar_variavel($1, yylineno);
		verificar_indice(verificar_tipo($1), yylineno);
	}
	| Numero_Inteiro
;

Operacao_Aritmetica:
	MENOS { $$ = strdup(yytext); }
	| MAIS { $$ = strdup(yytext); }
	| MULTIPLICACAO { $$ = strdup(yytext); }
;

Funcao:
	Variavel PARENTESE_E PARENTESE_D 
	{
		verificar_funcao($1, "semparametros", yylineno);
		char tipo[10];
		strcpy(tipo, verificar_tipo($1));

		strcpy($$, $1);
		strcat($$, "()$");
		strcat($$, tipo);
	}
	| Variavel PARENTESE_E Parametros PARENTESE_D
	{
		verificar_funcao($1, parametros, yylineno);
		char tipo[10];
		strcpy(tipo, verificar_tipo($1));

		strcpy($$, $1);
		strcat($$, "(");
		strcat($$, $3);
		strcat($$, ")$");
		strcat($$, tipo);

		memset(&parametros, 0, sizeof(parametros));
	}
;

Parametros:
	Parametro
	| Parametros VIRGULA Parametro
	{
		strcpy($$, $1);
		strcat($$, ", ");
		strcat($$, $3);
	}
;

Parametro:
	Variavel
	{
		verificar_variavel($1, yylineno);
		if (parametros == NULL) {
			strcpy(parametros, verificar_tipo($1));
		} else {
			strcat(parametros, verificar_tipo($1));
		}
	}
	| Vetor
	{
		int tamanho = strlen($1) + 1;
		char vetor[tamanho];
		strcpy(vetor, $1);
		char tipo[10];
		int i, j = 0, marcador = 0;

		char vetor_original[tamanho];
		memset(&vetor_original, 0, sizeof(vetor_original));
		memset(&tipo, 0, sizeof(tipo));

		for (i = 0; i < tamanho; i++) {
			if (marcador) {
				tipo[j] = vetor[i];
				j++;
			} else {
				if (vetor[i] != '$') {
					vetor_original[i] = vetor[i];
				} else {
					marcador = 1;
				}
			}
		}

		strcpy($$, vetor_original);

		if (parametros == NULL) {
			strcpy(parametros, tipo);
		} else {
			strcat(parametros, tipo);
		}
	}
	| String
	{
		if (parametros == NULL) {
			strcpy(parametros, "caractere");
		} else {
			strcat(parametros, "caractere");
		}
	}
	| Numero_Inteiro
	{
		if (parametros == NULL) {
			strcpy(parametros, "inteiro");
		} else {
			strcat(parametros, "inteiro");
		}
	}
	| Numero_Real
	{
		if (parametros == NULL) {
			strcpy(parametros, "real");
		} else {
			strcat(parametros, "real");
		}
	}
	| MENOS Numero_Inteiro %prec NEG
	{
		if (parametros == NULL) {
			strcpy(parametros, "inteiro");
		} else {
			strcat(parametros, "inteiro");
		}
	}
	| MENOS Numero_Real %prec NEG
	{
		if (parametros == NULL) {
			strcpy(parametros, "real");
		} else {
			strcat(parametros, "real");
		}
	}
	| Falso
	{
		if (parametros == NULL) {
			strcpy(parametros, "logico");
		} else {
			strcat(parametros, "logico");
		}
	}
	| Verdadeiro
	{
		if (parametros == NULL) {
			strcpy(parametros, "logico");
		} else {
			strcat(parametros, "logico");
		}
	}
;

Falso:
	FALSO { $$ = strdup("0"); }
;

Verdadeiro:
	VERDADEIRO { $$ = strdup("1"); }
;

Leia:
	Token_Leia PARENTESE_E Entrada_Dados PARENTESE_D
	{
		int tamanho = strlen(auxiliar) + strlen($3) + 11;
		char leia[tamanho];
		strcpy(leia, "scanf(");
		strcat(leia, auxiliar);
		strcat(leia, ", ");
		strcat(leia, $3);
		strcat(leia, ");");
		inserir_comando(leia);
	}
;

Entrada_Dados:
	Entrada_Dado
	| Entrada_Dados VIRGULA Entrada_Dado
	{
		strcpy($$, $1);
		strcat($$, ", ");
		strcat($$, $3);
	}	
;

Entrada_Dado:
	Variavel
	{
		verificar_variavel($1, yylineno);
		char tipo[3];
		strcpy(tipo, obter_tipo($1));

		if (auxiliar == NULL) {
			strcpy(auxiliar, "\"");
			
			if (strcmp(tipo, "%s")) {
				strcat(auxiliar, tipo);
			} else {
				strcat(auxiliar, "\\n%[^\\n]s");
			}

			strcat(auxiliar, "\"");
		} else {
			strcat(auxiliar, "\"");
			
			if (strcmp(tipo, "%s")) {
				strcat(auxiliar, tipo);
			} else {
				strcat(auxiliar, "\\n%[^\\n]s");
			}

			strcat(auxiliar, "\"");
		}

		if (strcmp(tipo, "%s")) {
			int tamanho = strlen($1) + 1;
			char var[tamanho];
			strcpy(var, $1);
			strcpy($$, "&");
			strcat($$, var);
		}
	}
	| Vetor
	{
		int tamanho = strlen($1) + 1;
		char vetor[tamanho];
		strcpy(vetor, $1);
		char tipo[10];
		int i, j = 0, marcador = 0;

		char vetor_original[tamanho];
		memset(&vetor_original, 0, sizeof(vetor_original));
		memset(&tipo, 0, sizeof(tipo));

		for (i = 0; i < tamanho; i++) {
			if (marcador) {
				tipo[j] = vetor[i];
				j++;
			} else {
				if (vetor[i] != '$') {
					vetor_original[i] = vetor[i];
				} else {
					marcador = 1;
				}
			}
		}

		char tipo_c[3];
		strcpy(tipo_c, obter_formato_tipo(tipo));

		if (auxiliar == NULL) {
			strcpy(auxiliar, "\"");
			
			if (strcmp(tipo_c, "%s")) {
				strcat(auxiliar, tipo_c);
			} else {
				strcat(auxiliar, "\\n%[^\\n]s");
			}

			strcat(auxiliar, "\"");
		} else {
			strcat(auxiliar, "\"");
			
			if (strcmp(tipo_c, "%s")) {
				strcat(auxiliar, tipo_c);
			} else {
				strcat(auxiliar, "\\n%[^\\n]s");
			}

			strcat(auxiliar, "\"");
		}
		
		if (strcmp(tipo_c, "%s")) {
			strcpy($$, "&");
			strcat($$, vetor_original);
		} else {
			strcpy($$, vetor_original);
		}
		
		memset(&parametros, 0, sizeof(parametros));
	}
;

Token_Leia:
	LEIA
;

Lista_Comandos:
	| Comandos
;

Se:
	Inicio_Se Lista_Comandos Token_Fim_Se
	| Inicio_Se Lista_Comandos Senao Lista_Comandos Token_Fim_Se
;

Inicio_Se:
	Token_Se Condicional Token_Entao Fim_Comando
	{
		int tamanho = strlen($2) + 8;
		char se[tamanho];
		strcpy(se, "\nif (");
		strcat(se, $2);
		strcat(se, ") {");
		inserir_comando(se);
	}
;

Token_Se:
	SE { inicio_linha = yylineno; }
;

Condicional:
	Expressao_Logica
	{
		if ($1 == NULL) {
			$1 = strdup("");
		}

		int tamanho_expressao = strlen($1) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $1);
		int i, j = 0, marcador = 0;

		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		verificar_condicional(tipo_expressao);
		strcpy($$, expressao_original);
	}
	| error { erros++; yyerror("Sintaxe incorreta da expressão lógica", yylineno, yytext); }
;

Senao:
	SENAO Fim_Comando
	{
		inserir_comando("} else {");
	}
;

Token_Entao:
	ENTAO
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'ENTAO'", yylineno, yytext); }
;

Token_Fim_Se:
	FIMSE
	{
		inserir_comando("}");
	}
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'FIMSE'", yylineno, yytext); }
;

Para:
	Inicio_Para Lista_Comandos Fim_Para
;

Inicio_Para:
	Token_Para Variavel Token_De Limite Token_Ate Limite Token_Faca Fim_Comando
	{
		verificar_variavel($2, inicio_linha);
		verificar_var_para(verificar_tipo($2), inicio_linha);

		int tamanho = strlen($2) + strlen($4) + strlen($6) + 22;
		char para[tamanho];
		strcpy(para, "\nfor (");
		strcat(para, $2);
		strcat(para, " = ");
		strcat(para, $4);
		strcat(para, "; ");
		strcat(para, $2);
		strcat(para, " <= ");
		strcat(para, $6);
		strcat(para, "; ");
		strcat(para, $2);
		strcat(para, "++) {");
		inserir_comando(para);
	}
	| Token_Para Variavel Token_De Limite Token_Ate Limite Token_Passo Passo Token_Faca Fim_Comando
	{
		verificar_variavel($2, inicio_linha);
		verificar_var_para(verificar_tipo($2), inicio_linha);

		int tamanho_passo = strlen($8) + 1;
		char passo[tamanho_passo];
		char novo_passo[tamanho_passo + 1];
		strcpy(passo, $8);

		int passo_negativo = 0;
		if (passo[0] != '-') {
			strcpy(novo_passo, "+");
			strcat(novo_passo, passo);
		} else {
			strcpy(novo_passo, passo);
			passo_negativo = 1;
		}

		
		int tamanho = strlen($2) + strlen($4) + strlen($6) + tamanho_passo + 23;
		char para[tamanho];
		strcpy(para, "\nfor (");
		strcat(para, $2);
		strcat(para, " = ");
		strcat(para, $4);
		strcat(para, "; ");
		strcat(para, $2);

		if (passo_negativo) {
			strcat(para, " >= ");
		} else {
			strcat(para, " <= ");
		}

		strcat(para, $6);
		strcat(para, "; ");
		strcat(para, $2);
		strcat(para, " = ");
		strcat(para, $2);
		strcat(para, novo_passo);
		strcat(para, ") {");
		inserir_comando(para);
	}
;

Token_Para:
	PARA { inicio_linha = yylineno; }
;

Token_De:
	DE
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'DE'", yylineno, yytext); }
;

Limite:
	Expressao_Limite
	{
		if ($1 == NULL) {
			$1 = strdup("");
		}

		int tamanho_expressao = strlen($1) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $1);
		int i, j = 0, marcador = 0;

		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		verificar_limite(tipo_expressao);
		strcpy($$, expressao_original);
	}
	| error { yyclearin; erros++; yyerror("Limite incorreto na estrutura de repetição", yylineno, yytext); }
;

Token_Ate:
	ATE
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'ATE'", yylineno, yytext); }
;

Token_Faca:
	FACA
	| error { erros++; yyerror("Ausência da palavra reservada 'FACA'", yylineno, yytext); }
;

Token_Passo:
	PASSO
	| error { erros++; yyerror("Ausência da palavra reservada 'PASSO'", yylineno, yytext); }
;

Passo:
	Expressao_Limite
	{
		if ($1 == NULL) {
			$1 = strdup("");
		}

		int tamanho_expressao = strlen($1) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $1);
		int i, j = 0, marcador = 0;

		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		verificar_passo(tipo_expressao);
		strcpy($$, expressao_original);
	}
	| error { erros++; yyerror("Incremento incorreto da estrutura de repetição", yylineno, yytext); }
;

Expressao_Limite:
	Variavel 
	{
		verificar_variavel($1, yylineno);
		int tamanho = strlen($1) + 1;
		char copia[tamanho];
		strcpy(copia, $1);
		strcpy($$, copia);
		strcat($$, "$");
		strcat($$, verificar_tipo(copia));
	}
	| Funcao
	| Vetor
	{
		memset(&parametros, 0, sizeof(parametros));
	}
	| Numero_Inteiro
	{
		strcat($$, "$inteiro");
	}
	| Expressao_Aritmetica MENOS Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "-");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "-");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| Expressao_Aritmetica MAIS Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			}

			if (!marcador && copia2[i] != '$') {
				valor2[i] = copia2[i];
			} else {
				marcador = 1;
			}
		}

		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "+");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "+");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| Expressao_Aritmetica MOD Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "mod");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "%");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| Expressao_Aritmetica MULTIPLICACAO Expressao_Aritmetica
	{
		int tamanho1 = strlen($1) + 1;
		int tamanho2 = strlen($3) + 1;
		char copia1[tamanho1];
		strcpy(copia1, $1);
		char copia2[tamanho2];
		strcpy(copia2, $3);
		char tipo1[10];
		char tipo2[10];
		char valor1[tamanho1];
		char valor2[tamanho2];
		int i, j = 0;
		int marcador = 0;
		memset(&valor1, 0, sizeof(valor1));

		for (i = 0; i < tamanho1; i++) {
			if (marcador) {
				tipo1[j] = copia1[i];
				j++;
			} else {
				if (copia1[i] != '$') {
					valor1[i] = copia1[i];
				} else {
					marcador = 1;
				}
			}
		}

		marcador = 0;
		j = 0;
		memset(&valor2, 0, sizeof(valor2));

		for (i = 0; i < tamanho2; i++) {
			if (marcador) {
				tipo2[j] = copia2[i];
				j++;
			} else {
				if (copia2[i] != '$') {
					valor2[i] = copia2[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		char expressao_completa[20];
		memset(&expressao_completa, 0, sizeof(expressao_completa));
		strcpy(expressao_completa, tipo1);
		strcat(expressao_completa, "*");
		strcat(expressao_completa, tipo2);

		strcpy($$, valor1);
		strcat($$, "*");
		strcat($$, valor2);
		strcat($$, "$");
		strcat($$, calcular(expressao_completa));
	}
	| MENOS Expressao_Aritmetica %prec NEG
	{
		int tamanho1 = strlen($2) + 2;
		char copia1[tamanho1];
		strcpy(copia1, $2);
		
		$$ = strdup("-");
		strcat($$, copia1);
	}
	| PARENTESE_E Expressao_Aritmetica PARENTESE_D
	{
		int tamanho = strlen($2) + 1;
		char copia[tamanho];
		strcpy(copia, $2);
		char nova_expressao[tamanho + 2];
		memset(&nova_expressao, 0, sizeof(nova_expressao));
		int i, j = 1, coloquei = 0;

		nova_expressao[0] = '(';
		for (i = 0; i < tamanho; i++) {
			if (copia[i] != '$') {
				nova_expressao[j] = copia[i];
				j++;
			} else {
				nova_expressao[j] = ')';
				j++;
				nova_expressao[j] = copia[i];
				j++;
			}
		}

		$$ = strdup(nova_expressao);
	}
;

Fim_Para:
	FIMPARA
	{
		inserir_comando("}");
	}
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'FIMPARA'", yylineno, yytext); }
;

Enquanto:
	Inicio_Enquanto Lista_Comandos Fim_Enquanto
;

Inicio_Enquanto:
	Token_Enquanto Condicional Token_Faca Fim_Comando
	{
		int tamanho = strlen($2) + 11;
		char enquanto[tamanho];
		strcpy(enquanto, "while (");
		strcat(enquanto, $2);
		strcat(enquanto, ") {");
		inserir_comando(enquanto);
	}
;

Token_Enquanto:
	ENQUANTO { inicio_linha = yylineno; }
;

Fim_Enquanto:
	FIMENQUANTO
	{
		inserir_comando("}");
	}
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'FIMENQUANTO'", yylineno, yytext); }
;

Repita:
	Inicio_Repita Lista_Comandos Fim_Repita
;

Inicio_Repita:
	REPITA Fim_Comando
	{
		inserir_comando("\ndo {");
	}
;

Fim_Repita:
	Token_Ate_Repita Condicional
	{
		int tamanho = strlen($2) + 15;
		char repita[tamanho];
		strcpy(repita, "} ");
		strcat(repita, "while (!(");
		strcat(repita, $2);
		strcat(repita, "));");
		inserir_comando(repita);
	}
;

Token_Ate_Repita:
	ATE { inicio_linha = yylineno; }
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'ATE'", yylineno, yytext); }
;

Escolha:
	Inicio_Escolha Bloco_Casos Fim_Escolha
;

Inicio_Escolha:
	ESCOLHA Tipo_Escolha Fim_Comando { primeiro_caso = 1; }
;

Tipo_Escolha:
	Variavel
	{
		verificar_variavel($1, yylineno);
		strcpy(tipo_escolha, verificar_tipo($1));
		strcpy(var_escolha, $1);
	}
	| Funcao
	{
		int tamanho_expressao = strlen($1) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $1);

		int i, j = 0, marcador = 0;
		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}
		
		strcpy(tipo_escolha, tipo_expressao);
		strcpy(var_escolha, expressao_original);
	}
	| Vetor
	{
		int tamanho_expressao = strlen($1) + 1;
		char expressao[tamanho_expressao];
		strcpy(expressao, $1);

		int i, j = 0, marcador = 0;
		char tipo_expressao[tamanho_expressao];
		memset(&tipo_expressao, 0, sizeof(tipo_expressao));
		char expressao_original[tamanho_expressao];
		memset(&expressao_original, 0, sizeof(expressao_original));

		for (i = 0; i < tamanho_expressao; i++) {
			if (marcador) {
				tipo_expressao[j] = expressao[i];
				j++;
			} else {
				if (expressao[i] != '$') {
					expressao_original[i] = expressao[i];
				} else {
					marcador = 1;
				}
			}
		}

		strcpy(tipo_escolha, tipo_expressao);
		strcpy(var_escolha, expressao_original);

		memset(&parametros, 0, sizeof(parametros));
	}
	| String
	{
		strcpy(tipo_escolha, "caractere");
		strcpy(var_escolha, $1);
	}
	| Numero_Inteiro
	{
		strcpy(tipo_escolha, "inteiro");
		strcpy(var_escolha, $1);
	}
	| Numero_Real
	{
		strcpy(tipo_escolha, "real");
		strcpy(var_escolha, $1);
	}
	| MENOS Numero_Inteiro %prec NEG
	{
		strcpy(tipo_escolha, "inteiro");
		strcpy(var_escolha, $1);
	}
	| MENOS Numero_Real %prec NEG
	{
		strcpy(tipo_escolha, "real");
		strcpy(var_escolha, $1);		
	}
	| Verdadeiro
	{
		strcpy(tipo_escolha, "logico");
		strcpy(var_escolha, $1);
	}
	| Falso
	{
		strcpy(tipo_escolha, "logico");
		strcpy(var_escolha, $1);
	}
	| error { yyclearin; erros++; yyerror("Ausência do argumento para o comando ESCOLHA", yylineno, yytext); }
;

Bloco_Casos:
	Casos
	| Casos Outrocaso Lista_Comandos
;

Casos:
	Caso Lista_Comandos
	| Casos Caso Lista_Comandos
;

Caso:
	CASO Opcao Fim_Comando
	{
		int tamanho = strlen(auxiliar) + strlen($2) + 1;
		char caso[tamanho];

		if (primeiro_caso) {
			primeiro_caso = 0;
			strcpy(caso, "\nif (");

			if (!strcmp(tipo_escolha, "caractere")) {
				strcat(caso, "strcmp(");
				strcat(caso, var_escolha);
				strcat(caso, ", ");
				strcat(caso, $2);
				strcat(caso, ") == 0) {");
			} else {
				strcat(caso, var_escolha);
				strcat(caso, " == ");
				strcat(caso, $2);
				strcat(caso, ") {");
			}
		} else {
			strcpy(caso, "} else if (");

			if (!strcmp(tipo_escolha, "caractere")) {
				strcat(caso, "strcmp(");
				strcat(caso, var_escolha);
				strcat(caso, ", ");
				strcat(caso, $2);
				strcat(caso, ") == 0) {");
			} else {
				strcat(caso, var_escolha);
				strcat(caso, " == ");
				strcat(caso, $2);
				strcat(caso, ") {");
			}
		}

		inserir_comando(caso);
	}
;

Outrocaso:
	OUTROCASO Fim_Comando
	{
		char caso[9];
		strcpy(caso, "} else {");
		inserir_comando(caso);
	}
;

Opcao:
	String
	{
		if (strcmp("caractere", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| Numero_Inteiro
	{
		if (strcmp("inteiro", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| Numero_Real
	{
		if (strcmp("real", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| MENOS Numero_Inteiro %prec NEG
	{
		if (strcmp("inteiro", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| MENOS Numero_Real %prec NEG
	{
		if (strcmp("real", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| Verdadeiro
	{
		if (strcmp("logico", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| Falso
	{
		if (strcmp("logico", tipo_escolha)) {
			erros++;
			printf("ERRO: Tipo incompatível com o argumento do comando ESCOLHA! LINHA DO ERRO: %d.\n", yylineno);
		}
	}
	| error { yyclearin; erros++; yyerror("Ausência do argumento para o comando CASO", yylineno, yytext); }
;

Fim_Escolha:
	FIMESCOLHA
	{
		inserir_comando("}");
		memset(&tipo_escolha, 0, sizeof(tipo_escolha));
		memset(&var_escolha, 0, sizeof(var_escolha));
	}
	| error { yyclearin; erros++; yyerror("Ausência da palavra reservada 'FIMESCOLHA'", yylineno, yytext); }
;

Retorne:
	Token_Retorne Expressao
	{
		if (!retorne_habilitado) {
			erros++;
			yyerror("O comando RETORNE não pode ser usado fora de uma função", yylineno, yytext);
		} else {
			int tamanho_expressao = strlen($2) + 1;
			char expressao[tamanho_expressao];
			strcpy(expressao, $2);
			int i, j = 0, marcador = 0;

			char tipo_expressao[tamanho_expressao];
			memset(&tipo_expressao, 0, sizeof(tipo_expressao));
			char expressao_original[tamanho_expressao];
			memset(&expressao_original, 0, sizeof(expressao_original));

			for (i = 0; i < tamanho_expressao; i++) {
				if (marcador) {
					tipo_expressao[j] = expressao[i];
					j++;
				} else {
					if (expressao[i] != '$') {
						expressao_original[i] = expressao[i];
					} else {
						marcador = 1;
					}
				}
			}

			verificar_retorne(tipo_expressao);
		
			if (!strcmp(tipo_expressao, "caractere")) {
				int tamanho = tamanho_expressao + 19;
				char retorne[tamanho];
				strcpy(retorne, "return (strdup(");
				strcat(retorne, expressao_original);
				strcat(retorne, "));");
				inserir_comando(retorne);
			} else {
				int tamanho = tamanho_expressao + 11;
				char retorne[tamanho];
				strcpy(retorne, "return (");
				strcat(retorne, expressao_original);
				strcat(retorne, ");");
				inserir_comando(retorne);
			}
		}
	}
;

Token_Retorne:
	RETORNE { inicio_linha = yylineno; }
;

Procedimento:
	Variavel PARENTESE_E PARENTESE_D
	{
		verificar_procedimento($1, "semparametros", yylineno);
		
		int tamanho = strlen($1) + 6;
		char procedimento[tamanho];
		strcpy(procedimento, "\n");
		strcat(procedimento, $1);
		strcat(procedimento, "();");
		inserir_comando(procedimento);
	}
	| Variavel PARENTESE_E Parametros PARENTESE_D
	{
		verificar_procedimento($1, parametros, yylineno);
		memset(&parametros, 0, sizeof(parametros));

		int tamanho = strlen($1) + strlen($3) + 6;
		char procedimento[tamanho];
		strcpy(procedimento, "\n");
		strcat(procedimento, $1);
		strcat(procedimento, "(");
		strcat(procedimento, $3);
		strcat(procedimento, ");");
		inserir_comando(procedimento);
	}
;

Fim_Algoritmo:
	FIMALGORITMO Fim_Comando
	{
		inserir_comando("}");
	}
	| error { yyclearin; erros++; yyerror("Esperado a palavra reservada 'FIMALGORITMO'", yylineno, yytext); }
;

Fim_Comando:
	ENTER
	| Fim_Comando ENTER
	| error { yyclearin; erros++; yyerror("Comando não está de acordo com a sintaxe", yylineno, yytext);}
;

%%

extern FILE *yyin;

int yyerror(char *msg, int linha, char *token) {
	if (linha > 0 && linha < 5000) {
		printf("ERRO: %s! NÃO ESPERADO: %s - LINHA DO ERRO: %d.\n", msg,token,linha);
		return 0;
	}
}

int main(int argc, char *argv[]) {
	if(argc < 2) {
		printf("Digite o nome do arquivo que vai ser compilado!\n");
	} else {
		inicializar(tabela_hash);

		fila = (TipoFila *) malloc(sizeof(TipoFila));
		inicializar_fila(fila);
		yyin = fopen(argv[1],"r");
		yyparse();
		if (erros == 0) {
			FILE *arquivo_c = fopen(arquivo, "w+");
			imprimir_dados(fila, arquivo_c);
			printf("\nAlgoritmo compilado com sucesso!\n\n");
		}
   		return 0;
	}
}
