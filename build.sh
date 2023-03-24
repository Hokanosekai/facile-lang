#!/bin/sh

# This script is used to build the project.

rm -rf build
mkdir build
cd build
cmake ..
make
