// ***********************************************************************
// * Display a CT image and associated ROIs
// *
// * APR: 04/03/15
// ***********************************************************************

//---------------------------------------------------------------------------
// Global Variables:
var	DataSetID;
var	NMfile;
var     NMfileSC;
var     NMfileNC;
var	CTfile;
var	nCT = 90;
var	ROIfile;
//---------------------------------------------------------------------------

macro "showNM" {

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    // Open the data set
    //openDataSet(NMfile, CTfile, nCT, ROIfile);
    openDataSet3(NMfile, NMfileSC, NMfileNC, CTfile, nCT, ROIfile);

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
    selectWindow("IRACOSEM001_DS.dcm");
    translateROImanagerdZ(-1*delta[2]);

}
