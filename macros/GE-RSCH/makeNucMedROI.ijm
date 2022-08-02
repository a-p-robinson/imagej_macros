/* 
Transfer a CT based ROI to a nuclear medicine image
*/
macro "makeNucMedROI" {

    // Get the data names from arguments
    args = split(getArgument(), " ");

    if (args.length != 2){
        print("ERROr: must specify 2 arguments (camera phantom");
        Array.print(args);
        exit();
    }

    cameraID = args[0];
    phantomID = args[1];

    // cameraID = "DR";
    // phantomID = "Cylinder";

    // Open the CT image
    openCTData(cameraID, phantomID); 

    // Open the ROIs
    openCTROI(cameraID, phantomID);
    
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
    roiManager("Save", roiDirectory + cameraID + "_" + phantomID + "_NM_RoiSet_XYZ.zip");

}