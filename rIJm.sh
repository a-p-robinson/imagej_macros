#!/bin/bash

# Which imagej do we want to use?
#IJ="/usr/bin/imagej - x 20000"
IJ="/home/apr/Apps/Fiji.app/ImageJ-linux64 -macro "

# Where did we run the script from ?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Where are our functions?
INCLUDE_FILE="$DIR/macros/functions.ijm"

# What temp file shall we use?
TMP_FILE="_run.ijm"

# Run the passed imagej macro
cp $1 $PWD/$TMP_FILE
echo " " >> $PWD/$TMP_FILE
cat $INCLUDE_FILE >> $PWD/$TMP_FILE
$IJ $PWD/$TMP_FILE
