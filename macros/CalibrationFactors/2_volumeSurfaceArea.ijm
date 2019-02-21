// ***********************************************************************
// * Load in a CT file and associated ROI set and 
// *  - Get volume and surface area for 512x512 and 128x128 voxels
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

macro "volumeSurfaceArea" {

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    // Open the data set
    openDataSet(NMfile, CTfile, nCT, ROIfile);

    // Print CT image details
    printDetails("CT");

    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    iWidth = getWidth;
    iHeight = getHeight;
    iDepth = nSlices;

    // Resize the CT image
    selectWindow("CT");
    newTitle = "CT_" +iWidth * factor + "x" +  iHeight * factor;
    run("Scale...", "x=- y=- z=1.0 width=" + iWidth * factor + " height=" + iHeight * factor + " depth=90 interpolation=Bilinear process create title=" + newTitle);
    
    // Select the original CT
    selectWindow("CT");

    //-------------------------------------------------------------------------------------------------------------------
    // 512x512

    // Measure volume and surface area
    geometry = newArray(2);
    geometry = getVolumeArea();

    // Also get the sum of the perimeter
    sumPerim = getSumPerimeter();

    print("Original sumPerim = " + sumPerim);

    // Find out the mean change in counts for +/- a slice at either end
    sigma_rdZ = calcSliceErrorVolume();
    sigma_rdZ /= 2; // Take an average of each end
  
    // Remove ROIS
    roiManager("Reset");

    // Open error ROIS
    roiManager("Open", errorROIfile512);

    // Get error
    sigma_geometry = newArray(2);
    sigma_geometry = getVolumeArea();

    // Divide the volume error by 4 (X and Y)
    sigma_geometry[0] /= 4;

    // Get the sum of perimeter for error ROIS
    sumPerimError = getSumPerimeter();
    print("Error sumPerim = " + sumPerimError);

    // Calculate the change and divide by 6 (X and Y and Z)
    sigma_geometry[1] = (sumPerimError - sumPerim) / 6.0;  // Surface area change
    //-------------------------------------------------------------------------------------------------------------------

    //-------------------------------------------------------------------------------------------------------------------
    // 128x128

    // Select 128 window
    selectWindow(newTitle);

    // Remove ROIS
    roiManager("Reset");

    // Open original ROIs
    roiManager("Open",ROIfile);




    // Calculate the alignment of CT and NM
    delta = calcNMCTalignment(NMfile, CTfile);

    //------------------------------------------------------------------------------------------------
    // Translate the ROIs from CT to NM in X and Y
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(factor);




    // Resize the ROIs in the manager
    //scaleROImanager(factor);

    // Select the rescaled image
    selectWindow(newTitle);

    // Print image details
    print(" ");
    printDetails(newTitle);

    // Measure volume and surface area
    geometry_rs = newArray(2);
    geometry_rs = getVolumeArea();

    // Also get the sum of the perimeter
    sumPerim_rs = getSumPerimeter();

    // Find out the mean change in counts for +/- a slice at either end
    sigma_rdZ_rs = calcSliceErrorVolume();
    sigma_rdZ_rs /= 2; // Take an average of each end

    // Remove ROIS
    roiManager("Reset");

    // Open error ROIS - no need to rescale them
    roiManager("Open", errorROIfile128);

    // Get error
    sigma_geometry_rs = newArray(2);
    sigma_geometry_rs = getVolumeArea();

    // Divide the volume error by 4 (X and Y)
    sigma_geometry_rs[0] /= 4;

    // Get the sum of perimeter for error ROIS
    sumPerimError_rs = getSumPerimeter();
    print("Error sumPerim = " + sumPerimError_rs);

    // Calculate the change and divide by 6 (X and Y and Z)
    sigma_geometry_rs[1] = (sumPerimError_rs - sumPerim_rs) / 6.0;  // Surface area change
    //-------------------------------------------------------------------------------------------------------------------

    print("512 x 512:");
    print("ROI Volume = " + geometry[0] + " (" + sigma_geometry[0] + " + " + sigma_rdZ + ")" + " " + unit + "^3");
    print("   Error = " + ((sigma_geometry[0] + sigma_rdZ)/ geometry[0]) * 100 + " %");
    print("ROI Surface Area = " + geometry[1] + " (" + sigma_geometry[1] + ")"+ " " + unit + "^2");
    print("   Error = " + ((sigma_geometry[1]) / geometry[1]) * 100 + " %");
    print(" ");
    print("128 x 128:");
    print("ROI Volume = " + geometry_rs[0] + " (" + sigma_geometry_rs[0] + " + " + sigma_rdZ_rs + ")" + " " + unit + "^3"); 
    print("   Error = " + ((sigma_geometry_rs[0] + sigma_rdZ_rs) / geometry_rs[0]) * 100 + " %");
    print("ROI Surface Area = " + geometry_rs[1] + " (" + sigma_geometry_rs[1] + ")"+ " " + unit + "^2");
    print("   Error = " + ((sigma_geometry_rs[1]) / geometry_rs[1]) * 100 + " %");

    // Save the output
    selectWindow("Log");
    save(DataSetID + "_volumeSurfaceArea.txt");

}
