// ***********************************************************************
// Testing NEMA sphere placement
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

macro "showROI" {

    // Open the CT data set and point ROIS
    openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_2_RoiSet.zip");

    // Print CT image details
    printDetails("CT");

    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);

    // Measure volume and surface area
    geometry = newArray(2);
    geometry = getVolumeArea();
    print("ROI Volume = " + geometry[0] + " ( )" + " " + unit + "^3");
    print("ROI Surface Area = " + geometry[1] + " ( )"+ " " + unit + "^2");
}
