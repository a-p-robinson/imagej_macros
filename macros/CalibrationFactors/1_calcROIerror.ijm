// ***********************************************************************
// * Calculate the ROI sets corresponding to the error in ROI definition
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

macro "calcROIerror" {

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    //-----------------------------------------------------------------------------------------
    // 512x512
    // Open the data set
    openDataSet3(NMfile, NMfileSC, NMfileNC, CTfile, nCT, ROIfile);
    print("***[Data Set = " + DataSetID + "]***\n");

    // Use CT images to calculate the error ROI sets
    selectWindow("CT");

    // Calculate the individual ROI error sets
    calcROIErrorSetsXY("512");

    // Merge the XY ROI error sets
    mergeErrorSetXY("512");

    // Add slice errors
    sliceErrorSet("512");

    // Save the output
    selectWindow("Log");
    save(DataSetID + "512" + "_errorSets.txt");

    // Close all windows and Images
    closeAllWindows();
    closeAllImages();
    // //-----------------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------------
    // 128 x 128
    // Open the data set again
    roiManager("Reset");
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

    // Calculate the individual ROI error sets
    calcROIErrorSetsXY("128");

    // Merge the XY ROI error sets
    mergeErrorSetXY("128");

    // Add slice errors
    sliceErrorSet("128");

    // Save the output
    selectWindow("Log");
    save(DataSetID + "128" + "_errorSets.txt");
    //-----------------------------------------------------------------------------------------


}
