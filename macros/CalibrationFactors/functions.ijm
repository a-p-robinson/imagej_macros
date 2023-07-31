// SPDX-License-Identifier: GPL-3.0-or-later
// ***********************************************************************
// * Common libary of ImageJ macro functions
// * 
// * Functions can be appended to the end of macro file before runing
// * using runM.sh
// *
// * The functions are roughly grouped in "topic area"
// *
// * Revised APR: 07/02/19
// ***********************************************************************

//------------------------------------------------------------------
// Scale the ROIS in Z
// Position is in mm
function scaleROImanagerSlice(factor){
    count = roiManager("count"); 
    current = roiManager("index"); 
    
    for (i = 0; i < count; i++) { 
	roiManager("select", 0);
	//print("count in loop = " + count + " i = " + i);
	// Translate in Z
	slice = getSliceNumber() * factor;
	moveROIslice(slice); 

    }
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Move the selected ROI to a new(will remove and old ROI)
// Position is in mm
function moveROIslice(slice) { 

    // Store the ROi we were called with
    called = roiManager("index"); 
    //called = 0;    

    // Calculate the new slice
    roiManager("Remove Slice Info");
    oldSlice = getSliceNumber();
    setSlice(slice);

    //print("Processing roi " + called);
    //print("Moving " + oldSlice );
    //print("Now on slice " + getSliceNumber());

    // Move the ROI to the current slice
    roiManager("select", called);
    roiManager("Add");
    
    // Delete the old ROI we were called with
    roiManager("select", called);
    roiManager("Delete");
} 
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and move all ROIS to slice
function moveROImanagerSlice(slice){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("transdZ start = " + current);
    for (i = 0; i < count; i++) { 
	roiManager("select", 0);
	print("count in loop = " + count + " i = " + i);
	// Translate in Z
	moveROIslice(slice); 
	//roiManager("update");
    }

}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Get total counts in Stack
function countsStack(){

    // Remove any ROIS
    roiManager("reset");
    
    getDimensions(width, height, channels, slices, frames);
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Variable for output
    results = 0;

    // Set the measurements we want to make
    run("Set Measurements...", "integrated stack display redirect=None decimal=5");

    for (s=1; s <= nSlices(); s++){
        setSlice(s);
	run("Select All");
	run("Measure");

	results += getResult("RawIntDen");
    
    }

    return results;
}
//------------------------------------------------------------------

//---------------------------------------------------------------------------
// Get non zero pixels in projection
function nonZero(){

    // Get number of non zero pixels
    nonzeroPixels = 0;
    npixels = 0;
    getDimensions(width, height, channels, slices, frames);
    print("Start loop through stack");
    for(s=1; s <= nSlices(); s++){
        setSlice(s);
        for(x=0; x<width; x++){ 
            for(y=0; y<height; y++){ 
                pval=getPixel(x,y); 
                if(pval > 0){
                    nonzeroPixels++;
                }
		npixels++;
            }
        }
    }

    // Return number of pixels
    out = newArray(2);
    out[0] = nonzeroPixels;
    out[1] = npixels;

    return out;

}
//---------------------------------------------------------------------------

//------------------------------------------------------------------
// Generate a sphereical ROI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius of the sphere in mm
function createSphere(x, y, z, R){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
    width = abs(width);
    height = abs(height);
    depth = abs(depth);
    
    // Convert R to voxels
    //radius = R / width;
    //print("Radius = " + R + " mm = " + radius + " voxels");

    
    // Calculate how many slices we need in each direction
    numberSlices = round(R / depth);
    print("Slices (half) = " + numberSlices);
    numberSlices = numberSlices + 2; // Make sure we go past the end with the calcualtion (but not the slices)

    for(i = 0; i <= numberSlices; i++) {

	print("Slice: " + i + " height = " + i*depth);

	// Get the radius for this slice
	// Move the position of the first slice up by the rounding error
	//roundError = round(R / depth) - (R /depth);
	roundError = 0;
	print("RE = " + roundError);
	r = getSegmentRadius(R, i*depth + roundError);
	r = r /width;
	
	// Make sure the radius is valid for this slice
	if(r > 0){

	    // // We have to adjust the centre point to account for the circle being defined from an edge!
	    // cx = sqrt((r*r)/2.0)/width;
	    // cy = sqrt((r*r)/2.0)/height;

	    // xx = (1.0*x) ;
	    // yy = (1.0*y) ;
	    
	    // print("CORRECTION = " + cx + " " + cy + " : " + xx + " " + yy);
	    
	    
	    // If first slice just one ROI
	    if (i == 0){
		setSlice(z);
		makeOval(x-r, y-r, 2*r, 2*r);
		roiManager("Add");
	    }
	    else{
		setSlice(z+i);
		makeOval(x-r, y-r, 2*r, 2*r);
		roiManager("Add");
		setSlice(z-i);
		makeOval(x-r, y-r, 2*r, 2*r);
		roiManager("Add");
	    }
	}
    }

    roiManager("Sort");
    
    // If we have even number of slicesWe may have an odd of total slice then we are okay
    // Otherwise the central slice needs moving down by


    
    // Set the internal zero point of the sphere
    //spZeroX = 0;
    //spZeroY = 0;
    //spZeroZ = 
    
    
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Given a radius and a height from the centre return segment radius
function getSegmentRadius(r,h){

    a = sqrt(r*r - h*h);
    if ((r*r - h*h) < 1){
	a = -99;
    }
    print("Radius = " + a);
    return a;

    
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Open a CT and NM image with an assoicated ROI set
function selectDataSet(){

    // First select the isotope
    isotopes = newArray("177Lu");
    windows = newArray("EM1","EM2");
    Dialog.create("Isotope:");
    Dialog.addChoice("Select Isotope:", isotopes);
    Dialog.addChoice("Select Window:", windows);

    Dialog.show();
    isotope = Dialog.getChoice();
    win = Dialog.getChoice();

    // 177Lu Data
    if (isotope == isotopes[0]){
       
	print(isotope + " [" + win + "]\n");

	choices = newArray("Spleen");

	Dialog.create("Data Set - 177Lu");
	Dialog.addChoice("Select Organ:", choices);
	Dialog.show();

	data = Dialog.getChoice();

	if (data == choices[0]){
	    DataSetID = isotopes[0] + "_Spleen";
	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM1_IRAC001_DS.dcm";
	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM1_IRACSC001_DS.dcm";
	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM1_IRNC001_DS.dcm";

	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM2_IRAC001_DS.dcm";
	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM2_IRACSC001_DS.dcm";
	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM2_IRNC001_DS.dcm";
	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/CT/CTTomo1SPLEEN001_CT001.dcm";
	    nCT = 90;
	    ROIfile = "/home/apr/git/imagej_CalibrationFactors/ROIS/177Lu_Spleen_ROI.zip";
	    errorROIfile512 = "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/177Lu_Spleen512_RoiSet_XYZ.zip";
	    errorROIfile128 = "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/177Lu_Spleen128_RoiSet_XYZ.zip";
	    
	    print("***[Data Set = " + DataSetID + "]***\n");
	}

	// Set correct energy window
	if (win == windows[0]){
	    NMfile = NMfile1;
	    NMfileSC = NMfileSC1;
	    NMfileNC = NMfileNC1;
	}
	if (win == windows[1]){
	    NMfile = NMfile2;
	    NMfileSC = NMfileSC2;
	    NMfileNC = NMfileNC2;
	}

    }

}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Return the total counts in a stack
function totalCounts(){

    // Set the measurements we want to make
    run("Set Measurements...", "integrated stack display redirect=None decimal=5");
    results = 0;

    // Loop through the currently selected stack
    for (i = 1; i <= nSlices(); i++) {
	setSlice(i);
	run("Measure");
	results += getResult("RawIntDen");
    }

    return results;
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Return the error in counts from slices ROI is defined on
function calcSliceErrorVolume(){

    // Get shift (in mm) corresponding to one voxel in X, Y and Z
    getVoxelSize(width, height, depth, unit);

    // Get the number of ROIs
    nrois = roiManager("count");

    // Select first ROI and add to previous slice
    roiManager("Select",0);
    roiManager("Add");
    translateROIdZ(-1*depth);

    // Select the last roi and add to next slice
    roiManager("Select",nrois-2);
    roiManager("Add");
    translateROIdZ(depth);

    // Sort the ROIS
    roiManager("Sort");

    // Array to store four options in
    sliceError = newArray(4);

    roiManager("Select",0);
    run("Measure");
    sliceError[0] = getResult("Area") * depth;

    roiManager("Select",1);
    run("Measure");
    sliceError[1] = getResult("Area") * depth;

    roiManager("Select",roiManager("count")-2);
    run("Measure");
    sliceError[2] = getResult("Area") * depth;

    roiManager("Select",roiManager("count")-1);
    run("Measure");
    sliceError[3] = getResult("Area") * depth;

    // Sort the array
    Array.print(sliceError);
    Array.getStatistics(sliceError, min, max, mean, stdDev);

    print(min + " " + max + " " + mean + " " + stdDev);

    // Return the mean
    return mean;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Return the error in counts from slices ROI is defined on
function calcSliceError(){

    // Array to store four options in
    sliceError = newArray(4);

    // Removing original end slices [0,1]
    roiManager("Select",1);
    run("Measure");
    sliceError[0] = getResult("RawIntDen");

    roiManager("Select",roiManager("count")-2);
    run("Measure");
    sliceError[1] = getResult("RawIntDen");

    // Shifting end slices [2,3]
    roiManager("Select",0);
    run("Measure");
    sliceError[2] = getResult("RawIntDen");

    // Shifting end slices [2,3]
    roiManager("Select",roiManager("count")-1);
    run("Measure");
    sliceError[2] = getResult("RawIntDen");

    // Sort the array
    Array.print(sliceError);
    Array.getStatistics(sliceError, min, max, mean, stdDev);

    print(min + " " + max + " " + mean + " " + stdDev);

    // Return the mean
    return mean;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Generate an ROI set including dZ
function sliceErrorSet(appendString){

    // Reset the ROI manager
    roiManager("reset");

    // Get shift (in mm) corresponding to one voxel in X, Y and Z
    getVoxelSize(width, height, depth, unit);

    // Load the XOR error sets
    roiManager("Open", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_XY.zip");

    // Get the number of ROIs
    nrois = roiManager("count");

    // Select first ROI and add to previous slice
    roiManager("Select",0);
    roiManager("Add");
    translateROIdZ(-1*depth);

    // Select the last roi and add to next slice
    roiManager("Select",nrois-2);
    roiManager("Add");
    translateROIdZ(depth);

    // Sort the ROIS
    roiManager("Sort");

    // Save the error sets
    roiManager("Save", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_XYZ.zip");

}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Merge the ROI error sets in XY
function mergeErrorSetXY(appendString){

    // Reset the ROI manager
    roiManager("reset");

    // If 512 then we need to reopen the rois from disk
    if(appendString == "512"){
	// Open the original ROIs
	roiManager("Open", ROIfile);
    }

    // If 128 then we need to reopen the rois from disk and rescale
    if(appendString == "128"){
	// Open the original ROIs
	roiManager("Open", ROIfile);

	// Calculate the alignment of CT and NM
	delta = calcNMCTalignment(NMfile, CTfile);
	
	// Translate the ROIs from CT to NM in X and Y
	selectWindow("CT");
	translateROImanagerdXdY(delta[0], delta[1]);
	
	// Scale the ROIS to NM on CT (most accrate)
	selectWindow("CT");
	scaleROImanager(factor);

    }

    // Open the four XY error sets
    roiManager("Open", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dx1.zip");
    roiManager("Open", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dx2.zip");
    roiManager("Open", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dy1.zip");
    roiManager("Open", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dy2.zip");
    roiManager("Sort");

    // Get the number of slices with ROIs
    nrois = roiManager("count") / 5.0;

    // Get the total number of rois at start
    count = roiManager("count");

    // Loop through ROIs: XOR, add and delete
    for (i = 0; i < nrois; i++){
    
	// Select the four error ROIs and OR them (combine)
    	roiManager("Select", newArray(1,2,3,4));
    	roiManager("OR");
    	roiManager("Add");

	// Select the first ROI and combined error ROI (latest ROI)
	newlast = roiManager("count") - 1;
	roiManager("Select", newArray(0, newlast));

	// XOR the error with the original
    	roiManager("XOR");
    	roiManager("Add");

	// Remove the combined error ROI
	roiManager("Deselect");
	roiManager("Select",newlast);
    	roiManager("Delete");

	// Remove all the original ROIS (x1 original and x4 errors) 
    	roiManager("Select", newArray(0,1,2,3,4));
    	roiManager("Delete");
    }

    roiManager("Save", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_XY.zip");

}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Create ROI sets corresponding to the positional error in an 
// exisiting ROI set
function calcROIErrorSetsXY(appendString){

    // Get shift (in mm) corresponding to one voxel in X, Y and Z
    getVoxelSize(width, height, depth, unit);

    // Shift ROI set in X (+ve)
    translateROImanagerdXdY(width, 0);
    // Save new ROI set
    roiManager("Save", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dx1.zip");
 
    // Shift ROI set in X (-ve)
    translateROImanagerdXdY(-2.0*width, 0);
    // Save new ROI set
    roiManager("Save", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dx2.zip");

    // Shift ROI set in Y (+ve)
    translateROImanagerdXdY(width, height);
    // Save new ROI set
    roiManager("Save", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dy1.zip");

    // Shift ROI set in Y (-ve)
    translateROImanagerdXdY(0, -2.0*height);
    // Save new ROI set
    roiManager("Save", "/home/apr/git/imagej_CalibrationFactors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dy2.zip");

    // Reset ROI set
    //translateROImanagerdXdY(0, 1.0*height);

    // Shift ROI set in Z (+ve)
    //translateROImanagerdZ(depth);
    // Save new ROI set
    //roiManager("Save", "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dz1.zip");

    // Probably dont need to do this here
    // Shift ROI set in Z (+ve)
    //translateROImanagerdZ(-2.0*depth);
    // Save new ROI set
    //roiManager("Save", "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/" + DataSetID + appendString + "_RoiSet_dz2.zip");


}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Open a CT and six NM image 
function openDataSet6(NMfile1, NMfileSC1, NMfileNC1, NMfile2, NMfileSC2, NMfileNC2, CTfile, nCT){
    // Open NM (NC, AC, ACSC)
    open(NMfile1);
    run("Fire");

    open(NMfileSC1);
    run("Fire");

    open(NMfileNC1);
    run("Fire");

    open(NMfile2);
    run("Fire");

    open(NMfileSC2);
    run("Fire");

    open(NMfileNC2);
    run("Fire");

    // Open CT image sequence
    run("Image Sequence...", "open=" + CTfile + " number=" + nCT + " starting=1 increment=1 scale=100 file=[] sort");

    // // Open ROIs and sort by slice
    // run("ROI Manager...");
    // roiManager("Open", ROIfile);
    // roiManager("Deselect");
    // roiManager("Sort");
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Open a CT and three NM image with an assoicated ROI set
function openDataSet3(NMfile, NMfileSC, NMfileNC, CTfile, nCT, ROIfile){
    // Open NM (NC, AC, ACSC)
    open(NMfile);
    run("Fire");
    rename("NM");

    open(NMfileSC);
    run("Fire");
    rename("NMSC");

    open(NMfileNC);
    run("Fire");
    rename("NMNC");

    // Open CT image sequence
    run("Image Sequence...", "open=" + CTfile + " number=" + nCT + " starting=1 increment=1 scale=100 file=[] sort");

    // Open ROIs and sort by slice
    run("ROI Manager...");
    roiManager("Open", ROIfile);
    roiManager("Deselect");
    roiManager("Sort");
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Open a CT and NM image with an assoicated ROI set
function openDataSet(NMfile, CTfile, nCT, ROIfile){
    // Open NM
    open(NMfile);
    run("Fire");
    rename("NM");

    // Open CT image sequence
    run("Image Sequence...", "open=" + CTfile + " number=" + nCT + " starting=1 increment=1 scale=100 file=[] sort");

    // Open ROIs and sort by slice
    run("ROI Manager...");
    roiManager("Open", ROIfile);
    roiManager("Deselect");
    roiManager("Sort");
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Open a CT data set and  assoicated ROI set
function openDataSetCT(CTfile, ROIfile, num){

    // Open CT image sequence
    run("Image Sequence...", "open=[" + CTfile + "] number=" + num + " sort");
    rename("CT");
    
    // Open ROIs and sort by slice
    run("ROI Manager...");
    roiManager("Open", ROIfile);
    roiManager("Deselect");
    roiManager("Sort");
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Print the geometry details of an image
function printDetails(image){
    selectWindow(image);
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    iWidth = getWidth;
    iHeight = getHeight;
    iDepth = nSlices;
    print("[" + getTitle + "]");
    print("Image size: " + iWidth + "x" + iHeight + "x" + iDepth);
    print("Voxel size: " + vWidth + "x" + vHeight + "x" + vDepth);
    print(" ");
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and return the volume and surface area defined by ROI
// For surface area no interpolation is applied
function getVolumeArea(){
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Get the scale of image
    getVoxelSize(width, height, depth, unit);
    width = abs(width);
    height = abs(height);
    depth = abs(depth);
    
    // Array for output [0] = area [1] = perimeter
    results = newArray(2);

    // How much area did the last ROI enclose?
    lastArea = 0.0;

    // Set the measurements we want to make
    run("Set Measurements...", "area perimeter stack display redirect=None decimal=5");

    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Measure");

	// Sum volumes for each slice
	results[0] += getResult("Area") * depth;

	// Sum the "strips" of surface area defined by perimeter
	results[1] += getResult("Perim.") * depth;

	// For the first slice add the surface area of the outside face
	if (i == 0){
	    print("first strip: " + i); 
	    results[1] += getResult("Area");
	    lastArea = getResult("Area");
	}
	// For all other slices add the difference between areas (overlap in Z)
	else{
	    print("strip: " + i); 
	    results[1] += abs(getResult("Area") - lastArea);
	    lastArea = getResult("Area");
	    
	    // If we are on the last slice then add the area of the other end face
	    if (i == count - 1){
		results[1] += getResult("Area");
		print("last strip: " + i); 
	    }
	}
	
	roiManager("update");
    }

    return results;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Return the sum of the perimeter of all open ROIs in mm
function getSumPerimeter(){
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Get the scale of image
    getVoxelSize(width, height, depth, unit);
    width = abs(width);
    height = abs(height);
    depth = abs(depth);
    
    // Output for perimeter
    results = 0;

    // Set the measurements we want to make
    run("Set Measurements...", "area perimeter stack display redirect=None decimal=5");
    
    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Measure");
	
	results += getResult("Perim.");
	
	roiManager("update");
    }

    return results * depth;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Calculate the alignment between NM and CT from Infinia Hawkeye 4
// NMfile is the dicom file
// CTfile is the first CT dicom in the sequence
//
// Return an array with dX, dY and dZ in mm (for use with translateROImanager(dX, dY, dZ))
function calcNMCTalignment(NMfile, CTfile){

    // Open the files and rename
    open(NMfile);
    rename("_NM");
    run("Image Sequence...", "open=" + CTfile + " number=90 starting=1 increment=1 scale=100 file=[] sort");
    rename("_CT");

    // Extract the Dicom fields -> 0020,0032  Image Position (Patient): 
    selectWindow("_NM");
    NMdicom = split( getInfo("0020,0032"),"\\");
    selectWindow("_CT");
    CTdicom = split( getInfo("0020,0032"),"\\");

    // Calculate the shifts in mm
    // [0] = x (CT - NM), [1] = y (CT - NM), [2] = z (NM - CT)
    delta = newArray(3);
    delta[0] = parseFloat(CTdicom[0]) - parseFloat(NMdicom[0]);
    delta[1] = parseFloat(CTdicom[1]) - parseFloat(NMdicom[1]);
    delta[2] = parseFloat(NMdicom[2]) - parseFloat(CTdicom[2]);

    Array.print(delta);

    // Close the files
    selectWindow("_NM");
    close();
    selectWindow("_CT");
    close();

    return delta;
}

//------------------------------------------------------------------
// Get the statistics for all ROIs defined in the manager
//
function getStatsROImanager(){
    count = roiManager("count"); 
    current = roiManager("index"); 

    res = newArray(2);

    // Loop through the ROIs
    for (i = 0; i < count; i++) { 
	roiManager("select", i); 

	getStatistics(min, max);

	if(i == 0){
	    res[0] = min;
	    res[1] = max;
	}
	else{
	    if(res[0] < min){
		min = res[0];
	    }
	    if(res[1] > max){
		max = res[1];
	    }	    
	}
    }

    return res;
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Clear image outside the ROI manager
function clearoutsideROImanager(){
    count = roiManager("count");
    //print("CCOOUUNNTT == " + count);
    current = roiManager("index"); 

    // Set the background colour
    setBackgroundColor(0, 0, 0);

    // Clear outside the ROIs
    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Clear Outside", "slice");
	
	// Change the value inside the ROI to something
	//run("Set...", "value=15000 slice"); //change ROI value

	// Record the first slice we have cleared
	if (i ==0 ){
	    firstSlice = getSliceNumber();
	}
    }

    // Clear the slices without ROIs
    lastSlice = firstSlice + count - 1;
    //print("1st = " + firstSlice + " last = " + lastSlice + " count = " + count);
    for (i = 1; i <= nSlices(); i++) {
	if(i < firstSlice || i > lastSlice){

	    setSlice(i);
	    run("Select All");
	    run("Clear", "slice");
	}
    }

}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Clear image outside the ROI manager
function clearAll(){
    
    // Set the background colour
    setBackgroundColor(0, 0, 0);

    for (i = 1; i <= nSlices(); i++) {
	setSlice(i);
	run("Select All");
	run("Clear", "slice");
    }
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Clear image outside the ROI manager
function setvalueROImanager(val){
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Set the foreground colour
    setForegroundColor(1, 0, 0);

    // Clear outside the ROIs
    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Set...", "value=" + val + " slice"); //change ROI value
    }

}
//------------------------------------------------------------------



//------------------------------------------------------------------
// Get total counts in ROI manager
function countsROImanager(){
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Variable for output
    results = 0;

    // Set the measurements we want to make
    run("Set Measurements...", "integrated stack display redirect=None decimal=5");

    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Measure");

	results += getResult("RawIntDen");
					      

	roiManager("update");
    }

    return results;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and rescale all ROIs
function scaleROImanager(factor){
    count = roiManager("count"); 
    current = roiManager("index"); 
    print("scale start = " + current);

    for (i = 0; i < count; i++) { 
	roiManager("select", i);
	print("selected " + i);
	scaleROI(factor); 
	print("scaled " + i);
	roiManager("update");
	print("updated " + i);
    }
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and translate all ROIs
// We can move the ROIs by an amount dZ through the stack
// All values in mm
function translateROImanagerdXdYdZ(dX, dY, dZ){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("transdXdYdZ start = " + current);

    for (i = 0; i < count; i++) { 
	roiManager("select", 0);
	
	// Translate in X and Y
	translateROIdXdY(dX, dY); 
	roiManager("update");

	// Translate in Z
	translateROIdZ(dZ);
    }

}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and translate all ROIs
// We can move the ROIs by an amount dZ through the stack
// All values in mm
function translateROImanagerdXdY(dX, dY){
    count = roiManager("count"); 
    current = roiManager("index"); 
    print("transdXdY start = " + current);
    for (i = 0; i < count; i++) { 
	roiManager("select", i);
	
	print("[" + i + "] Current Slice = " + getSliceNumber());

	// Translate in X and Y
	translateROIdXdY(dX, dY); 
	roiManager("update");
    }

}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and translate all ROIs ADDING to manager
// We can move the ROIs by an amount dZ through the stack
// All values in mm
function translateROImanagerAdddXdY(dX, dY){
    count = roiManager("count"); 
    current = roiManager("index"); 
    print("transdXdY start = " + current);
    for (i = 0; i < count; i++) { 
	roiManager("select", i);
	
	print("[" + i + "] Current Slice = " + getSliceNumber());

	// Translate in X and Y
	translateROIAdddXdY(dX, dY); 
	roiManager("update");
    }

}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Loop through ROI manger and translate all ROIs
// We can move the ROIs by an amount dZ through the stack
// All values in mm
function translateROImanagerdZ(dZ){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("transdZ start = " + current);
    for (i = 0; i < count; i++) { 
	roiManager("select", 0);
	//print("count in loop = " + count + " i = " + i);
	// Translate in Z
	translateROIdZ(dZ); 
	//roiManager("update");
    }

}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Scale the currently selected ROI and overwrite
// Position is in mm
function scaleROI(factor) { 
    type = selectionType(); 
    getSelectionCoordinates(x, y); 
    for (i = 0; i < x.length; i++) { 
	//print ("OLD:" + x[i] + " :" + y[i]);
	x[i] = x[i] * factor; 
	y[i] = y[i] * factor;
	//print ("NEW:" + x[i] + " :" + y[i]);
    } 

    makeSelection(type, x, y); 
} 
//------------------------------------------------------------------

//------------------------------------------------------------------
// Translate the selected ROI (will remove and old ROI)
// Position is in mm
function translateROIdZ(dZ) { 

    // Calculate number of slices to shift ROIS
    getVoxelSize(width, height, depth, unit);
    shift = round(dZ / depth);
    //print("dZ = " + dZ + " = " + shift + " voxels");

    // Store the ROi we were called with
    called = roiManager("index"); 
    //called = 0;    

    // Calculate the new slice
    roiManager("Remove Slice Info");
    oldSlice = getSliceNumber();
    setSlice(oldSlice + shift);

    //print("Processing roi " + called);
    //print("Moving " + oldSlice + " to " + oldSlice + shift);
    //print("Now on slice " + getSliceNumber());

    // Move the ROI to the current slice
     roiManager("select", called);
     roiManager("Add");

     // Delete the old ROI we were called with
     roiManager("select", called);
     roiManager("Delete");
} 
//------------------------------------------------------------------

//------------------------------------------------------------------
// Translate the selected ROI (will remove the old ROI)
// Position is in mm
function translateROIdXdY(dX, dY) { 

    // Move the ROI in X and Y
    type = selectionType(); 
    getSelectionCoordinates(x, y); 

    //print("shift = " + dX + " " + dY);

    for (i = 0; i < x.length; i++) { 
	//print ("Old = " + x[i] + " :" + y[i]);
	x[i] = x[i] + dX; 
	y[i] = y[i] + dY; 
	//print ("New = " + x[i] + " :" + y[i]);
    } 
    makeSelection(type, x, y); 

} 
//------------------------------------------------------------------

//------------------------------------------------------------------
// Translate the selected ROI and ADD to manager
// Position is in mm
function translateROIAdddXdY(dX, dY) { 

    // Add the selection so we get a new one
    roiManager("index");
    roiManager("Add");

    // Move the ROI in X and Y
    type = selectionType(); 
    getSelectionCoordinates(x, y); 

    //print("shift = " + dX + " " + dY);

    for (i = 0; i < x.length; i++) { 
	//print ("Old = " + x[i] + " :" + y[i]);
	x[i] = x[i] + dX; 
	y[i] = y[i] + dY; 
	//print ("New = " + x[i] + " :" + y[i]);
    } 
    makeSelection(type, x, y); 

} 
//------------------------------------------------------------------


//---------------------------------------------------------------------------
// Close all open windows with out saving
//
function closeAllWindows(){
    list = getList("window.titles"); 
    for (i=0; i<list.length; i++){ 
	winame = list[i]; 
     	selectWindow(winame); 
	run("Close"); 
    } 
}
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------
// Close all open images without saving
//
function closeAllImages(){
    while (nImages>0) { 
        selectImage(nImages); 
        close(); 
    } 
}
//---------------------------------------------------------------------------




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// // APR:													   //
// //														   //
// // These commented out functions are used by the allAnalysis macros if you want to automate the analysis chain. //
// //														   //
// // You can remove them if you want to clean up the code.							   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// //------------------------------------------------------------------
// // Seperate out picking the data
// function pickData(){
//     isotopes = newArray("177Lu","99mTc");
//     windows = newArray("EM1","EM2");
//     Dialog.create("Isotope:");
//     Dialog.addChoice("Select Isotope:", isotopes);
//     Dialog.addChoice("Select Window:", windows);

//     Dialog.show();
//     isotope = Dialog.getChoice();
//     win = Dialog.getChoice();

//     // 99mTc Data
//     if (isotope == isotopes[1]){
// 	// Organs we can choice from
// 	choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Spleen - Polyjet", "Cylinder ABS (2014)","Cylinder Perspex (2014)", "Cylinder ABS", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "Whole Phantom", "LVS");
	
// 	Dialog.create("Data Set - 99mTc");
// 	Dialog.addChoice("Select Organ:", choices);
// 	Dialog.show();
	
// 	data = Dialog.getChoice();
//     }

//     // 177Lu Data
//     if (isotope == isotopes[0]){
       
// 	print(isotope + " [" + win + "]\n");

// 	choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "LVS", "WholePhantom");

// 	Dialog.create("Data Set - 177Lu");
// 	Dialog.addChoice("Select Organ:", choices);
// 	Dialog.show();

// 	data = Dialog.getChoice();
//     }

//     selectDataSetByID(isotope, win, data);

// }
// //------------------------------------------------------------------

// //------------------------------------------------------------------
// // Open a CT and NM image with an assoicated ROI set
// function selectDataSetByIDnoPostFilter(isotope, win, data){

//     // First select the isotope
//     isotopes = newArray("177Lu","99mTc");
//     windows = newArray("EM1","EM2");

//     // 99mTc Data
//     if (isotope == isotopes[1]){

// 	// Organs we can choice from
// 	choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Spleen - Polyjet", "Cylinder ABS (2014)","Cylinder Perspex (2014)", "Cylinder ABS", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "Whole Phantom", "LVS");

// 	if (data == choices[0]){
// 	    DataSetID = isotopes[1] + "_Spleen";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Spleen/Recon/TomoHwkSPLEEN_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Spleen/Recon/TomoHwkSPLEEN_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Spleen/Recon/TomoHwkSPLEEN_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Spleen/CT/CTTomoHwkSPLEEN001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/2015SpleenRoiSet.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Spleen_ROI_apr_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Spleen512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Spleen128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[1]){
// 	    DataSetID = isotopes[1] + "_Kidney";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney/Recon/TomoHwkKidney_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney/Recon/TomoHwkKidney_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney/Recon/TomoHwkKidney_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney/CT/CTTomoHwkKidney001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/2015KidneyRoiSet.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Kidney_ROI_apr_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[2]){
// 	    DataSetID = isotopes[1] + "_Pancreas";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Pancreas/Recon/TomoHwkPancreas_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Pancreas/Recon/TomoHwkPancreas_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Pancreas/Recon/TomoHwkPancreas_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Pancreas/CT/CTTomoHwkPancreas001_CT001.dcm";
// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/ABSPancreasRoiSet4.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Pancreas512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Pancreas128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[3]){
// 	    DataSetID = isotopes[1] + "_LiverLarge";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/RoiSet_Liver_large4.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Large_ROI_apr_v1.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverLarge512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverLarge128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[4]){
// 	    DataSetID = isotopes[1] + "_LiverSmall";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/RoiSet_Liver_small8.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverSmall512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverSmall128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[5]){
// 	    DataSetID = isotopes[1] + "_LiverTumour";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/ROISet_Liver_insert2.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Tumour_ROI_apr_v1.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTumour512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTumour128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[6]){
// 	    DataSetID = isotopes[1] + "_LiverTotal";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Liver/Recon/TomoHwkLiver_EM_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Combined_ROI_apr.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Combined_ROI_apr3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTotal512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTotal128_RoiSet_XYZ.zip";
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[7]){
// 	    DataSetID = isotopes[1] + "_SpleenPolyjet";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/CT/CTTomoHwkSPLEEN001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/2015Spleen_polyjet_RoiSet.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Spleen_Polyjet_ROI_apr_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_SpleenPolyjet512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_SpleenPolyjet128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[8]){
// 	    DataSetID = isotopes[1] + "_CylinderABS";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/10ml_Cylinder/Recon/Tomo10mlcylinder_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/10ml_Cylinder/Recon/Tomo10mlcylinder_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/10ml_Cylinder/Recon/Tomo10mlcylinder_EM_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/CT/CTTomowater001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/CylinderABS_ROI.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[9]){
// 	    DataSetID = isotopes[1] + "_CylinderPerspex";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRNCOSEM001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/CT/CTTomowater001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/CylinderPerspex_ROI.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderPerspex512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderPerspex128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[10]){
// 	    DataSetID = isotopes[1] + "_CylinderABS2015";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/10ml_Cylinder/Recon/Tomo10mlcylinder_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/10ml_Cylinder/Recon/Tomo10mlcylinder_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/10ml_Cylinder/Recon/Tomo10mlcylinder_EM_IRNC001_DS.dcm";
// 	    CTfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/10ml_Cylinder/CT/CTTomo10mlcylinder001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Cylinder_x1_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS2015512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS2015128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[11]){
// 	    DataSetID = isotopes[1] + "_Kidney5years";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney_5years/Recon/Tomo5yrkidney_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney_5years/Recon/Tomo5yrkidney_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney_5years/Recon/Tomo5yrkidney_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_5years/CT/CTTomo5yrkidney001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Kidney_5years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney5years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney5years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[12]){
// 	    DataSetID = isotopes[1] + "_Kidney10years";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney_10years/Recon/Tomo10yrkidney_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney_10years/Recon/Tomo10yrkidney_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/Kidney_10years/Recon/Tomo10yrkidney_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_10years/CT/CTTomo5yrkidney001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Kidney_10years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney10years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney10years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[13]){
// 	    DataSetID = isotopes[1] + "_LargeSphere";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/LargeSphere/Recon/Tomobigsphere_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/LargeSphere/Recon/Tomobigsphere_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/LargeSphere/Recon/Tomobigsphere_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Large_Sphere/CT/CTTomobigsphere001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/LargeSphere_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LargeSphere512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LargeSphere128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[14]){
// 	    DataSetID = isotopes[1] + "_WholePhantom";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/WholePhantom/Recon/Tomowholephantom_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/WholePhantom/Recon/Tomowholephantom_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/WholePhantom/Recon/Tomowholephantom_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Whole_Phantom/CT/CTTomowholephantom001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/WholePhantom_ROI.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_WholePhantom512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_WholePhantom128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[15]){
// 	    DataSetID = isotopes[1] + "_LVS";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/LVS/Recon/TomoHwkphantom_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/LVS/Recon/TomoHwkphantom_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/99mTc/LVS/Recon/TomoHwkphantom_EM_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/LVS/CT/CTTomoHwkphantom001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/LVS_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LVS512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LVS128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

//     }

//     // 177Lu Data
//     if (isotope == isotopes[0]){
       
// 	choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "LVS", "WholePhantom");

// 	if (data == choices[0]){
// 	    DataSetID = isotopes[0] + "_Spleen";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Spleen/Recon/Tomo1SPLEEN_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Spleen/Recon/Tomo1SPLEEN_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Spleen/Recon/Tomo1SPLEEN_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Spleen/Recon/Tomo1SPLEEN_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Spleen/Recon/Tomo1SPLEEN_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Spleen/Recon/Tomo1SPLEEN_EM1_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/CT/CTTomo1SPLEEN001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Spleen_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Spleen_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Spleen512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Spleen128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[1]){
// 	    DataSetID = isotopes[0] + "_Kidney";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney/Recon/TomoAdultMIRD_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney/Recon/TomoAdultMIRD_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney/Recon/TomoAdultMIRD_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney/Recon/TomoAdultMIRD_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney/Recon/TomoAdultMIRD_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney/Recon/TomoAdultMIRD_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney/CT/CTTomoAdultMIRD001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_ROI.zip";
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_ROI_v2.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[2]){
// 	    DataSetID = isotopes[0] + "_Pancreas";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Pancreas/Recon/Tomo1PANCREAS_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Pancreas/Recon/Tomo1PANCREAS_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Pancreas/Recon/Tomo1PANCREAS_EM1_IRNC001_DS.dcm";
	    
// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Pancreas/Recon/Tomo1PANCREAS_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Pancreas/Recon/Tomo1PANCREAS_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Pancreas/Recon/Tomo1PANCREAS_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/CT/CTTomo1PANCREAS001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Pancreas_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Pancreas_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Pancreas512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Pancreas128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[3]){
// 	    DataSetID = isotopes[0] + "_LiverLarge";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Large_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Large_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverLarge512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverLarge128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[4]){
// 	    DataSetID = isotopes[0] + "_LiverSmall";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Small_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Small_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverSmall512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverSmall128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[5]){
// 	    DataSetID = isotopes[0] + "_LiverTumour";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Tumour_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Tumour_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTumour512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTumour128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[6]){
// 	    DataSetID = isotopes[0] + "_LiverTotal";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";

// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Total_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Total_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTotal512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTotal128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[7]){
// 	    DataSetID = isotopes[0] + "_Kidney5years";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_5years/Recon/Tomo5yrsMIRD_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_5years/Recon/Tomo5yrsMIRD_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_5years/Recon/Tomo5yrsMIRD_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_5years/Recon/Tomo5yrsMIRD_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_5years/Recon/Tomo5yrsMIRD_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_5years/Recon/Tomo5yrsMIRD_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_5years/CT/CTTomo5yrsMIRD001_CT001.dcm";

// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_5years_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_5years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney5years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney5years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[8]){
// 	    DataSetID = isotopes[0] + "_Kidney10years";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_10years/Recon/Tomo10yrsMIRD_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_10years/Recon/Tomo10yrsMIRD_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_10years/Recon/Tomo10yrsMIRD_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_10years/Recon/Tomo10yrsMIRD_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_10years/Recon/Tomo10yrsMIRD_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/Kidney_10years/Recon/Tomo10yrsMIRD_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_10years/CT/CTTomo01yrsMIRD001_CT001.dcm";

// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_10years_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_10years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney10years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney10years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[9]){
// 	    DataSetID = isotopes[0] + "_LargeSphere";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LargeSphere/Recon/Tomo1100MLSPHERE_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LargeSphere/Recon/Tomo1100MLSPHERE_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LargeSphere/Recon/Tomo1100MLSPHERE_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LargeSphere/Recon/Tomo1100MLSPHERE_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LargeSphere/Recon/Tomo1100MLSPHERE_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LargeSphere/Recon/Tomo1100MLSPHERE_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/LargeSphere/CT/CTTomo1100MLSPHERE001_CT001.dcm";

// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/LargeSphere_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/LargeSphere_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LargeSphere512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LargeSphere128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[10]){
// 	    DataSetID = isotopes[0] + "_LVS";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LVS/Recon/Tomo_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LVS/Recon/Tomo_EM1-TEW2_IRAC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LVS/Recon/Tomo_EM1_IRNC001_DS.dcm";


// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LVS/Recon/Tomo_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LVS/Recon/Tomo_EM2-TEW2_IRAC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/LVS/Recon/Tomo_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/CT/CTTomo1001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/LVS_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LVS512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LVS128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[11]){
// 	    DataSetID = isotopes[0] + "_WholePhantom";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/WholePhantom/Recon/Tomo1Central_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/WholePhantom/Recon/Tomo1Central_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/WholePhantom/Recon/Tomo1Central_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/WholePhantom/Recon/Tomo1Central_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/WholePhantom/Recon/Tomo1Central_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/NoPostFilter/177Lu/WholePhantom/Recon/Tomo1Central_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/CT/CTTomo1Central001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/WholePhantom_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_WholePhantom512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_WholePhantom128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}


// 	// Set correct energy window
// 	if (win == windows[0]){
// 	    NMfile = NMfile1;
// 	    NMfileSC = NMfileSC1;
// 	    NMfileNC = NMfileNC1;
// 	}
// 	if (win == windows[1]){
// 	    NMfile = NMfile2;
// 	    NMfileSC = NMfileSC2;
// 	    NMfileNC = NMfileNC2;
// 	}

//     }

// }
// //------------------------------------------------------------------


// //------------------------------------------------------------------
// // Open a CT and NM image with an assoicated ROI set
// function selectDataSetByID(isotope, win, data){

//     // First select the isotope
//     isotopes = newArray("177Lu","99mTc");
//     windows = newArray("EM1","EM2");

//     // 99mTc Data
//     if (isotope == isotopes[1]){

// 	// Organs we can choice from
// 	choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Spleen - Polyjet", "Cylinder ABS (2014)","Cylinder Perspex (2014)", "Cylinder ABS", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "Whole Phantom", "LVS");

// 	if (data == choices[0]){
// 	    DataSetID = isotopes[1] + "_Spleen";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Spleen/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Spleen/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Spleen/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Spleen/CT/CTTomoHwkSPLEEN001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/2015SpleenRoiSet.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Spleen_ROI_apr_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Spleen512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Spleen128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[1]){
// 	    DataSetID = isotopes[1] + "_Kidney";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney/CT/CTTomoHwkKidney001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/2015KidneyRoiSet.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Kidney_ROI_apr_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[2]){
// 	    DataSetID = isotopes[1] + "_Pancreas";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Pancreas/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Pancreas/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Pancreas/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Pancreas/CT/CTTomoHwkPancreas001_CT001.dcm";
// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/ABSPancreasRoiSet4.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Pancreas512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Pancreas128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[3]){
// 	    DataSetID = isotopes[1] + "_LiverLarge";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/RoiSet_Liver_large4.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Large_ROI_apr_v1.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverLarge512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverLarge128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[4]){
// 	    DataSetID = isotopes[1] + "_LiverSmall";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/RoiSet_Liver_small8.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverSmall512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverSmall128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[5]){
// 	    DataSetID = isotopes[1] + "_LiverTumour";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/ROISet_Liver_insert2.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Tumour_ROI_apr_v1.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTumour512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTumour128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[6]){
// 	    DataSetID = isotopes[1] + "_LiverTotal";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Combined_ROI_apr.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Combined_ROI_apr3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTotal512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LiverTotal128_RoiSet_XYZ.zip";
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[7]){
// 	    DataSetID = isotopes[1] + "_SpleenPolyjet";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/Polyjet/Spleen/CT/CTTomoHwkSPLEEN001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/2015Spleen_polyjet_RoiSet.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Spleen_Polyjet_ROI_apr_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_SpleenPolyjet512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_SpleenPolyjet128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[8]){
// 	    DataSetID = isotopes[1] + "_CylinderABS";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/CT/CTTomowater001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/CylinderABS_ROI.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[9]){
// 	    DataSetID = isotopes[1] + "_CylinderPerspex";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/Recon/EM/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2014/Data/x2_Cylinders/Water/CT/CTTomowater001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/CylinderPerspex_ROI.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderPerspex512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderPerspex128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[10]){
// 	    DataSetID = isotopes[1] + "_CylinderABS2015";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/10ml_Cylinder/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/10ml_Cylinder/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/10ml_Cylinder/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/10ml_Cylinder/CT/CTTomo10mlcylinder001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Cylinder_x1_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS2015512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_CylinderABS2015128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[11]){
// 	    DataSetID = isotopes[1] + "_Kidney5years";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_5years/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_5years/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_5years/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_5years/CT/CTTomo5yrkidney001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Kidney_5years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney5years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney5years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[12]){
// 	    DataSetID = isotopes[1] + "_Kidney10years";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_10years/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_10years/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_10years/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Kidney_10years/CT/CTTomo5yrkidney001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Kidney_10years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney10years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_Kidney10years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[13]){
// 	    DataSetID = isotopes[1] + "_LargeSphere";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Large_Sphere/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Large_Sphere/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Large_Sphere/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Large_Sphere/CT/CTTomobigsphere001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/LargeSphere_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LargeSphere512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LargeSphere128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[14]){
// 	    DataSetID = isotopes[1] + "_WholePhantom";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Whole_Phantom/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Whole_Phantom/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Whole_Phantom/Recon/IRNCOSEM001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Whole_Phantom/CT/CTTomowholephantom001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/WholePhantom_ROI.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_WholePhantom512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_WholePhantom128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[15]){
// 	    DataSetID = isotopes[1] + "_LVS";
// 	    NMfile   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/LVS/Recon/TomoHwkphantom_EM_IRAC001_DS.dcm";
// 	    NMfileSC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/LVS/Recon/TomoHwkphantom_EM_IRACSC001_DS.dcm";
// 	    NMfileNC = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/LVS/Recon/TomoHwkphantom_EM_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/LVS/CT/CTTomoHwkphantom001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/LVS_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LVS512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/99mTc_LVS128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

//     }

//     // 177Lu Data
//     if (isotope == isotopes[0]){
       
// 	choices = newArray("Spleen", "Kidney", "Pancreas", "Liver - large", "Liver - small", "Liver - tumour", "Liver - Total", "Kidney 5yrs", "Kidney 10yrs", "Large Sphere", "LVS", "WholePhantom");

// 	if (data == choices[0]){
// 	    DataSetID = isotopes[0] + "_Spleen";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/Recon/Tomo1SPLEEN_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Spleen/CT/CTTomo1SPLEEN001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Spleen_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Spleen_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Spleen512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Spleen128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[1]){
// 	    DataSetID = isotopes[0] + "_Kidney";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney/EM1/TomoAdultMIRD_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney/Recon/TomoAdultMIRD_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney/Recon/IRNCOSEM001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney/EM2/TomoAdultMIRD_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney/Recon/TomoAdultMIRD_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney/Recon/IRNCOSEM002_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney/CT/CTTomoAdultMIRD001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_ROI.zip";
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_ROI_v2.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[2]){
// 	    DataSetID = isotopes[0] + "_Pancreas";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/Recon/Tomo1PANCREAS_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/Recon/Tomo1PANCREAS_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/Recon/Tomo1PANCREAS_EM1_IRNC001_DS.dcm";
	    
// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/Recon/Tomo1PANCREAS_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/Recon/Tomo1PANCREAS_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/Recon/Tomo1PANCREAS_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Pancreas/CT/CTTomo1PANCREAS001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Pancreas_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Pancreas_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Pancreas512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Pancreas128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[3]){
// 	    DataSetID = isotopes[0] + "_LiverLarge";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM1/Tomo1LIVER_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM2/Tomo1LIVER_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Large_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Large_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverLarge512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverLarge128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[4]){
// 	    DataSetID = isotopes[0] + "_LiverSmall";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM1/Tomo1LIVER_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM2/Tomo1LIVER_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Small_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Small_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverSmall512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverSmall128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[5]){
// 	    DataSetID = isotopes[0] + "_LiverTumour";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM1/Tomo1LIVER_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM2/Tomo1LIVER_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Tumour_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Tumour_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTumour512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTumour128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[6]){
// 	    DataSetID = isotopes[0] + "_LiverTotal";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM1/Tomo1LIVER_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Liver/EM2/Tomo1LIVER_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/Recon/Tomo1LIVER_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Liver/CT/CTTomo1LIVER001_CT001.dcm";
// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Total_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Liver_Total_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTotal512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LiverTotal128_RoiSet_XYZ.zip";
	    
// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[7]){
// 	    DataSetID = isotopes[0] + "_Kidney5years";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney_5yrs/EM1/Tomo5yrsMIRD_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_5years/Recon/Tomo5yrsMIRD_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_5years/Recon/IRNCOSEM001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney_5yrs/EM2/Tomo5yrsMIRD_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_5years/Recon/Tomo5yrsMIRD_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_5years/Recon/IRNCOSEM002_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_5years/CT/CTTomo5yrsMIRD001_CT001.dcm";

// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_5years_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_5years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney5years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney5years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[8]){
// 	    DataSetID = isotopes[0] + "_Kidney10years";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney_10yrs/EM1/Tomo10yrsMIRD_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_10years/Recon/Tomo10yrsMIRD_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_10years/Recon/IRNCOSEM001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney_10yrs/EM2/Tomo10yrsMIRD_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_10years/Recon/Tomo10yrsMIRD_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_10years/Recon/IRNCOSEM002_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Kidney_10years/CT/CTTomo01yrsMIRD001_CT001.dcm";

// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_10years_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/Kidney_10years_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney10years512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_Kidney10years128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[9]){
// 	    DataSetID = isotopes[0] + "_LargeSphere";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney_10yrs/EM1/Tomo10yrsMIRD_EM1_IRAC002_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/LargeSphere/Recon/Tomo1100MLSPHERE_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/LargeSphere/Recon/Tomo1100MLSPHERE_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/optimising_reconstruction/Data/177Lu/Kidney_10yrs/EM2/Tomo10yrsMIRD_EM2_IRAC002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/LargeSphere/Recon/Tomo1100MLSPHERE_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/LargeSphere/Recon/Tomo1100MLSPHERE_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/LargeSphere/CT/CTTomo1100MLSPHERE001_CT001.dcm";

// 	    nCT = 90;
// 	    //ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/LargeSphere_ROI.zip";
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/LargeSphere_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LargeSphere512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LargeSphere128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[10]){
// 	    DataSetID = isotopes[0] + "_LVS";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/Recon/IRACOSEM001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/Recon/IRACSCOSEM001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/Recon/IRNCOSEM001_DS.dcm";


// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/Recon/IRACOSEM002_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/Recon/IRACSCOSEM002_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/Recon/IRNCOSEM002_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/LVS/CT/CTTomo1001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/LVS_ROI_v3.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LVS512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_LVS128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}

// 	if (data == choices[11]){
// 	    DataSetID = isotopes[0] + "_WholePhantom";
// 	    NMfile1   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/Recon/Tomo1Central_EM1_IRAC001_DS.dcm";
// 	    NMfileSC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/Recon/Tomo1Central_EM1_IRACSC001_DS.dcm";
// 	    NMfileNC1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/Recon/Tomo1Central_EM1_IRNC001_DS.dcm";

// 	    NMfile2   = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/Recon/Tomo1Central_EM2_IRAC001_DS.dcm";
// 	    NMfileSC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/Recon/Tomo1Central_EM2_IRACSC001_DS.dcm";
// 	    NMfileNC2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/Recon/Tomo1Central_EM2_IRNC001_DS.dcm";
// 	    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/177Lu/ABS/Whole_Phantom/CT/CTTomo1Central001_CT001.dcm";

// 	    nCT = 90;
// 	    ROIfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/177Lu/WholePhantom_ROI_v2.zip";
// 	    errorROIfile512 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_WholePhantom512_RoiSet_XYZ.zip";
// 	    errorROIfile128 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/errors/177Lu_WholePhantom128_RoiSet_XYZ.zip";

// 	    print("***[Data Set = " + DataSetID + "]***\n");
// 	}


// 	// Set correct energy window
// 	if (win == windows[0]){
// 	    NMfile = NMfile1;
// 	    NMfileSC = NMfileSC1;
// 	    NMfileNC = NMfileNC1;
// 	}
// 	if (win == windows[1]){
// 	    NMfile = NMfile2;
// 	    NMfileSC = NMfileSC2;
// 	    NMfileNC = NMfileNC2;
// 	}

//     }

// }
// //------------------------------------------------------------------
