COB = cobc
COBFLAGS = -x -std=ibm
INDEXEDF = indexedf
INDEXEDFDATA = products.dat

.PHONY : all run clean cleandata
all : indexedf

indexedf : indexedf.cbl
	$(COB) $(COBFLAGS) -o $(INDEXEDF) $<

run : indexedf cleandata
	./$<

clean : cleandata
	rm -f $(INDEXEDF)

cleandata :
	rm -f $(INDEXEDFDATA)
