# MAKEFLAGS=

build:
	./src/dync.sh

clean:
	rm -rf backups

cleantest:
	rm -rf test_home/*
