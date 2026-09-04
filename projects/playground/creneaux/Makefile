COB = cobc
COBFLAGS = -x -std=ibm
CRENEAUX = creneaux
CRENEAUXDATA = creneaux.dat

.PHONY : all run clean cleandata
all : creneaux

creneaux : creneaux.cob
	$(COB) $(COBFLAGS) -o $(CRENEAUX) $<

run : creneaux cleandata
	./$<

clean : cleandata
	rm -f $(CRENEAUX)

cleandata : 
	rm -f $(CRENEAUXDATA)
