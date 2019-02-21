// ***********************************************************************
// * Do all the analysis
// *
// * APR: 03/09/15
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

macro "allAnalysis" {

    // Loop through each data option
    isotopes = newArray("177Lu","99mTc");
    windows = newArray("EM1","EM2");

    // // 99mTc
    // isotope = isotopes[1];
    // win = windows[0];
    // choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Spleen - Polyjet", "Cylinder ABS (2014)","Cylinder Perspex (2014)", "Cylinder ABS", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "Whole Phantom", "LVS");

    // for(i = 0 ; i < choices.length; i++){
    // 	data = choices[i];

    // 	selectDataSetByIDnoPostFilter(isotope, win, data);

    // 	// Calc roiErrors
    // 	calcROIerror();
	
    // 	// Get countsNM
    // 	countsNM();
	
    // 	// Get total counts
    // 	doTotalCounts();
	
    // 	// Get counted volume
    // 	getCountedVolume();
	
    // }

    // 177Lu
    isotope = isotopes[0];
    choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "LVS", "WholePhantom");

    for(j = 0; j < windows.length; j++){
    //for(j = 0; j < 1; j++){
	win = windows[j];

	//	for(i = 0 ; i < choices.length; i++){
	for(i = 6 ; i < 7; i++){
	    data = choices[i];
	
	    selectDataSetByIDnoPostFilter(isotope, win, data);

	    // Calc roiErrors
	    calcROIerror();
	
	    // Get countsNM
	    countsNM();
	    
	    // Get total counts
	    doTotalCounts();
	    
	    // Get counted volume
	    getCountedVolume();
	    
	}
    }

}

function calcROIerror(){

   // Define the rescale factor we want to use
    factor = 0.25;

    print(errorROIfile512);
    print(errorROIfile128);

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

    print(errorROIfile512);
    print(errorROIfile128);

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

    closeAllWindows();
    closeAllImages();

}

function countsNM(){

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
    // Get the mean change in counts from doidn +/- 1 slice
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

    closeAllWindows();
    closeAllImages();

}


function doTotalCounts() {

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

    closeAllWindows();
    closeAllImages();

}

function getCountedVolume(){

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

    closeAllWindows();
    closeAllImages();


}
