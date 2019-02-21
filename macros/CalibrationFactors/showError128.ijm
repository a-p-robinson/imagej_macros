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

macro "showError128" {

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    // Open the data set 
    openDataSet(NMfile, CTfile, nCT, errorROIfile128);

    // Calculate the alignment of CT and NM
    delta = calcNMCTalignment(NMfile, CTfile);

    // Translate the ROIs from CT to NM in Z
    //selectWindow("IRACOSEM001_DS.dcm");
    selectWindow("NM");
    translateROImanagerdZ(-1*delta[2]);

}
