# screenFormatter

This repo is for a screenformatter implemented in 4 languages. (Ada, Cobol, Fortran, and Lisp)

**Author: Nolan Donley**

**Input**: any text file

**Output**: text file formatter to maximum 60 chars per Line and also the line with most and least words

## For Ada:
-To compile:
`gnatmake formatter.adb`

-To run:
`formatter {absolute filepath}`

## For Cobol:
-To compile:
`cobc -x formatter.cob`

-To run:
`./formatter {absolute filepath}`

## For Fortran:
-To compile:
`gfortran formatter.f95`

-To run:
`./a.out {absolute filepath}`

## For Lisp:
-To compile and run:
`sbcl --script formatter.lisp {absolute filepath}`



## Example Run in Ada

### testfile.txt

        93The quick brown fox jumped over the lazy
        dog and then ran to the hen-house where he ate the rooster and all of the chickens.
        94The brown fox then made a dessert of the
        white protein packets with the hard
        shell and creamy yellow     center.

### On command line:
`[]$ gnatmake formatter.adb`
        
        gcc -c formatter.adb
        gnatbind -x formatter.ali
        gnatlink formatter.ali

`[]$ formatter /home/donley_ns/screenformatter/testfile.txt`

                1  The quick brown fox jumped over the lazy dog and then ran to
                2  the hen-house where he ate the rooster and all of the
                3  chickens. The brown fox then made a dessert of the white
                4  protein packets with the hard shell and creamy yellow
                5  center.

        LONG    1           The quick brown fox jumped over the lazy dog and then ran to
        SHORT   5           center.  
