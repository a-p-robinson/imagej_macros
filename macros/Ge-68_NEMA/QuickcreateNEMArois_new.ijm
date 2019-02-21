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

macro "QuickcreateNEMArois" {


    //---------------
    // 1024 x 1024
    //---------------
    
    // Open the CT data set and point ROIS
    openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/RoiSet-Centres_1024_new.zip", 488);
    
    factor = 1024;
    
    //Print CT image details
    print("FACTOR = " + factor);
    printDetails("CT");
    
    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    
    // Read the x,y,z for each ROI (Sphere1 to Sphere6)
    count = roiManager("count");
    sphereX = newArray(3);
    sphereY = newArray(3);
    sphereZ = newArray(3);
    
    for (i = 0; i < count; i++) {
	roiManager("select", i);
	getSelectionCoordinates(x, y);
	Array.print(x);
	Array.print(y);
	
	sphereX[i] = x[0];
	sphereY[i] = y[0];
	sphereZ[i] = getSliceNumber();
    }
	
    // Clear ROI manager
    roiManager("reset");
	
    // Store the radi
    sphereR = newArray(2.5,2.5,2.5);
	
    Array.print(sphereX);
    Array.print(sphereY);
    Array.print(sphereZ);
    Array.print(sphereR);
	
    // Loop through Spheres
    for (i = 0; i < sphereX.length; i++) {
	
	// Create the sphere ROIS 
	createSphere(sphereX[i],sphereY[i],sphereZ[i],sphereR[i]);
	
	// Save the ROIS
	roiManager("Save", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_" + (i+7) + "_" + factor + "_RoiSet.zip");
	
	// Clear ROI manager
	roiManager("reset");
    }
    
    roiManager("reset");
    selectWindow("CT");
    close();


    //---------------
    // 512 x 512
    //---------------
    
    // Open the CT data set and point ROIS
    openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/RoiSet-Centres_512_new.zip", 124);

    factor = 512;
    
    //Print CT image details
    print("FACTOR = " + factor);
    printDetails("CT");
    
    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    
    // Read the x,y,z for each ROI (Sphere1 to Sphere6)
    count = roiManager("count");
    sphereX = newArray(3);
    sphereY = newArray(3);
    sphereZ = newArray(3);
    
    for (i = 0; i < count; i++) {
    	roiManager("select", i);
    	getSelectionCoordinates(x, y);
    	Array.print(x);
    	Array.print(y);
	
    	sphereX[i] = x[0];
    	sphereY[i] = y[0];
    	sphereZ[i] = getSliceNumber();
    }
	
    // Clear ROI manager
    roiManager("reset");
	
    // Store the radi
    sphereR = newArray(2.5,2.5,2.5);
	
    Array.print(sphereX);
    Array.print(sphereY);
    Array.print(sphereZ);
    Array.print(sphereR);
	
    // Loop through Spheres
    for (i = 0; i < sphereX.length; i++) {
	
    	// Create the sphere ROIS 
    	createSphere(sphereX[i],sphereY[i],sphereZ[i],sphereR[i]);
	
    	// Save the ROIS
    	roiManager("Save", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_" + (i+7) + "_" + factor + "_RoiSet.zip");
	
    	// Clear ROI manager
    	roiManager("reset");
    }

    roiManager("reset");
    selectWindow("CT");
    close();

    //---------------
    // 234 x 234
    //---------------
    
    // Open the CT data set and point ROIS
    openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/RoiSet-Centres_234_new.zip", 124);

    factor = 234;
    
    //Print CT image details
    print("FACTOR = " + factor);
    printDetails("CT");
    
    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    
    // Read the x,y,z for each ROI (Sphere1 to Sphere6)
    count = roiManager("count");
    sphereX = newArray(3);
    sphereY = newArray(3);
    sphereZ = newArray(3);
    
    for (i = 0; i < count; i++) {
    	roiManager("select", i);
    	getSelectionCoordinates(x, y);
    	Array.print(x);
    	Array.print(y);
	
    	sphereX[i] = x[0];
    	sphereY[i] = y[0];
    	sphereZ[i] = getSliceNumber();
    }
	
    // Clear ROI manager
    roiManager("reset");
	
    // Store the radi
    sphereR = newArray(2.5,2.5,2.5);
	
    Array.print(sphereX);
    Array.print(sphereY);
    Array.print(sphereZ);
    Array.print(sphereR);
	
    // Loop through Spheres
    for (i = 0; i < sphereX.length; i++) {
	
    	// Create the sphere ROIS 
    	createSphere(sphereX[i],sphereY[i],sphereZ[i],sphereR[i]);
	
    	// Save the ROIS
    	roiManager("Save", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_" + (i+7) + "_" + factor + "_RoiSet.zip");
	
    	// Clear ROI manager
    	roiManager("reset");
    }
    
}


