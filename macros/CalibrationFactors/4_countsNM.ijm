// SPDX-License-Identifier: GPL-3.0-or-later
// ***********************************************************************
// * Load in a CT file and associated ROI set and 
// *  - scale ROis to NM with alignment
// *  - Get counts in ROI
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
var     win;
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

    //------------------------------------------------------------------------------------------------
    // Translate the ROIs from CT to NM in X and Y
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(factor);

    // Translate the ROIs from CT to NM in Z
    selectWindow("NM");
    translateROImanagerdZ(-1*delta[2]);

    // Measure total counts in ROI for all NM images
    selectWindow("NM");
    countsIRAC = countsROImanager();
    tStats = getStatsROImanager();
    maxCountsIRAC = tStats[1];
    selectWindow("NMSC");
    countsIRACSC = countsROImanager();
    tStats = getStatsROImanager();
    maxCountsIRACSC = tStats[1];
    selectWindow("NMNC");
    countsIRNC = countsROImanager();
    tStats = getStatsROImanager();
    maxCountsIRNC = tStats[1];
    /////////////////
    // Get the mean change in counts from doing +/- 1 slice
    // Add an extra ROI to +/- one slice from ends
    getVoxelSize(width, height, depth, unit);
    roiManager("Select",0);
    roiManager("Add");
    translateROIdZ(-1*depth);

    roiManager("Sort");

    roiManager("Deselect");
    roiManager("Select",roiManager("count")-1);
    roiManager("Add");
    translateROIdZ(depth);
    roiManager("Deselect");

    // Get the biggest error in slices
    selectWindow("NM");
    sigma_rdZIRAC = calcSliceError() / 2;
    selectWindow("NMSC");
    sigma_rdZIRACSC = calcSliceError() / 2;
    selectWindow("NMNC");
    sigma_rdZIRNC = calcSliceError() / 2;
    /////////////////

    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Now load in the error ROIS and repeat 
    roiManager("Reset");
    roiManager("Open", errorROIfile128);

    // Translate the ROIs from CT to NM in Z
    selectWindow("NM");
    translateROImanagerdZ(-1*delta[2]);

    // Measure total counts in errorROI for all NM images
    selectWindow("NM");
    sigma_rdXdYIRAC = countsROImanager() / 4;

    selectWindow("NMSC");
    sigma_rdXdYIRACSC = countsROImanager() / 4;

    selectWindow("NMNC");
    sigma_rdXdYIRNC = countsROImanager() / 4;
    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Calculate counting errors
    sigma_nIRAC   = sqrt(countsIRAC);
    sigma_nIRACSC = sqrt(countsIRACSC);
    sigma_nIRNC   = sqrt(countsIRNC);
    //------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------
    // Calculate total errors
    sigma_IRAC = sqrt((sigma_nIRAC * sigma_nIRAC) + (sigma_rdXdYIRAC * sigma_rdXdYIRAC) + (sigma_rdZIRAC * sigma_rdZIRAC));
    sigma_IRACSC = sqrt((sigma_nIRACSC * sigma_nIRACSC) + (sigma_rdXdYIRACSC * sigma_rdXdYIRACSC) + (sigma_rdZIRACSC * sigma_rdZIRACSC));
    sigma_IRNC = sqrt((sigma_nIRNC * sigma_nIRNC) + (sigma_rdXdYIRNC * sigma_rdXdYIRNC) + (sigma_rdZIRNC * sigma_rdZIRNC));
    //------------------------------------------------------------------------------------------------

    print(" ");
    print("Sum counts ROI [IRAC]   = " + countsIRAC   + " sigma_rdXdY = " + sigma_rdXdYIRAC   + " sigma_rdZ = " + sigma_rdZIRAC + " sigma_n = " + sigma_nIRAC + " SIGMA = " + sigma_IRAC);
    print("Error = " + (sigma_IRAC / countsIRAC) * 100 + " % [n = " + (sigma_nIRAC / countsIRAC) * 100 + " %, dXdY = " + (sigma_rdXdYIRAC / countsIRAC) * 100 + " %, dZ = " + (sigma_rdZIRAC / countsIRAC) * 100 + " %]\n");

    print("Sum counts ROI [IRACSC] = " + countsIRACSC + " sigma_rdXdY = " + sigma_rdXdYIRACSC + " sigma_rdZ = " + sigma_rdZIRACSC + " sigma_n = " + sigma_nIRACSC + " SIGMA = " + sigma_IRACSC);
    print("Error = " + (sigma_IRACSC / countsIRACSC) * 100 + " % [n = " + (sigma_nIRACSC / countsIRACSC) * 100 + " %, dXdY = " + (sigma_rdXdYIRACSC / countsIRACSC) * 100 + " %, dZ = " + (sigma_rdZIRACSC / countsIRACSC) * 100 + " %]\n");

    print("Sum counts ROI [IRNC]   = " + countsIRNC   + " sigma_rdXdY = " + sigma_rdXdYIRNC   + " sigma_rdZ = " + sigma_rdZIRNC   + " sigma_n = " + sigma_nIRNC + " SIGMA = " + sigma_IRNC);
print("Error = " + (sigma_IRNC / countsIRNC) * 100 + " % [n = " + (sigma_nIRNC / countsIRNC) * 100 + " %, dXdY = " + (sigma_rdXdYIRNC / countsIRNC) * 100 + " %, dZ = " + (sigma_rdZIRNC / countsIRNC) * 100 + " %]\n");

print("Max Pixel values:");
print("IRAC = " + maxCountsIRAC + " IRACSC = " + maxCountsIRACSC + " IRNC = " + maxCountsIRNC);
    // Save the output
    selectWindow("Log");
    save(DataSetID + "_" + win + "_countsNM.txt");

}
