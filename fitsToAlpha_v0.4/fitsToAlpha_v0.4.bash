#!/bin/bash -f

# fta
# fits to alpha

# 2022.03.28

# yuma aoki



# check arguments
if [ $# != 2 ] ; then
    printf "[inputFile] [outputFile]\n"
    exit
fi

# input args
inputFile=$1
outputFile=$2

# var
scriptDir=$(cd $(dirname $0); pwd)

# checking outputFile
if [ -e $outputFile ] ; then
    printf "$outputFile exists...\n"
    printf "Do you want to overwrite?(Y/N): "
    read KEY
    case "$KEY" in
        [Yy])
            rm -f $outputFile
            ;;
        *)
            exit
            ;;
    esac
fi

# fits -> ASCII
fdump page=no prhead=no pagewidth=256 outfile=STDOUT columns="CCD_ID, SEGMENT, GRADE, RAWX, RAWY, PHA" rows=- $inputFile | awk 'NF==7 {printf "%d  %d  %d  %d  %d  %d  %d\n", $2, $3, $4, $5, $6, $7, $1}' > $outputFile

exit

