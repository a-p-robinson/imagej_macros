// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Estimate the PDF of VOI defintions
*/
macro "unc_Sphere" {

    cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    args = newArray(3);
    args[1] = "Sphere1";
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
    radius = newArray(9.9/2.0, 12.4/2.0, 15.6/2.0, 19.7/2.0, 24.8/2.0, 31.3/2.0);
    
    // At his point we have read the centres in and cleared the ROI manager.
    // We have also defined the "correct" radi

    Array.print(sphereX);
    Array.print(sphereY);
    Array.print(sphereZ);
    Array.print(radius);

    zoom_factor = 2.0;
    radius_perc_unc = 0.33; //%
    seed = 2;
    random("seed",seed);

    // Get a random value each centre
    for (i = 0; i < sphereX.length; i++){
        print("x,y[" + i + "] = " + sphereX[i] + " , " + sphereY[i] + " --> " + getRectangular(sphereX[i],pointerWidth(zoom_factor)) + " , " + getRectangular(sphereY[i],pointerWidth(zoom_factor)));

        print("r[" + i + "] = " + radius[i] + " --> " + getGaussian(radius[i],radius_perc_unc/100.0*radius[i]));

    }

    exit();
    


    for (i = 0; i < sphereX.length; i++){

        selectWindow("CT");
        
        print("Will generate sphere [CT]:");
        print(i + " : " + sphereX[i] + " "+ sphereY[i] + " "+ sphereZ[i]);  
        	
        // Create the sphere ROI
	    createSphere(sphereX[i],sphereY[i],sphereZ[i],radius[i]);

        // Save the ROI set
        //roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
        roiManager("Save", roiDirectory + cameraID + "_" + phantomID + "_CT_Sphere_" + i+1 + "_RoiSet_XYZ.zip");
        
        // Get some stats
        geometry = newArray(2);
        geometry = getVolumeArea();
        print("CT VOI volume : " + geometry[0] + " mm^3");
        print("CT VOI surface area : " + geometry[1] + " mm^2");

        // Close ROIs
	    roiManager("reset");
    }

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