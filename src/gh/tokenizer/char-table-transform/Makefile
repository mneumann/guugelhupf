all: tools/german.cts tools/english.cts
	ruby tools/createCharTable.rb < tools/german.cts > german.sml
	ruby tools/createCharTable.rb Bin < tools/german.cts > german.ct
	ruby tools/createCharTable.rb < tools/english.cts > english.sml
	ruby tools/createCharTable.rb Bin < tools/english.cts > english.ct
