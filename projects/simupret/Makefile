COBC = cobc -x -std=ibm
COBM = cobc -m -std=ibm
SIMUPRET = simupret
EVALTAUX = evaltaux
CALCMENS = calcmens
GENEECHE = geneeche
GENEJSON = genejson

.PHONY : cleanmodule clean cleanjson

$(SIMUPRET) : $(SIMUPRET).cob $(EVALTAUX).dylib $(CALCMENS).dylib $(GENEECHE).dylib $(GENEJSON).dylib
	$(COBC) $<
$(EVALTAUX).dylib : $(EVALTAUX).cob
	$(COBM) $<
$(CALCMENS).dylib : $(CALCMENS).cob
	$(COBM) $<
$(GENEECHE).dylib : $(GENEECHE).cob
	$(COBM) $<
$(GENEJSON).dylib : $(GENEJSON).cob
	$(COBM) $<
run : $(SIMUPRET)
	./$<
clean : cleanmodule cleanjson
	rm -f $(SIMUPRET)
cleanmodule : 
	rm -f *.dylib
cleanjson : 
	rm -f *.json