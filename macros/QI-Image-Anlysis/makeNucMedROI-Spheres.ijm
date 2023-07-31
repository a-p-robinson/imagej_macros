/* 
Transfer a CT based ROI to a nuclear medicine image
*/
macro "makeNucMedROI" {

    cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    phantoms = newArray("Sphere1","Sphere2");

    args = newArray(3);
    // args[1] = "Cylinder";
    // args[2] = "_CT";
    
    // Loop through all the cameras
    for (c = 0; c < cameras.length; c++) {
        // Loop through all the phantoms
        for (p = 0; p < phantoms.length; p++) {

            args[0] = cameras[c];
            args[1] = phantoms[p];

            if (args[1] == "Sphere1") {
                rois = newArray("_CT_Sphere_1", "_CT_Sphere_2", "_CT_Sphere_3", "_CT_Sphere_4", "_CT_Sphere_5", "_CT_Sphere_6");
            }
            if (args[1] == "Sphere2") {
                rois = newArray(1);
                rois[0] = "_CT";
            }

            // Loop through all the rois
            for (r = 0; r < rois.length; r++) {
                args[2] = rois[r];

                run_me(args);

                closeAllWindows();
                closeAllImages();

            }

        }


    }

}

function run_me(args){

    // // Get the data names from arguments
    // args = parseArguments();    
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Open the CT image
    openCTData(cameraID, phantomID); 

    // Open the ROIs
    openROI(cameraID, phantomID, roiID);
    
    // Open the Nuc Med reconstructed image
    openNMData(cameraID, phantomID);

    // Calculate the alignment of CT and NM in voxels
    delta = calcNMCTalignmentXY("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    Array.print(delta);
    // Array.print(scale);

    // Translate the ROIs from CT to NM in X and Y voxels
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanagerZ("NM", "CT");

    // Save the ROI dataset
    //roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
    roiManager("Save", roiDirectory + cameraID + "_" + phantomID + roiID + "_NM_RoiSet_XYZ.zip");

}