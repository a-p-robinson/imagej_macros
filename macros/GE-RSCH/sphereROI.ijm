/* 
Define spherical ROIs for the NEMA phantom
*/
macro "sphereROI" {

    // Get the data names from arguments
    args = split(getArgument(), " ");

    if (args.length != 2){
        print("ERROr: must specify 2 arguments (camera phantom");
        Array.print(args);
        exit();
    }

    cameraID = args[0];
    phantomID = args[1];

    // Open the CT image
    openCTData(cameraID, phantomID); 

    // Open the Sphere Centres
    openCTsphereCentres(cameraID, phantomID);

    // Open the NM image
    openNMData(cameraID, phantomID);

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
    radius = newArray(9.9 / 2.0,12.4 / 2.0,15.4 / 2.0,19.8 / 2.0,24.8 / 2.0,31.3 / 2.0);

    // Calculate the alignment of CT and NM in mm
    delta = calcNMCTalignment("NM", "CT");
    Array.print(delta);
    
    for (i = 0; i < sphereX.length; i++){

        selectWindow("CT");
        
        print("Will generate sphere [CT]:");
        print(i + " : " + sphereX[i] + " "+ sphereY[i] + " "+ sphereZ[i]);  
        	
        // Create the sphere ROI
	    createSphere(sphereX[i],sphereY[i],sphereZ[i],radius[i]);

        // Save the ROI set
        roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
        roiManager("Save", roiDirectory + cameraID + "_" + phantomID + "_CT_Sphere_" + i+1 + "_RoiSet_XYZ.zip");
        
        // Get some stats
        geometry = newArray(2);
        geometry = getVolumeArea();
        print("CT VOI volume : " + geometry[0] + " mm^3");
        print("CT VOI surface area : " + geometry[1] + " mm^2");

        // Close ROIs
	    roiManager("reset");

        // Move the centres to NM and repeat on NM
        selectWindow("NM");
        getVoxelSize(nm_width, nm_height, nm_depth, nm_unit);

        sphereX[i] = sphereX[i] + delta[0] / nm_width;
        sphereY[i] = sphereY[i] + delta[1] / nm_height;
        sphereZ[i] = round(sphereZ[i] + delta[2] / nm_depth);

        print("Will generate sphere [NM]:");
        print(i + " : " + sphereX[i] + " "+ sphereY[i] + " "+ sphereZ[i]);  
        	
        // Create the sphere ROI
	    createSphere(sphereX[i],sphereY[i],sphereZ[i],radius[i]);

        // // Move the VOI to the Nuc Med
        // //
        // // Calculate the alignment of CT and NM in mm
        // delta = calcNMCTalignment("NM", "CT");
        // scale = calcNMCTscale("NM", "CT");
        // Array.print(delta);
        // Array.print(scale);
        
        // // Translate the ROIs from CT to NM in X and Y
        // selectWindow("CT");
        // translateROImanagerdXdY(delta[0], delta[1]);
        
        // // Scale the ROIS to NM on CT (most accrate)
        // selectWindow("CT");
        // scaleROImanager(scale[0]);
        
        // // Translate the ROIs from CT to NM in Z
        // ctToNMROImanager("NM", "CT", delta[2]);
        
        // Get some stats
        geometry = newArray(2);
        geometry = getVolumeArea();
        print("NM VOI volume : " + geometry[0] + " mm^3");
        print("NM VOI surface area : " + geometry[1] + " mm^2");

        // Save the ROI set
        roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
        roiManager("Save", roiDirectory + cameraID + "_" + phantomID + "_NM_Sphere_" + i+1 + "_RoiSet_XYZ.zip");
        
        // Close ROIs
	    roiManager("reset");

    }


}