test:
#cc -c MmapStream.cc
	cc -c MyMmapTokenStream.cc
	cc -c test.cc

#	cc MmapStream.o MyMmapTokenStream.o test.o -o test
	cc MyMmapTokenStream.o test.o -lstdc++ -o test

clean:
	rm *.o
	rm test
