#!/bin/sh

rm -f *.exe
rm -f *.il

./build/facile $1

ilasm output.il /exe /output:z.exe

echo "\nDone.\n"