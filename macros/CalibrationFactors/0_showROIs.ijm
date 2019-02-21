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
//---------------------------------------------------------------------------

macro "showROIs" {

    // Prompt for dataset to use
    selectDataSet();

    // Open the data set
    openDataSet(NMfile, CTfile, nCT, ROIfile);

}
