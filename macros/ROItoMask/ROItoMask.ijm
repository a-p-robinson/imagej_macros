// ***********************************************************************
// * Create a mask imaged from some ROIs
// *
// * APR: 26/08/20
// ***********************************************************************

macro "ROItoMask" {

    phantom = "nema";
    si = 20;
    
    // Open the ROIS
    if(phantom == "cyl"){
	roi_file = "/home/apr/Nextcloud/prj/work/NPL_SPECT_Uncertainties/analysis/Uncertainties/ImageJ/Cylinder_Large_RoiSet.zip";
    }
    if(phantom == "nema"){
	roi_file = "/home/apr/Nextcloud/prj/work/NPL_SPECT_Uncertainties/analysis/Uncertainties/ImageJ/Big-Rect-NEMA_RoiSet.zip";
    }

    roiManager("Open", roi_file);
    
    // Open the image
    if(phantom == "cyl"){
	image_file = "/home/apr/prj/work/NPL_SPECT_Uncertainties/data/Recon/Cyl_noCor/reconOSEM_1sub_100subiter/OSEM+Mediso_LC+EC+UC_AC_"+si+".v";
    }

    if(phantom == "nema"){
	image_file = "/home/apr/prj/work/NPL_SPECT_Uncertainties/data/Recon/NEMA_NoCorr/reconOSEM_1sub_100subiter/OSEM+Mediso_LC+EC+UC_AC_"+si+".v";
    }

    run("Raw...", "open="+image_file+" image=[32-bit Real] width=128 height=128 number=128 little-endian");
    rename("Image");

    // Set colour and data type
    run("Fire");
    run("8-bit");

    // Mask the image
    maskROImanager(12,1);

    // Save the image
    savename = "/home/apr/prj/work/NPL-ImageJ/macros/NPL/ROItoMask/Recon-ImageMask_" + phantom + ".raw";
    saveAs("Raw Data", savename);

    
}

function maskROImanager(inside_value, clear_outside){
    // Do we need to clear outside?
    if (clear_outside == 1){
	clearoutsideROImanager();
    }

    // Set the value inside ROIs
    setvalueROImanager(inside_value);
}

//------------------------------------------------------------------
// Clear image outside the ROI manager
function clearoutsideROImanager(){
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Set the background colour
    setBackgroundColor(0, 0, 0);

    // Clear outside the ROIs
    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Clear Outside", "slice");
	
	// Record the first slice we have cleared
	if (i ==0 ){
	    firstSlice = getSliceNumber();
	}
    }

    // Clear the slices without ROIs
    lastSlice = firstSlice + count - 1;
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
function setvalueROImanager(val){
    count = roiManager("count"); 
    current = roiManager("index"); 

    //firstSlice;
    //lastSlice;

    // Set the foreground colour
    setForegroundColor(1, 0, 0);

    // Clear outside the ROIs
    for (i = 0; i < count; i++) { 
	roiManager("select", i); 
	run("Set...", "value=" + val + " slice"); //change ROI value
    }

}
//------------------------------------------------------------------
