// SPDX-License-Identifier: GPL-3.0-or-later
// ***********************************************************************
// * Get the number and rea of pixels which are actually in a measurement
// *
// * APR: 04/03/15
// ***********************************************************************

//---------------------------------------------------------------------------
// Global Variables:
var	DataSetID;
var	NMfile;
var     NMfileSC;
var     NMfileNC;
var	NMfile1;
var     NMfileSC1;
var     NMfileNC1;
var	NMfile2;
var     NMfileSC2;
var     NMfileNC2;
var	CTfile;
var	nCT = 90;
var	ROIfile;
var	errorROIfile512;
var	errorROIfile128;
//---------------------------------------------------------------------------

macro "countsNM" {

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    // Open the data set
    openDataSet3(NMfile, NMfileSC, NMfileNC, CTfile, nCT, ROIfile);
    print("***[Data Set = " + DataSetID + "]***\n");

    // Calculate the alignment of CT and NM
    delta = calcNMCTalignment(NMfile, CTfile);

    // Translate the ROIs from CT to NM in X and Y
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(factor);

    // Translate the ROIs from CT to NM in Z
    selectWindow("NM");
    translateROImanagerdZ(-1*delta[2]);

    // Clear the region ouside the ROIs
    clearoutsideROImanager();
    setvalueROImanager(1);

    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);

    // Now measure the total counts in the whole image = number of voxels
    npixels = countsROImanager();

    printDetails("NM");
    print("ROI Measure uses " + npixels + " voxels in total");
    print(" ");
    print("Corresponds to " + npixels * vWidth * vHeight * abs(vDepth) + " " + unit + "^3");

    // Save the output
    selectWindow("Log");
    save(DataSetID + "_getCountedVolume.txt");

}
