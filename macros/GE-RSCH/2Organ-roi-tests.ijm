/* 
Get the statistics from the VOI (all ROIs)
*/
macro "2Organ-roi-tests" {

    
    // // Optima
    // run("Image Sequence...", "open=/home/apr/Science/GE-RSCH/QI/data/DicomData/Optima/2-Organ/CT/CTSPECT-CT_H_1001_CT001.dcm");
    // rename("CT");

    // roiManager("Open", "/home/apr/Science/GE-RSCH/QI/analysis/rois/Optima-2organ_CT_RoiSet_XYZ.zip");

    // open("/home/apr/Science/GE-RSCH/QI/data/DicomData/Optima/2-Organ/Recon/SPECT-CT_EM2_IRACSC001_DS.dcm");
    // rename("NM");
    // run("Fire");


    // DR
    CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/2-Organ/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
    CTslices=321;

    run("Image Sequence...", "open=" + CTfile + " number=" + CTslices + " starting=1 increment=1 scale=100 file=[] sort");
    rename("CT");

    roiManager("Open", "/home/apr/Science/GE-RSCH/QI/analysis/rois/DR-2organ_CT_RoiSet_XYZ.zip");

    open("/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/2-Organ/Recon/SPECTCT_EM2_IRAC001_DS.dcm");
    rename("NM");
    run("Fire");

    // Get the VOI stats
    // Get total counts in VOI
    selectWindow("CT");
    
    // Measure volume and surface area
    geometry = newArray(2);
    geometry = getVolumeArea();
    print("CT VOI volume : " + geometry[0] + " mm^3");
    print("CT VOI surface area : " + geometry[1] + " mm^2");

    // Move to NM

    // Calculate the alignment of CT and NM in mm
    delta = calcNMCTalignmentXY("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    //Array.print(delta);
    //Array.print(scale);

    // Translate the ROIs from CT to NM in X and Y
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);
    
    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanagerZ("NM", "CT");

    // Get the VOI stats
    // Get total counts in VOI
    selectWindow("NM");
    
    // Measure volume and surface area
    geometry = newArray(2);
    geometry = getVolumeArea();
    print("NM VOI volume : " + geometry[0] + " mm^3");
    print("NM VOI surface area : " + geometry[1] + " mm^2");

    // // Total counts in image
    // selectWindow("NM");
    // total = sumStack();
    // print("Sum stack counts : " + total);
    
    // What is the "right" answer?
    // phantomRadius = 216 * 1.3 / 2.0;
    // phantomHeight = 186 * 1.2;
    //
    // Vol = 1.38222×107
    // Area = 3.20753×105
    // CT: 13905835.2172, 321997.3111
    // NM: 13990353.0416, 323119.2122

    // ALos add the total counts in the image....

}