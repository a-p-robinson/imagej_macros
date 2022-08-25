/* 
Get the statistics from the VOI (all ROIs)
*/
macro "getVOIstats" {

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

    // Get the VOI stats
    //
    // Get total counts in VOI
    selectWindow("NM");
    test = countsROImanager();
    print("Voi Counts : " + test);

    // Measure volume and surface area
    geometry = newArray(2);
    geometry = getVolumeArea();
    print("VOI volume : " + geometry[0] + " mm^3");
    print("VOI surface area : " + geometry[1] + " mm^2");

    // Total counts in image
    selectWindow("NM");
    total = sumStack();
    print("Sum stack counts : " + total);
    
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