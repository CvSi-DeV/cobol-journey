#Hellowld Makefile 
##################

COB = cobc
COBFLAGS = -x -std=ibm
HELLOWLD = hellowld

.PHONY:  all clean build  run 

all : hellowld

hellowld : HELLOWLD.cob
	$(COB) $(COBFLAGS) $< -o $@

rebuild: clean hellowld

run: hellowld
	./$(HELLOWLD)

clean: 
	rm -f $(HELLOWLD)

