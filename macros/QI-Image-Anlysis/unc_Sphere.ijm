// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Estimate the PDF of VOI defintions
*/

var testPath = "/var/home/apr/Science/rois/big_u/"

macro "unc_Sphere" {

    // cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    cameras = newArray("DR");
    args = newArray(3);
    args[1] = "Sphere1";
    args[2] = "NULL";
    
    // Loop through all the cameras
    for (c = 0; c < cameras.length; c++){

        args[0] = cameras[c];

        run_me(args);

        // closeAllWindows();
        // closeAllImages();

    }


}

function run_me(args){
    // // Get the data names from arguments
    // args = parseArguments();    
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Open the Nuc Med reconstructed image
    openNMData(cameraID, phantomID);

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

    zoom_factor = 0.1;
    radius_perc_unc = 0.33; //%
    seed = 2;
    nRand = 100;
    random("seed",seed);

    // Loop through each sphere
    for (i = 0; i < sphereX.length; i++){

        selectWindow("CT");
        
        print("Will generate sphere [CT]:");
        print(i + " : " + sphereX[i] + " "+ sphereY[i] + " "+ sphereZ[i] + " " + radius[i]);  

        // Loop through the VOI perturbations
        for (nr = 0; nr < nRand; nr++){
            // Get the new positions
            new_sphereX = getRectangular(sphereX[i],pointerWidth(zoom_factor)/2.0);
            new_sphereY = getRectangular(sphereY[i],pointerWidth(zoom_factor)/2.0);
            new_radius  = getGaussian(radius[i],radius_perc_unc/100.0*radius[i]);
          
            print("***Number: " + nr + "****");
            print(nr + " : " + new_sphereX + " " + new_sphereY + " " + sphereZ[i] + " " + new_radius);

            // Create the sphere ROI
            selectWindow("CT");
            createSphere(new_sphereX,new_sphereY,sphereZ[i],new_radius);
            roiManager("Sort");

            // Save the ROI set
            roiManager("Save", testPath + cameraID + "_" + phantomID + "_CT_Sphere_" + i+1 + "_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip");

            print("CTotoNM....");

            // Translate to a NM ROI
            makeNucMedVOI();

            // Save the ROI set
            roiManager("Save", testPath + cameraID + "_" + phantomID + "_CT_Sphere_" + i+1 + "_NM_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip");

            // // Get some stats
            // geometry = newArray(2);
            // geometry = getVolumeArea();
            // print("CT VOI volume : " + geometry[0] + " mm^3");
            // print("CT VOI surface area : " + geometry[1] + " mm^2");

            // Close ROIs
	        roiManager("reset");

            // Save window
            selectWindow("Log");
            saveAs("Text",testPath+"uncertainties.log"); 

        }

        // // Create the sphere ROI
	    // createSphere(sphereX[i],sphereY[i],sphereZ[i],radius[i]);

        // // Save the ROI set
        // //roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
        // roiManager("Save", roiDirectory + cameraID + "_" + phantomID + "_CT_Sphere_" + i+1 + "_RoiSet_XYZ.zip");
        
        // // Get some stats
        // geometry = newArray(2);
        // geometry = getVolumeArea();
        // print("CT VOI volume : " + geometry[0] + " mm^3");
        // print("CT VOI surface area : " + geometry[1] + " mm^2");

        // // Close ROIs
	    // roiManager("reset");
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

function makeNucMedVOI(){
    // Function to reproduce `macros/QI-Image-Anlysis/makeNucMedROI-Spheres.ijm`

    selectWindow("NM");

    // Calculate the alignment of CT and NM in voxels
    delta = calcNMCTalignmentXY("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    Array.print(delta);

    // Translate the ROIs from CT to NM in X and Y voxels
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanagerZ("NM", "CT");

  }