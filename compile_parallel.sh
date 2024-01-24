#!/bin/bash

# If GNU Parallel is not found, compile and install it for the current user.
if ! command -v ./compiled/bin/parallel &> /dev/null
then
  cd ./parallel || exit
  ./configure --prefix="${COMPILED_PATH}"
  make install
  cd ..
fi