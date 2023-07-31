// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Define spherical ROIs for the NEMA phantom using CT
*/
macro "sphereROI-Sphere2" {

    cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    args = newArray(3);
    args[1] = "Sphere2";
    args[2] = "NULL";
    
    // Loop through all the cameras
    for (c = 0; c < cameras.length; c++){

        args[0] = cameras[c];

        run_me(args);

        closeAllWindows();
        closeAllImages();

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

    // Open the Sphere Centres
    openCTsphereCentres(cameraID, phantomID);

    // Loop through the centres
    selectWindow("CT");
    count = roiManager("count");
    sphereX = newArray(count);
    sphereY = newArray(count);
    sphereZ = newArray(count);

    for (i = 0; i < count; i++) {
        roiManager("select", i);

        // Get the position
        getSelectionCoordinates(x, y);
        sphereX[i] = x[0];
        sphereY[i] = y[0];
        sphereZ[i] = getSliceNumber();
    }

    // Get rid of the centres from roiManager now
    roiManager("reset");
    
    // Create the sphere ROIS
    // Volume is ~153ml therefore radius = 33.2 ml
    radius = newArray(1);
    radius[0] = 33;
    
    for (i = 0; i < sphereX.length; i++){

        selectWindow("CT");
        
        print("Will generate sphere [CT]:");
        print(i + " : " + sphereX[i] + " "+ sphereY[i] + " "+ sphereZ[i]);  
        	
        // Create the sphere ROI
	    createSphere(sphereX[i],sphereY[i],sphereZ[i],radius[i]);
       
        // Save the ROI set
        //roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
        roiManager("Save", roiDirectory + cameraID + "_" + phantomID + "_CT" + "_RoiSet_XYZ.zip");
        
        // Get some stats
        geometry = newArray(2);
        geometry = getVolumeArea();
        print("CT VOI volume : " + geometry[0] + " mm^3");
        print("CT VOI surface area : " + geometry[1] + " mm^2");

        // Close ROIs
	    roiManager("reset");
    }

}