#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef struct TipoItemFila* PonteiroItemFila;

typedef struct TipoItemFila {
    char *dado;
    PonteiroItemFila seguinte;
} TipoItemFila;

typedef struct TipoFila {
    TipoItemFila *inicio;
    TipoItemFila *fim;
    int tamanho;
} TipoFila;

void inicializar_fila(TipoFila *fila) {
    fila->inicio = NULL;
    fila->fim = NULL;
    fila->tamanho = 0;
}
/* add (adicionar) um TipoItemFila na Tipofila */
int enfileirar(TipoFila *fila, TipoItemFila *elemento, char *dado) {
    int tamanho = strlen(dado) + 1;
    char codigo[tamanho];
    strcpy(codigo, dado);

    TipoItemFila *novo_item;

    if ((novo_item = (TipoItemFila *) malloc (sizeof (TipoItemFila))) == NULL) {
        return 0;
    }

    if ((novo_item->dado = (char *) malloc (tamanho)) == NULL) {
        return 0;
    }

    strcpy(novo_item->dado, codigo);

    if (elemento == NULL) {
        if (fila->tamanho == 0) {
            fila->fim = novo_item;
        }

        novo_item->seguinte = fila->inicio;
        fila-> inicio = novo_item;
    } else {
        if (elemento->seguinte == NULL) {
            fila->fim = novo_item;
        }

        novo_item->seguinte = elemento->seguinte;
        elemento->seguinte = novo_item;
    }

    fila->tamanho++;
    return 1;
}

/* exibição da TipoFila */
void imprimir_dados(TipoFila *fila, FILE *arquivo){
    TipoItemFila *elemento;
    int i;

    elemento = fila->inicio;

    for (i = 0; i < fila->tamanho; i++) {
        fprintf(arquivo, "%s\n", elemento->dado);
        elemento = elemento->seguinte;
    }
}
