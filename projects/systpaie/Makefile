.PHONY : all run clean

COB = cobc
COBFLAGS = -x -std=ibm
SYSTPAIE = systpaie
RAPPORT = rapport-fp.txt

all : systpaie

systpaie : systpaie.cob
	$(COB) $(COBFLAGS) $< -o $(SYSTPAIE)

run : systpaie employes.dat
	./$<

clean:
	rm -f $(SYSTPAIE) $(RAPPORT)