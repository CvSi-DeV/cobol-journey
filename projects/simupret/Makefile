COBC = cobc -x -std=ibm
COBM = cobc -m -std=ibm
SIMUPRET = simupret
EVALTAUX = evaltaux
CALCMENS = calcmens
GENEECHE = geneeche

.PHONY : cleanmodule clean 

$(SIMUPRET) : $(SIMUPRET).cob $(EVALTAUX).dylib $(CALCMENS).dylib $(GENEECHE).dylib
	$(COBC) $<
$(EVALTAUX).dylib : $(EVALTAUX).cob
	$(COBM) $<
$(CALCMENS).dylib : $(CALCMENS).cob
	$(COBM) $<
$(GENEECHE).dylib : $(GENEECHE).cob
	$(COBM) $<
run : $(SIMUPRET)
	./$<
clean : cleanmodule
	rm -f $(SIMUPRET)
cleanmodule : 
	rm -f *.dylib