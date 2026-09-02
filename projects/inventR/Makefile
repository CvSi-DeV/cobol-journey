COB = cobc
COBFLAGS = -x -std=ibm
INVENTR = inventR
RAPPORT = rapport-inventaire.txt

.PHONY: all run clean
all: inventR

inventR: inventR.cob
	$(COB) $(COBFLAGS) $< -o $(INVENTR)

run: inventR commandes.dat produits.dat
	./$<

clean: 
	rm -f $(INVENTR) $(RAPPORT)