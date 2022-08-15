/* 
Transfer a CT based ROI to a nuclear medicine image
*/
macro "makeNucMedROI" {

    // Get the data names from arguments
    args = parseArguments();    
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Open the CT image
    openCTData(cameraID, phantomID); 

    // Open the ROIs
    openROI(cameraID, phantomID, roiID);
    
    // Open the Nuc Med reconstructed image
    openNMData(cameraID, phantomID);


    // Calculate the alignment of CT and NM in mm
    delta = calcNMCTalignment("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    Array.print(delta);
    Array.print(scale);

    // Translate the ROIs from CT to NM in X and Y
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);
    
    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanager("NM", "CT", delta[2]);

    // Save the ROI dataset
    roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
    roiManager("Save", roiDirectory + cameraID + "_" + phantomID + roiID + "_NM_RoiSet_XYZ.zip");

} 
// ***********************************************************************
// * Common libary of ImageJ macro functions
// * 
// * Functions can be appended to the end of macro file before running
// * using runM.sh
// 
// * Revised APR: 01/08/22
// ***********************************************************************

// Parse the passed arguments and get the dataset to open
function parseArguments(){

    // Get the data names from arguments
    args = split(getArgument(), " ");
    cameraID = args[0];
    phantomID = args[1];

    if (args.length < 2){
        print("ERROR: must specify at least 2 arguments (camera phantom");
        Array.print(args);
        exit();
    }


    if (phantomID == "Sphere1"){
        if (args.length != 3){
            print("ERROR: must specify 3 arguments (camera phantom sphereID");
            Array.print(args);
            exit();
        }
    
        roiID = args[2];
    }
    else{
        roiID = "_CT";
    }

    // Construct array to return
    res = newArray(3);
    res[0] = cameraID;
    res[1] = phantomID;
    res[2] = roiID;

    return res;
}

// Open the correct CT image for the specified dataset
function openCTData(cameraID, phantomID){

    if (cameraID == "DR" && phantomID == "Cylinder"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/Cylinder/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
        CTslices = 321;
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Cylinder"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/WEHR/Cylinder/CT/CTAC5mmCYLINDER_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Cylinder"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/MEHRS/Cylinder/CT/CTAC5mmCYLINDER_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "Optima" && phantomID == "Cylinder"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/Optima/Cylinder/CT/CTSPECT-CT_H_1001_CT001.dcm";
        CTslices = 161;
    }

    if (cameraID == "DR" && phantomID == "Sphere1"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/Sphere1/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
        CTslices = 321;
    }

    if (cameraID == "Optima" && phantomID == "Sphere1"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/Optima/Sphere1/CT/CTSPECT-CT_H_1001_CT001.dcm";
        CTslices = 161;
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Sphere1"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/WEHR/Sphere1/CT/CTAC5mmSPHERES1_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Sphere1"){
        CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/MEHRS/Sphere1/CT/CTAC5mmSPHERES1_H_1001_CT001.dcm";
        CTslices = 80;
    }


    run("Image Sequence...", "open=" + CTfile + " number=" + CTslices + " starting=1 increment=1 scale=100 file=[] sort");
    rename("CT");
}

// Open the ROI set
function openROI(cameraID, phantomID, roiID){

    roiFile = "/home/apr/Science/GE-RSCH/QI/analysis/rois/"+cameraID+ "_" + phantomID + roiID + "_RoiSet_XYZ.zip";
    roiManager("Open",roiFile);

}

// Open the Sphere Centres
function openCTsphereCentres(cameraID, phantomID){

    roiFile = "/home/apr/Science/GE-RSCH/QI/analysis/rois/centres/"+cameraID+ "_" + phantomID + "_CT_Centres_RoiSet.zip";
    roiManager("Open",roiFile);

}

// Open the correct NM image for the specified dataset
function openNMData(cameraID, phantomID){

    if (cameraID == "DR" && phantomID == "Cylinder"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/Cylinder/Recon/SPECTCT_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Cylinder"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/WEHR/Cylinder/Recon/CYLINDER_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Cylinder"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/MEHRS/Cylinder/Recon/CYLINDER_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "Optima" && phantomID == "Cylinder"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/Optima/Cylinder/Recon/SPECT-CT_EM2_IRAC001_DS.dcm";      
    }

    if (cameraID == "DR" && phantomID == "Sphere1"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/Sphere1/Recon/SPECTCT_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Sphere1"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/WEHR/Sphere1/Recon/SPHERES1_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Sphere1"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/CZT/MEHRS/Sphere1/Recon/SPHERES1MEHRS_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "Optima" && phantomID == "Sphere1"){
        NMfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/Optima/Sphere1/Recon/SPECT-CT_EM2_IRAC001_DS.dcm";      
    }

    open(NMfile);
    rename("NM");
    run("Fire");
}

// Return the centre slice of a CT image based on the profile
function centreSliceCT(){

    // Get slice thickness 
    getVoxelSize(width, height, depth, unit);
    
    run("Reslice [/]...", "output="+depth+" start=Top avoid");
    selectWindow("Reslice of CT");
    setSlice(nSlices()/2);
    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    setKeyDown("alt"); ct_z = getProfile();
    //run("Plot Profile");

    ct_z_max = Array.findMaxima(ct_z,0.00001);
    ct_z_min = Array.findMinima(ct_z,0.00001);
    ct_z_half = (ct_z[ct_z_max[0]]+ct_z[ct_z_min[0]])/2;
    
    centre_z = centreProfile(ct_z, ct_z_half);
    close();
    
    return round(centre_z);
}

// Return the centre of a profile based on values passing threshold twice
function centreProfile(profile, threshold){

    for (i = 0; i < profile.length / 2; i++){
        if (profile[i] < threshold){
            lower = i;
        }
        if (profile[profile.length-i-1] < threshold){
            upper = profile.length-i-1;
        }
    }
    centre = (upper + lower) / 2;
    //print("lower: " + lower + " upper: " + upper + " centre: " + centre);
    return centre;
}

//------------------------------------------------------------------
// Generate cylindrical VOI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius in mm
//  - H is the height in mm
function createCylinder(x, y, z, R, H){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
  
    // See how many slices we need
    ns = round(H / depth);
    print("H = " + H + " nSlices = " + ns + " depth = " + depth);

    // If this is odd then we add an even number of slices either slide of z
    // If it is even then we have to go 1 more slice on one slide or the other...!
    if (ns%2 == 1){
        first_slice = z - floor(ns/2);
        last_slice  = z + floor(ns/2);
    }
    if (ns%2 == 0){
        first_slice = z - floor(ns/2);
        last_slice  = z + floor(ns/2) - 1;
    }

    // Check we haven't gone off the end of image
    if(first_slice < 0){
        first_slice = 1;
    }
    if(last_slice > nSlices){
        last_slice = nSlices;
    }
    // print("First: " + first_slice + " Last: :" + last_slice);
    // print(floor(ns/2));
    // print(z);

    for (i = first_slice; i <= last_slice; i++){
        createCircle(x, y, i, R);
    }
	    
}

//------------------------------------------------------------------
// Generate circular ROI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius in mm
function createCircle(x, y, z, R){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
    // width = abs(width);
    // height = abs(height);
    // depth = abs(depth);
    
    // Convert R to voxels
    r = R / width;
    //print("Radius = " + R + " mm = " + r + " voxels");
	
    setSlice(z);
    makeOval(x-r, y-r, 2*r, 2*r);
	roiManager("Add");
	    
}


//------------------------------------------------------------------
// Calculate the alignment between NM and CT from Infinia Hawkeye 4
// NMname is the open nuclear medicine image to use
// CTname is the open CT image to use
//
// Return an array with dX, dY and dZ in mm (for use with translateROImanager(dX, dY, dZ))
function calcNMCTalignment(NMname, CTname){

    // Extract the Dicom fields -> 0020,0032  Image Position (Patient): 
    selectWindow(NMname);
    NMdicom = split( getInfo("0020,0032"),"\\");
    selectWindow(CTname);
    CTdicom = split( getInfo("0020,0032"),"\\");

    // Calculate the shifts in mm
    // [0] = x (CT - NM), [1] = y (CT - NM), [2] = z (NM - CT)
    delta = newArray(3);
    delta[0] = parseFloat(CTdicom[0]) - parseFloat(NMdicom[0]);
    delta[1] = parseFloat(CTdicom[1]) - parseFloat(NMdicom[1]);
    delta[2] = parseFloat(NMdicom[2]) - parseFloat(CTdicom[2]);

    return delta;
}

//------------------------------------------------------------------
// Calculate the scale between NM and CT from Infinia Hawkeye 4
// NMname is the open nuclear medicine image to use
// CTname is the open CT image to use
//
// Return an array with scaleX, scaleY and scaleZ 
function calcNMCTscale(NMname, CTname){

    // Extract the voxel sizes
    selectWindow(NMname);
    getVoxelSize(nm_width, nm_height, nm_depth, nm_unit);
    selectWindow(CTname);
    getVoxelSize(ct_width, ct_height, ct_depth, ct_unit);
    
    print(nm_width + " " + nm_height+ " " + nm_depth+ " " + nm_unit);
    print(ct_width + " " + ct_height+ " " + ct_depth+ " " + ct_unit);


    // Calculate the scale
    // [0] = x (CT / NM), [1] = y (CT / NM), [2] = z (NM / CT)
    delta = newArray(3);
    delta[0] = ct_width / nm_width;
    delta[1] = ct_height / nm_height;
    delta[2] = ct_depth / nm_depth;

    return delta;
}

//------------------------------------------------------------------
// Loop through ROI manger and translate all ROIs
// We can move the ROIs by an amount dZ through the stack
// All values in mm
function translateROImanagerdXdY(dX, dY){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("transdXdY start = " + current);
    
    for (i = 0; i < count; i++) { 
	    roiManager("select", i);
	
	    //print("[" + i + "] Current Slice = " + getSliceNumber());

	    // Translate in X and Y
	    translateROIdXdY(dX, dY); 
	    roiManager("update");
    }

}

//------------------------------------------------------------------
// Translate the selected ROI (will remove the old ROI)
// Position is in mm
function translateROIdXdY(dX, dY) { 

    // Move the ROI in X and Y
    //type = selectionType();
    type = Roi.getType ;
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
// Loop through ROI manger and rescale all ROIs
function scaleROImanager(factor){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("scale start = " + current);

    for (i = 0; i < count; i++) { 
        roiManager("select", i);
        //print("selected " + i);
        scaleROI(factor); 
        //print("scaled " + i);
        roiManager("update");
        //print("updated " + i);
    }
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Scale the currently selected ROI and overwrite
// Position is in mm
function scaleROI(factor) { 
    //type = selectionType();
    type = Roi.getType ; 
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
// Loop through ROI manger and move each ROI to the corresponding NM slice
// - dZ = shift in CT / NM position in mm
// - NMname = Nuclear medicine image to use
// - CTname = CT image to use
function ctToNMROImanager(NMname, CTname, dZ){

    // Extract the voxel sizes
    selectWindow(NMname);
    getVoxelSize(nm_width, nm_height, nm_depth, nm_unit);
    nmSlicesMax = nSlices;
    print(nmSlicesMax);
    selectWindow(CTname);
    getVoxelSize(ct_width, ct_height, ct_depth, ct_unit);

    // Calculate variable we need
    dZ = dZ / ct_depth; // now in units of CT slices

    count = roiManager("count"); 
    current = roiManager("index"); 

    for (i = 0; i < count; i++) { 
        selectWindow("CT");
        roiManager("select", 0); // New ROI goes to bottom so always pick "top" next
        ctSlice = getSliceNumber();
        nmSlice = (ctSlice + dZ) * abs(ct_depth / nm_depth);
    
        // Check we are not going off the end of the NM image
        if (round(nmSlice) > nmSlicesMax-1){
            nmSlice = nmSlicesMax-1;
        }

        print("[" + i +"] CT Slice: " + ctSlice + " ---> NM Slice: " + nmSlice + " (" + round(nmSlice) + ")" );

        selectWindow("NM");
        moveROIslice(round(nmSlice));

    }

    // Now merge the ROIS on the same slice (only need to do this if we have multiple ROIs)
    currentSlice = -99;
    if (count > 1){
    
        //print("will process " + count + " rois");
        for (i = 0; i < count; i++) { 
            //print("i="+i);
            roiManager("select", i);
            thisSlice = getSliceNumber();
        
            if (i == 0){
                currentSlice = thisSlice;
                mergeArray = newArray(1);
                mergeArray[0] = 0;
            }
            else{            
                if (thisSlice == currentSlice){
                    // Add to the array of slices to merge
                    mergeArray = Array.concat(mergeArray, i);
                }
                if ((thisSlice > currentSlice) || (i == count-1)){
                    // Merge the array and set current slice
                    //print(thisSlice + " > " + currentSlice);
                    //print("Will merge ROIs:");
                    //Array.print(mergeArray);
                
                    currentSlice = thisSlice;
                
                    // Do the merge
                    if(mergeArray.length > 1){
                        roiManager("select", mergeArray);
                        roiManager("Or");
                        roiManager("Add");
                    }
                    else{
                        // We may have a single ROI ona  slice in which we don't need to merge
                        roiManager("select", mergeArray);
                        roiManager("Add");
                    }
                    // Reset array
                    mergeArray = newArray(1);
                    mergeArray[0] = i;
                }
            }
        }

        // Delete the original ROIS (can I do this in one loop?)
        for (i = 0; i < count; i++) { 
            roiManager("select", 0);
            roiManager("delete");   
        }
    }

    
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Move current ROI to new slice
function moveROIslice(nmSlice){ 

    // Store the ROi we were called with
    called = roiManager("index"); 
    //called = 0;    

    // Calculate the new slice
    roiManager("Remove Slice Info");
    setSlice(nmSlice);

    // Move the ROI to the current slice
     roiManager("select", called);
     roiManager("Add");

     // Delete the old ROI we were called with
     roiManager("select", called);
     roiManager("Delete");
} 
//------------------------------------------------------------------


//------------------------------------------------------------------
// Get total counts in ROI manager
function countsROImanager(){
    DEBUG = 0;

    count = roiManager("count"); 
    current = roiManager("index"); 

    // Variable for output
    results = 0;

    // Set the measurements we want to make
    run("Set Measurements...", "integrated stack display redirect=None decimal=5");

    for (i = 0; i < count; i++) { 
	    roiManager("select", i); 
	
    
        if (DEBUG > 0){
            run("Measure");                                                                                                              
            results += getResult("RawIntDen");                                                                                      
        }
        else{
            List.setMeasurements;
            results = results + List.getValue("RawIntDen");
            List.clear();
        }	

	    roiManager("update");
    }

    return results;
}
//------------------------------------------------------------------

//---------------------------------------------------------------------------
// Measure total counts in stack
// - Return the total counts in image
function sumStack(){
    run("Z Project...", "projection=[Sum Slices]");
    rename("_sum");

    // Set the measurements we want to make 
    run("Set Measurements...", "area min bounding shape integrated stack display redirect=None decimal=5");

    // Measure
    List.setMeasurements;
    results = List.getValue("RawIntDen");
    List.clear();

    close("_sum");

    return results;
    
}
//---------------------------------------------------------------------------


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
    run("Set Measurements...", "area perimeter stack display redirect=None decimal=10");

    for (i = 0; i < count; i++) { 
        roiManager("select", i); 
        
        // Run the measurements
        List.setMeasurements;

        // Sum volumes for each slice
        results[0] += List.getValue("Area") * depth;
        
        // Sum the "strips" of surface area defined by perimeter
        results[1] += List.getValue("Perim.") * depth;
        
        // For the first slice add the surface area of the outside face
        if (i == 0){
            results[1] += List.getValue("Area");
            lastArea = List.getValue("Area");
        }
        // For all other slices add the difference between areas (the overlap in Z)
        else{
            results[1] += abs(List.getValue("Area") - lastArea);
            lastArea = List.getValue("Area");
            
            // If we are on the last slice then add the area of the other end face
            if (i == count - 1){
                results[1] += List.getValue("Area");
            }
        }
        
        List.clear();
        roiManager("update");
    }

    return results;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Generate a spherical ROI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius of the sphere in mm
function createSphere(x, y, z, R){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
    width = abs(width);
    height = abs(height);
    depth = abs(depth);
        
    // Calculate how many slices we need in each direction
    numberSlices = round(R / depth);
    numberSlices = numberSlices + 2; // Make sure we go past the end with the calculation (but not the slices)

    for(i = 0; i <= numberSlices; i++) {
        
        // Get the radius for this slice
        // Move the position of the first slice up by the rounding error
        //roundError = round(R / depth) - (R /depth);
        roundError = 0;
        r = getSegmentRadius(R, i*depth + roundError);
        r = r /width;
        
        // Make sure the radius is valid for this slice
        if(r > 0){
            
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
    
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Given a radius and a height from the centre return segment radius
function getSegmentRadius(r,h){

    if ((r*r - h*h) < 1){
	    a = -99;
    }
    else{
        a = sqrt(r*r - h*h);
    }
    
    return a;
    
}
//------------------------------------------------------------------