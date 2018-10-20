.PHONY: all build doc test clean

all: build doc test

build:
	dune build

doc:
	dune build @doc

test:
	dune runtest -f -j1 --no-buffer --verbose

clean:
	dune clean
