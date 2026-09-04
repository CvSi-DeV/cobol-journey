COB = cobc
COBFLAGS = -x -std=ibm
NAVALBAT = navalbat
GRILLE = grille.dat

.PHONY: all run clean cleangrille
all : navalbat

navalbat : navalbat.cob
	$(COB) $(COBFLAGS) $< -o $(NAVALBAT)

run : navalbat cleangrille
	./$<

clean: cleangrille
	rm -f $(NAVALBAT)

cleangrille :  
	rm -f $(GRILLE)