CALCBIMP = calcbimp
CALCCOTI = calccoti
CALCIMPO = calcimpo
CALCSALN = calcsaln
GENERAPP = generapp
SYSTPAII = systpaii
#Compiler les modules
COBM = COBC -m -std=ibm
#Compiler l'exécutable 
COBC = COBC -x -std=ibm
RAPPORT = rapport-fp.txt

.PHONY: all run modules cleanrapport clean

$(CALCBIMP) : $(CALCBIMP).cob
	$(COBM) $<
$(CALCCOTI) : $(CALCCOTI).cob
	$(COBM) $<
$(CALCIMPO) : $(CALCIMPO).cob
	$(COBM) $<
$(CALCSALN) : $(CALCSALN).cob
	$(COBM) $<
$(GENERAPP) : $(GENERAPP).cob
	$(COBM) $<
$(SYSTPAII) :$(SYSTPAII).cob
	$(COBC) $<

all : modules $(SYSTPAII)

run : all
	./$(SYSTPAII)

modules: $(CALCBIMP) $(CALCCOTI) $(CALCIMPO) $(CALCSALN) $(GENERAPP)

cleanrapport : 
	rm -f $(RAPPORT)

clean: cleanrapport
	rm -f *.dylib  $(SYSTPAII)
