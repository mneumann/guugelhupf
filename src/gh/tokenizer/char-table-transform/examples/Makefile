all:
	CM.rb test.cm /tmp/prg.sml
	( cd ../mmap && $(MAKE) )
	mlton /tmp/prg.sml ../mmap/mmap-tokenizer.o

clean:
	rm -f /tmp/prg.sml /tmp/prg
	( cd ../mmap && $(MAKE) clean )
