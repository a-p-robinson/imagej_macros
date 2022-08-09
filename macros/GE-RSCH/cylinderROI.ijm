/* 
Define a cylindrical ROI based on the centre of the phantom using CT
*/
macro "cylinderROI" {

    // Get the data names from arguments
    args = parseArguments();    
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Open the CT image
    // cameraID = "DR";
    // phantomID = "Cylinder";
    openCTData(cameraID, phantomID); 

    // Find the centre in Z
    selectWindow("CT");
    centreCT = newArray(3);
    centreCT[2] = centreSliceCT();

    // Find centre in x and y
    setSlice(centreCT[2]);

    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    ct_x = getProfile();

    selectWindow("CT");
    setKeyDown("alt"); ct_y = getProfile();
    

    threshold = -1200;
    centreCT[0] = centreProfile(ct_x, threshold);
    threshold = -700;
    centreCT[1] = centreProfile(ct_y, threshold);

    Array.print(centreCT);

    // Make ROIS
    // 	Cylinder inside diameter: 21.6 cm * 130 % = 28.08 cm
    // 	Cylinder inside height: 18.6 cm * 120 % = 22.32 cm
    phantomRadius = 216 * 1.3 / 2.0;
    phantomHeight = 186 * 1.2;
    //phantomRadius = 216  / 2.0;
    //phantomHeight = 186;

    selectWindow("CT");
    run("Select None");
    roiManager("reset");

    createCylinder(centreCT[0], centreCT[1], centreCT[2], phantomRadius, phantomHeight);

    // Save the ROI dataset
    roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
    roiManager("Save", roiDirectory + cameraID + "_" + phantomID + roiID + "_RoiSet_XYZ.zip");


}