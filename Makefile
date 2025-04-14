MAKEFLAGS=-s

build:
	./src/shcripts/dync.sh

clean:
	rm -rf backup

cleantest:
	rm -rf test_home/*
