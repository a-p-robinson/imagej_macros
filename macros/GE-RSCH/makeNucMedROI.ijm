/* 
Transfer a CT based ROI to a nuclear medicine image
*/
macro "makeNucMedROI" {

    // Open the CT image
    cameraID = "DR";
    phantomID = "Cylinder";
    openCTData(cameraID, phantomID); 

    // Open the ROIs
    roiFile = "/home/apr/Science/GE-RSCH/QI/analysis/rois/DR_Cylinder_exact__RoiSet_XYZ.zip";
    roiManager("Open",roiFile);

    // Open the Nuc Med reconstructed image
    open("/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/Cylinder/Recon/SPECTCT_EM2_IRAC001_DS.dcm");
    rename("NM");
    run("Fire");

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

}