COBC = cobc -x -std=ibm
COBM = cobc -m -std=ibm
SIMUPRET = simupret
EVALTAUX = evaltaux
CALCMENS = calcmens

.PHONY : cleanmodule clean 

$(SIMUPRET) : $(SIMUPRET).cob $(EVALTAUX) $(CALCMENS)
	$(COBC) $<
$(EVALTAUX) : $(EVALTAUX).cob
	$(COBM) $<
$(CALCMENS) : $(CALCMENS).cob
	$(COBM) $<
run : $(SIMUPRET)
	./$<
clean : cleanmodule
	rm -f $(SIMUPRET)
cleanmodule : 
	rm -f *.dylib