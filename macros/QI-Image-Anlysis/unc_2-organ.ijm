// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Uncertainties on polygon ROIs
*/

var savePath = "/home/apr/Science/rois/2-organ/"
var zoom_factor = 3.0; // ImageJ zoom factor used to define the centres
var nRand = 10; // Number of random perturbation of VOI
var seed = 2; // Random number seed
var threshold_cofm = 0.5; //%

macro "makeNucMedROI" {

    cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    //cameras = newArray("DR");
    phantoms = newArray(1);
    phantoms[0] = "2-Organ";
    rois = newArray("_CT_spleen","_CT_cortex","_CT_medulla")
    // rois = newArray("_CT_spleen");

    args = newArray(3);
    // args[1] = "Cylinder";
    // args[2] = "_CT";
    
    // Loop through all the cameras
    for (c = 0; c < cameras.length; c++) {
        // Loop through all the phantoms
        for (p = 0; p < phantoms.length; p++) {

            // Loop through all the rois
            for (r = 0; r < rois.length; r++) {
                
                args[0] = cameras[c];
                args[1] = phantoms[p];    
                args[2] = rois[r];

                run_me(args);

                // Save window
                print("END: " + printTime());
                selectWindow("Log");
                saveAs("Text",savePath+args[0]+"_2-organ_uncertainties.log"); 

                closeAllWindows();
                closeAllImages();



            }

        }


    }

}

function run_me(args){
    print("START: " + printTime());
    print("savePath = " + savePath);
    print("zoom_factor = " + zoom_factor);
    print("nRand = " + nRand);
    print("seed = " + seed);

    // Seed the random generator
    random("seed",seed);

    // // Get the data names from arguments
    // args = parseArguments();    
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Open the CT image
    openCTData(cameraID, phantomID); 
   
    // Open the Nuc Med reconstructed image
    openNMData(cameraID, phantomID);

    // Loop through the ROIs
    selectWindow("CT");
    print("nROIS = " + roiManager("count"));

    // Random loop
    for (nr = 0; nr < nRand; nr++){

        // Open the ROIs
        openROI(cameraID, phantomID, roiID);
        selectWindow("CT");

        // Loop through ROIs
        for (r = 0; r < roiManager("count"); r++){

            roiManager("select", r);

            // Difference in centre of mass
            diff_cofm_x = 10000;
            diff_cofm_y = 10000;
            
            // Save the original ROI in case we need to go round the loop again
            Roi.getCoordinates(xp_original, yp_original);
            type = Roi.getType ;

            while( abs(diff_cofm_x) > threshold_cofm || abs(diff_cofm_y) > threshold_cofm){
                // If the difference in the new ROI Centre of Mass is too big repeat

                // If not the first time then reset ROI to original
                if( diff_cofm_x != 10000 ){
                    print("Resetting ROI");
                    makeSelection(type, xp_original, yp_original); 
                    roiManager("update");
                }

                // Get centre of mass on CT image
                cm_original = getCentreofMass();
                print(r + " : " + cm_original[0] + " " + cm_original[1]);

                // Perturb the ROI
                perturbROI(zoom_factor);

                // Get centre of mass
                cm_new = getCentreofMass();
                diff_cofm_x = (cm_new[0] - cm_original[0])/cm_original[0]*100.0;
                diff_cofm_y = (cm_new[1] - cm_original[1])/cm_original[1]*100.0;
                print(r + " : " + cm_new[0] + " " + cm_new[1]);

                print("% diff : " + diff_cofm_x + " " + diff_cofm_y);

            }
        }

        // Save the ROI set
        roiManager("Save", savePath + cameraID + "_" + phantomID + roiID + "_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip");

        print("CTotoNM....");

        // Translate to a NM ROI
        makeNucMedVOI();

        // Save the ROI set
        roiManager("Save", savePath + cameraID + "_" + phantomID + roiID + "_NM_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip");
        
        // Close the ROIs
        roiManager("reset");



    }

}


function perturbROI(zoom_factor){
    // Get the points of the ROI
    type = Roi.getType ;
    Roi.getCoordinates(xp, yp);

    // Loop through points and change
    for (i = 0; i < xp.length; i++) { 
        // print ("Old = " + xp[i] + " :" + yp[i]);
        xp[i] = getRectangular(xp[i],pointerWidth(zoom_factor)/2.0);
        yp[i] = getRectangular(yp[i],pointerWidth(zoom_factor)/2.0);
        // xp[i] = xp[i] - 50;
        // yp[i] = yp[i] - 50;
        // print ("New = " + xp[i] + " :" + yp[i]);
    }

    // Make the new selection
    makeSelection(type, xp, yp); 
    roiManager("update");
}

function getRectangular(value, uncertainty){
    // Return a random value for the value based on a rectangular distribution
    // - value = value to perturb
    // - uncertainty = absolute uncertainty

    return value + (((2.0*random())-1.0) * uncertainty);

}

function getGaussian(value, uncertainty){
    // Return a random value for the value based on a Gaussian distribution
    // - value = value to perturb (mean)
    // - uncertainty = absolute uncertainty (SD)
    
    return uncertainty*random("gaussian") + value;

}

function pointerWidth(zoom){
    // Return the width covered by the pointer in pixels
    
    size_p = 6;
    
    return (size_p / zoom);
}

function makeNucMedVOI(){
    // Function to reproduce `macros/QI-Image-Anlysis/makeNucMedROI-Spheres.ijm`

    selectWindow("NM");

    // Calculate the alignment of CT and NM in voxels
    delta = calcNMCTalignmentXY("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    //Array.print(delta);

    // Translate the ROIs from CT to NM in X and Y voxels
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanagerZ("NM", "CT");

}

//---------------------------------------------------------------------------
// Get the centre fo mass of an ROI
// - Return the X and Y CofM
function getCentreofMass(){

    // Set the measurements we want to make 
    run("Set Measurements...", "area center min bounding shape integrated stack display redirect=None decimal=5");

    results = newArray(2);
    // Measure
    List.setMeasurements;
    results[0] = List.getValue("X");
    results[1] = List.getValue("Y");
    
    // print(results[0] + " " + results[1]);

    return results;
    
}
//---------------------------------------------------------------------------

function makeNucMedVOI(){
    // Function to reproduce `macros/QI-Image-Anlysis/makeNucMedROI-Spheres.ijm`

    selectWindow("NM");

    // Calculate the alignment of CT and NM in voxels
    delta = calcNMCTalignmentXY("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    //Array.print(delta);

    // Translate the ROIs from CT to NM in X and Y voxels
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanagerZ("NM", "CT");

}