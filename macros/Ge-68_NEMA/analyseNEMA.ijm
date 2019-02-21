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

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //     NEXT:															   //
    //     It will be quicker to make 1024,512,256,128,64 voxel ROIS and then use these for each scale.				   //
    //  If we get the nameing right then we can just set the scale at the start and load everything from there.			   //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
											      
    
    // [x]Open the image and an ROI set (SOURCE)
    // Rescael image (PET voxels) - optional
    // - how do we rescale ROIS properly in Z?
    // [x]Clear the region and set to zero
    // [x]Remove ROIS
    // Gaussian blur (copy image first)
    //    - need to set the size scale (voxel or mm)
    // Load first ROI set and get counts
    // Repeat for all ROIS and store (TARGET)
    // Open next image and repeat

    sources = newArray(6);
    
    // Open the CT data set and point ROIS
    openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_1_0.5_RoiSet.zip", 488);
    printDetails("CT");

    // Scale the image
    getDimensions(width, height, channels, slices, frames);
    s = 2;
    factor = 1.0 / pow(2,s);
    newWidth = floor(width* factor);
    newHeight = floor(height * factor);
    newSlices = floor(slices * factor);
    if(factor < 1){
	run("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
	print("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
	selectWindow("CT");
	close();
	selectWindow("CT-1");
	rename("CT");
    }
    
    // Clear the region ouside the ROIs
    selectWindow("CT");
    clearAll();
    setvalueROImanager(1);

    // Remove ROIS
    //roiManager("reset");

    //Get non-zero pixels
    //sources[0] = countsStack();   
    //run("32-bit");
    
//     // Apply Gaussian blur
//     run("Gaussian Blur 3D...", "x=20 y=20 z=20");

//     // Open the ROIS and measure
//     targets1 = newArray(6); 
//     for (i = 1; i <=6; i++){
// 	selectWindow("CT");
// 	roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_0.5_RoiSet.zip");
// 	roiManager("Deselect");
// 	roiManager("Sort");
// 	targets1[i-1] = countsROImanager();
// 	roiManager("reset");
//     }

//     Array.print(targets1);
//     closeAllImages();

//     // Open the CT data set and point ROIS
//     openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_2_0.5_RoiSet.zip", 488);
//     printDetails("CT");

//     // Scale the image
//     getDimensions(width, height, channels, slices, frames);
//     s = 2;
//     factor = 1.0 / pow(2,s);
//     newWidth = floor(width* factor);
//     newHeight = floor(height * factor);
//     newSlices = floor(slices * factor);
//     if(factor < 1){
// 	run("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	print("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	selectWindow("CT");
// 	close();
// 	selectWindow("CT-1");
// 	rename("CT");
//     }
    
//     // Clear the region ouside the ROIs
//     selectWindow("CT");
//     clearoutsideROImanager();
//     setvalueROImanager(1);

//     // Remove ROIS
//     roiManager("reset");

//     //Get non-zero pixels
//     sources[1] = countsStack();
//     run("32-bit");
    
//     // Apply Gaussian blur
//     run("Gaussian Blur 3D...", "x=20 y=20 z=20");

//     // Open the ROIS and measure
//     targets2 = newArray(6); 
//     for (i = 1; i <=6; i++){
// 	selectWindow("CT");
// 	roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_0.5_RoiSet.zip");
// 	roiManager("Deselect");
// 	roiManager("Sort");
// 	targets2[i-1] = countsROImanager();
// 	roiManager("reset");
//     }

//     Array.print(targets2);
//     closeAllImages();

//     // Open the CT data set and point ROIS
//     openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_3_0.5_RoiSet.zip", 488);
//     printDetails("CT");

//     // Scale the image
//     getDimensions(width, height, channels, slices, frames);
//     s = 2;
//     factor = 1.0 / pow(2,s);
//     newWidth = floor(width* factor);
//     newHeight = floor(height * factor);
//     newSlices = floor(slices * factor);
//     if(factor < 1){
// 	run("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	print("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	selectWindow("CT");
// 	close();
// 	selectWindow("CT-1");
// 	rename("CT");
//     }
    
//     // Clear the region ouside the ROIs
//     selectWindow("CT");
//     clearoutsideROImanager();
//     setvalueROImanager(1);

//     // Remove ROIS
//     roiManager("reset");

//     //Get non-zero pixels
//     sources[2] = countsStack();
//     run("32-bit");

//     // Apply Gaussian blur
//     run("Gaussian Blur 3D...", "x=20 y=20 z=20");

//     // Open the ROIS and measure
//     targets3 = newArray(6); 
//     for (i = 1; i <=6; i++){
// 	selectWindow("CT");
// 	roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_0.5_RoiSet.zip");
// 	roiManager("Deselect");
// 	roiManager("Sort");
// 	targets3[i-1] = countsROImanager();
// 	roiManager("reset");
//     }

//     Array.print(targets3);
//     closeAllImages();



//     // Open the CT data set and point ROIS
//     openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_4_0.5_RoiSet.zip", 488);
//     printDetails("CT");
    
//     // Scale the image
//     getDimensions(width, height, channels, slices, frames);
//     s = 2;
//     factor = 1.0 / pow(2,s);
//     newWidth = floor(width* factor);
//     newHeight = floor(height * factor);
//     newSlices = floor(slices * factor);
//     if(factor < 1){
// 	run("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	print("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	selectWindow("CT");
// 	close();
// 	selectWindow("CT-1");
// 	rename("CT");
//     }
    
//     // Clear the region ouside the ROIs
//     selectWindow("CT");
//     clearoutsideROImanager();
//     setvalueROImanager(1);

//     // Remove ROIS
//     roiManager("reset");

//     //Get non-zero pixels
//     sources[3] = countsStack();
//     run("32-bit");

//     // Apply Gaussian blur
//     run("Gaussian Blur 3D...", "x=20 y=20 z=20");

//     // Open the ROIS and measure
//     targets4 = newArray(6); 
//     for (i = 1; i <=6; i++){
// 	selectWindow("CT");
// 	roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_0.5_RoiSet.zip");
// 	roiManager("Deselect");
// 	roiManager("Sort");
// 	targets4[i-1] = countsROImanager();
// 	roiManager("reset");
//     }

//     Array.print(targets4);
//     closeAllImages();

//     // Open the CT data set and point ROIS
//     openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_5_0.5_RoiSet.zip", 488);
//     printDetails("CT");

//     // Scale the image
//     getDimensions(width, height, channels, slices, frames);
//     s = 2;
//     factor = 1.0 / pow(2,s);
//     newWidth = floor(width* factor);
//     newHeight = floor(height * factor);
//     newSlices = floor(slices * factor);
//     if(factor < 1){
// 	run("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	print("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	selectWindow("CT");
// 	close();
// 	selectWindow("CT-1");
// 	rename("CT");
//     }
    
//     // Clear the region ouside the ROIs
//     selectWindow("CT");
//     clearoutsideROImanager();
//     setvalueROImanager(1);

//     // Remove ROIS
//     roiManager("reset");

//     //Get non-zero pixels
//     sources[4] = countsStack();
//     run("32-bit");


//     // Apply Gaussian blur
//     run("Gaussian Blur 3D...", "x=20 y=20 z=20");

//     // Open the ROIS and measure
//     targets5 = newArray(6); 
//     for (i = 1; i <=6; i++){
// 	selectWindow("CT");
// 	roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_0.5_RoiSet.zip");
// 	roiManager("Deselect");
// 	roiManager("Sort");
// 	targets5[i-1] = countsROImanager();
// 	roiManager("reset");
//     }

//     Array.print(targets5);
//     closeAllImages();

//     // Open the CT data set and point ROIS
//     openDataSetCT("/home/apr/Analysis/NEMA-Ge/PhantomDesign/Data/Empty Phantom/HighDoseCT/0000000a.dcm","/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_6_0.5_RoiSet.zip", 488);
//     printDetails("CT");

//     // Scale the image
//     getDimensions(width, height, channels, slices, frames);
//     s = 2;
//     factor = 1.0 / pow(2,s);
//     newWidth = floor(width* factor);
//     newHeight = floor(height * factor);
//     newSlices = floor(slices * factor);
//     if(factor < 1){
// 	run("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	print("Scale...", "x="+factor+" y="+factor+" z="+factor+" width="+newWidth+" height="+newHeight+" depth="+newSlices+" interpolation=Bilinear average process create");
// 	selectWindow("CT");
// 	close();
// 	selectWindow("CT-1");
// 	rename("CT");
//     }
    
    
//     // Clear the region ouside the ROIs
//     selectWindow("CT");
//     clearoutsideROImanager();
//     setvalueROImanager(1);

//     // Remove ROIS
//     roiManager("reset");

//     //Get non-zero pixels
//     sources[5] = countsStack();
//     run("32-bit");

//     // Apply Gaussian blur
//     run("Gaussian Blur 3D...", "x=20 y=20 z=20");

//     // Open the ROIS and measure
//     targets6 = newArray(6); 
//     for (i = 1; i <=6; i++){
// 	selectWindow("CT");
// 	roiManager("Open", "/home/apr/Analysis/NEMA-Ge/PhantomDesign/ROIS/virtualSphere_"  + i + "_0.5_RoiSet.zip");
// 	roiManager("Deselect");
// 	roiManager("Sort");
// 	targets6[i-1] = countsROImanager();
// 	roiManager("reset");
//     }

//     closeAllImages();

//     Array.print(sources);
//     Array.print(targets1);
//     Array.print(targets2);
//     Array.print(targets3);
//     Array.print(targets4);
//     Array.print(targets5);
//     Array.print(targets6);

//     selectWindow("Log");
//     save("events_" + factor + ".txt");

}


   
