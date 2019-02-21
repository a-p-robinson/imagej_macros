// ***********************************************************************
// * Load in the NM data and return total counts
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

macro "totalCounts" {

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    // Open the data set
    openDataSet3(NMfile, NMfileSC, NMfileNC, CTfile, nCT, ROIfile);
    print("***[Data Set = " + DataSetID + "]***\n");

    // Measure total counts in ROI for all NM images
    selectWindow("NM");
    countsIRAC = totalCounts();

    selectWindow("NMSC");
    countsIRACSC = totalCounts();

    selectWindow("NMNC");
    countsIRNC = totalCounts();

    print("IRAC = " + countsIRAC);
    print("IRACSc = " + countsIRACSC);
    print("IRNC = " + countsIRNC);

    selectWindow("Log");
    save(DataSetID + "_" + win + "_totalCountsNM.txt");

}
