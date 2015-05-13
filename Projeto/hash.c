#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TAMANHO_HASH 100
#define TAMANHO_VARIAVEL 30
#define TAMANHO_TIPO 10
#define TAMANHO_ESCOPO 8
#define TAMANHO_CHAVE 36
#define TAMANHO_PARAMETROS 100

typedef char TipoVariavel[TAMANHO_VARIAVEL];
typedef char TipoChave[TAMANHO_CHAVE];
typedef char TipoEscopo[TAMANHO_ESCOPO];
typedef char TipoPrimitivo[TAMANHO_TIPO];
typedef char TipoParametro[TAMANHO_PARAMETROS];

typedef struct TipoDimensao {
    int primeiro_indice;
    int segundo_indice;
    int terceiro_indice;
    int quarto_indice;
} TipoDimensao;

typedef struct TipoItem {
    TipoChave chave;
    TipoVariavel variavel;
    TipoPrimitivo tipo;
    TipoEscopo escopo;
    TipoDimensao dimensao;
    TipoParametro parametros;
} TipoItem;

typedef unsigned int TipoInteiro;

typedef struct Celula* Ponteiro;

typedef struct Celula {
  TipoItem item;
  Ponteiro proxima;
}Celula;

typedef struct TipoLista {
  Celula *primeira, *ultima;
}TipoLista;

typedef TipoLista TipoTabela[TAMANHO_HASH];

TipoInteiro pesos[TAMANHO_VARIAVEL];

void lista_vazia(TipoLista *lista) {
    lista->primeira = (Celula *)malloc(sizeof(Celula));
    lista->ultima = lista->primeira;
    lista->primeira->proxima = NULL;
}

int vazia(TipoLista lista) {
    return (lista.primeira == lista.ultima);
}

void inserir(TipoItem item, TipoLista *lista) {
    lista->ultima->proxima = (Celula *)malloc(sizeof(Celula));
    lista->ultima = lista->ultima->proxima;
    lista->ultima->item = item;
    lista->ultima->proxima = NULL;
}

void gerar_pesos() {
  int i;

  for (i = 0; i < TAMANHO_VARIAVEL; i++) {
    pesos[i] = (TAMANHO_HASH*(rand()/(RAND_MAX+1.0)));
  }
}

TipoInteiro gerar_indice(TipoChave chave) {
    int i;
    int tamanho = strlen(chave);
    TipoInteiro soma = 0;

    for (i = 0; i < tamanho; i++) {
        soma += (TipoInteiro)chave[i] * pesos[i];
    }

    return (soma % TAMANHO_HASH);
}

void inicializar(TipoTabela tabela) {
    int i;

    for (i = 0; i < TAMANHO_HASH; i++) {
        lista_vazia(&tabela[i]);
    }

    gerar_pesos();
}

Ponteiro pesquisar(TipoChave chave, TipoTabela tabela) {
    TipoInteiro i;
    Ponteiro ponteiro;

    i = gerar_indice(chave);

    if (vazia(tabela[i])) {
        return NULL;   /* Pesquisa sem sucesso */
    } else {
        ponteiro = tabela[i].primeira;

        while (ponteiro->proxima->proxima != NULL && strncmp(chave, ponteiro->proxima->item.chave, sizeof(TipoChave))) {
            ponteiro = ponteiro->proxima;
        }

        if (!strncmp(chave, ponteiro->proxima->item.chave, sizeof(TipoChave))) {
            return ponteiro;
        } else {
            return NULL;   /* Pesquisa sem sucesso */
        }
    }
}

int inserir_item(TipoItem item, TipoTabela T) {
    if (pesquisar(item.chave, T) == NULL) {
        inserir(item, &T[gerar_indice(item.chave)]);
        return 1;
    } else {
        return 0;
    }
}
