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

macro "alpha" {

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
    run("32-bit");
    nVoxels = countsROImanager();

    // Convolve this with an appropiate gaussian
    // NEED TO DO THIS IN 3D!
    // Define sigma here
    selectWindow("NM");
    gaus = 4.246609003; // FWM = 10mm
    //gaus = 4.671269904; // FWM = 11mm
    //gaus = 5.095930804; // FWM = 12mm
    //gaus = 5.520591704; // FWM = 13mm
    //gaus = 5.945252605; // FWM = 14mm
    //gaus = 6.369913505; // FWM = 15mm
    //gaus = 6.794574405; // FWM = 16mm
    //gaus = 7.219235306; // FWM = 17mm
    //gaus = 7.643896207; // FWM = 18mm
    //gaus = 8.068557106; // FWM = 19mm
    //gaus = 8.493218007; // FWM = 20mm
    gaus = gaus / 4.41806; // now in voxels ?
    run("Gaussian Blur 3D...", "x=" + gaus + " y=" + gaus + " z=" + gaus);
    //run("Gaussian Blur...", "sigma=" + gaus +" scaled stack");
    
    // Blank outside the ROI again
    clearoutsideROImanager();

    // Measure counts again
    nRemoved = countsROImanager();

    // Counts removed
    cr = nVoxels - nRemoved;
    
    // Calcualte alpha
    print("Gauss = " + gaus);
    print("nVoxels = " + nVoxels);
    print("nRemoved = " + cr);
    print("cvoi/ctrue = " + (nRemoved/nVoxels));
    print("mean alpha[i] = " + (1 - (nRemoved/nVoxels)) );
    
    // Save the output
    selectWindow("Log");
    save(DataSetID + "_alpha.txt");

}
