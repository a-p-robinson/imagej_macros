#!/bin/bash

# Which imagej do we want to use?
#IJ="/usr/bin/imagej - x 20000"
IJ="/home/apr/Apps/Fiji.app/ImageJ-linux64 -macro "

# Where did we run the script from ?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Where are our functions?+
INCLUDE_FILE="$DIR/macros/functions_npl.ijm"

# What temp file shall we use?
TMP_FILE="_run.ijm"

# Run the passed imagej macro
cp $1 $PWD/$TMP_FILE
echo " " >> $PWD/$TMP_FILE
cat $INCLUDE_FILE >> $PWD/$TMP_FILE

# Pass arguments to script (apart from file name)
argc=$#
argv=("$@")
tmp_argv=" "
for (( j=1; j<argc; j++ )); do
    echo "${argv[j]}"
    tmp_argv="${tmp_argv} ${argv[j]}"
done

$IJ $PWD/$TMP_FILE "${tmp_argv}"
