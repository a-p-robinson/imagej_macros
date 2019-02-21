
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


/////////////////////////
// Counting in Stacks: //
/////////////////////////

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
// Get non zero pixels in stack
function nonZeroStack(){

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

/////////////////////////
// Window Manipulation //
/////////////////////////

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

///////////////////
// ROI Functions //
///////////////////

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
// Loop through ROI manger and rescale all ROIs (X and Y)
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
