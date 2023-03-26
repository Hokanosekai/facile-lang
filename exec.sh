#!/bin/sh

rm -f *.exe
rm -f *.il

./build/facile test.ez

ilasm output.il /exe /output:output.exe

echo "\nDone.\n"

mono output.exe