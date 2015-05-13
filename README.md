# Compilador da linguagem Legol
Este repositório contém o texto e a apresentação da Monografia e os códigos do compilador da linguagem Legol.

Para utilizar o compilador, é necessário ter uma máquina com o sistema operacional Linux e instalar as ferramentas Flex e Bison. Os comandos para instalação são:

$ sudo apt-get install flex flex-doc bison bison-doc

Em seguida, dentro da pasta Projeto, execute os comandos:

$ make<br>
$ ./compilador [caminho ou nome do arquivo (.txt) com algoritmo em Legol]

O comando 'make' acima faz uma cópia do compilador para a pasta Exemplos. Dentro desta pasta tem 50 exemplos de algoritmos escritos em linguagem Legol e ao executar o comando 'make' dentro dela, os 50 algoritmos serão compilados.
