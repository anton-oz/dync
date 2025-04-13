MAKEFLAGS=-s

build:
	./src/shcripts/dync.sh

clean:
	rm -rf src/backup
