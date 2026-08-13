all: spartacus ftt

spartacus: src/*/*.sml src/parsers/*/* src/spartacus.mlb
	mlton -codegen native -output spartacus src/spartacus.mlb

ftt: src/*/*.sml src/parsers/*/* src/ftt.mlb
	mlton -codegen native -output ftt src/ftt.mlb

clean:
	rm -f spartacus ftt
