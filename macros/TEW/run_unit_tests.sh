#!/bin/bash

# Which imagej do we want to use?
IJ="/home/apr/Apps/Fiji.app/ImageJ-linux64 -macro "

# What temp file shall we use?
TMP_FILE="_run.ijm"

# Copy the macro
cp run_unit_tests.ijm $PWD/$TMP_FILE
echo " " >> $PWD/$TMP_FILE
cat TEW_DEW_Scatter_Correction.ijm >> $PWD/$TMP_FILE

# Run (no argument passing)
$IJ $PWD/$TMP_FILE