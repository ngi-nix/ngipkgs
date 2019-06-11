# Noise Socket

This library implements the
[NoiseSocket](https://noisesocket.org/)
[specification](https://noisesocket.org/spec/noisesocket/).

## Installation

`noise-socket` can be installed via `opam`:

    opam install noise-socket

## Building

To build from source, generate documentation, and run tests, use `dune`:

    dune build
    dune build @doc
    dune runtest

In addition, the following `Makefile` targets are available
 as a shorthand for the above:

    make all
    make build
    make doc
    make test

## Documentation

The documentation and API reference is generated from the source interfaces.
It can be consulted [online][doc] or via `odig`:

    odig odoc noise-socket
    odig doc noise-socket

[doc]: https://p2pcollab.net/doc/noise-socket/
