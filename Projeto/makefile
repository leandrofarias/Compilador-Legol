FLEX = flex
BISON = bison
GCC = gcc
FILE = compilador

compile:
	@ $(BISON) -d $(FILE).y
	@ $(FLEX) -o $(FILE).c $(FILE).lex
	@ $(GCC) -o $(FILE) $(FILE).c $(FILE).tab.c -lfl -lm
	@ cp $(FILE) ../Exemplos

clean:
	@ rm -rf $(FILE) $(FILE).c $(FILE).tab.c $(FILE).tab.h $(FILE).output
	@ rm -rf *~ 
