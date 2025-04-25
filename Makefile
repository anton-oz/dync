MAKEFLAGS=-s

build:
	./src/dync.sh

clean:
	rm -rf backup

cleantest:
	rm -rf test_home/*
