# on Windows: make EXE_EXT=.exe 

all: gh_index$(EXE_EXT) gh_query$(EXE_EXT) 

gh_index$(EXE_EXT): 
	rm -f x.sml
	CM.rb index.cm
	mv x $@
	rm x.sml

gh_query$(EXE_EXT): 
	rm -f x.sml
	CM.rb query.cm
	mv x $@
	rm x.sml

clean:
	rm -f x.sml gh_index$(EXE_EXT) gh_query$(EXE_EXT)
