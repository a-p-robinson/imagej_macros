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

    psf = 0.00;
    factor = 1024;
    
    sources = newArray(9);
    targets1 = newArray(9); 
    targets2 = newArray(9);
    targets3 = newArray(9); 
    targets4 = newArray(9);
    targets5 = newArray(9);
    targets6 = newArray(9);
    targets7 = newArray(9);
    targets8 = newArray(9);
    targets9 = newArray(9);
    
    // Loop through factors
    for (f = 0; f < 3; f++){

	if(f == 0){
	    factor = 1024;
	}
	if(f == 1){
	    factor = 512;
	}
	if(f == 2){
	    factor = 234;
	}
	
	// Loop through PSF
	//for (p = 0; p < 3; p++){
	for (p = 0; p < 2; p++){

	    if(p == 0){
		psf = 15; // mm
	    }
	    if(p == 1){
		psf = 20; // mm
	    }
	    if(p == 2){
		psf = 3; // mm
	    }
	    	    
	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_1_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_1_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_1_"+factor+"_RoiSet.zip", 488);
	    }
    
	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[0] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);

	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets1[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();


	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_2_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_2_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_2_"+factor+"_RoiSet.zip", 488);
	    }
	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
	    sources[1] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets2[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();

	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_3_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_3_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_3_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[2] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets3[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();


	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_4_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_4_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_4_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[3] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets4[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();


	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_5_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_5_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_5_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[4] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets5[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();


	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_6_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_6_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_6_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[5] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets6[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();

	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_7_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_7_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_7_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[6] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets7[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();

	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_8_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_8_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_8_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[7] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets8[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();

	    // Open the CT data set and point ROIS
	    if(factor == 1024){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_9_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 512){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/CTAC/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_9_"+factor+"_RoiSet.zip", 488);
	    }
	    else if(factor == 234){
		openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/MuMap/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_9_"+factor+"_RoiSet.zip", 488);
	    }

	    printDetails("CT");

	    // Clear the region ouside the ROIs
	    selectWindow("CT");
	    clearAll();
	    setvalueROImanager(1);

	    // Remove ROIS
	    roiManager("reset");

	    // Get non-zero pixels
    
	    sources[8] = countsStack();   
	    run("32-bit");
    
	    // Apply Gaussian blur
	    getVoxelSize(vWidth, vHeight, vDepth, unit);
	    p_x = psf / vWidth;
	    p_y = psf / vHeight;
	    p_z = psf / vDepth;
	    run("Gaussian Blur 3D...", "x="+p_x+" y="+p_y+" z="+p_z);


	    // Open the ROIS and measure
	    for (i = 1; i <=9; i++){
		selectWindow("CT");
		roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_"+factor+"_RoiSet.zip");
		roiManager("Deselect");
		roiManager("Sort");
		targets9[i-1] = countsROImanager();
		roiManager("reset");
	    }

	    closeAllImages();
 
	    Array.print(sources);
	    Array.print(targets1);
	    Array.print(targets2);
	    Array.print(targets3);
	    Array.print(targets4);
	    Array.print(targets5);
	    Array.print(targets6);
	    Array.print(targets7);
	    Array.print(targets8);
	    Array.print(targets9);


	    selectWindow("Log");
	    save("events_" + factor + "_" + psf + ".txt");

	    closeAllWindows();

	} // Close PSF
    } // Close factor
} // Close Macro


   
