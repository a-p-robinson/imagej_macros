// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Define a cylindrical ROI based on the centre of the phantom using CT
*/

var savePath = "/var/home/apr/Science/rois/cylinder/"
var zoom_factor = 1.0; // ImageJ zoom factor used to define the centres
var radius_perc_unc = 1.0  // Sphere radius percentage uncertainty (%)
var height_perc_unc = 1.0; // Cylinder height percentage uncertainty (%)
var unc_threshold = 10; // Uncertainty on CT threshold (%)
var unc_profile = 5; // Uncertainty on profile value (%)

var nRand = 1000; // Number of random perturbation of VOI
var seed = 2; // Random number seed

macro "unc_Cylinder" {

    cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    // cameras = newArray("DR");
    args = newArray(3);
    args[1] = "Cylinder";
    args[2] = "_CT";
    
    // Loop through all the cameras
    for (c = 0; c < cameras.length; c++){

        args[0] = cameras[c];

        print(cameras[c]);
        run_me(args);

        // Save window
        print("END: " + printTime());
        selectWindow("Log");
        saveAs("Text",savePath+args[0]+"_cylinder_uncertainties.log"); 

        closeAllWindows();
        closeAllImages();

    }


    
}

function run_me(args){
    print("START: " + printTime());
    print("unc_threshold = " + unc_threshold + "%");
    print("unc_profile = " + unc_profile + "%");
    print("nRand = " + nRand);
    print("seed = " + seed);

    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    phantomRadius = 216 * 1.3 / 2.0;
    phantomHeight = 186 * 1.2;

    random("seed",seed);

    // Open the Nuc Med reconstructed image
    openNMData(cameraID, phantomID);

    // Open the CT image
    openCTData(cameraID, phantomID); 

    // Find the centre in Z
    selectWindow("CT");

    // Make the image that we use for centreSliceCT()
    getVoxelSize(width, height, depth, unit);

    run("Reslice [/]...", "output="+depth+" start=Top avoid");
    selectWindow("Reslice of CT");
    setSlice(nSlices()/2);
    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    setKeyDown("alt"); ct_z = getProfile();

    // Find the threshold
    ct_z_max = Array.findMaxima(ct_z,0.00001);
    ct_z_min = Array.findMinima(ct_z,0.00001);
    ct_z_half = (ct_z[ct_z_max[0]]+ct_z[ct_z_min[0]])/2;

    // Find the "real" centre (x,y,z)
    m_centre_z = centreProfile(ct_z, ct_z_half);

    // Find centre in x and y
    selectWindow("CT");
    setSlice(m_centre_z);

    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    ct_x = getProfile();

    selectWindow("CT");
    setKeyDown("alt"); ct_y = getProfile();
    
    threshold = -1200;
    m_centre_x = centreProfile(ct_x, threshold);  
    threshold = -700;
    m_centre_y = centreProfile(ct_y, threshold); 

    // Find the centre of the profile (With random fluctuations)
    centre_z = newArray(nRand);
    centre_x = newArray(nRand);
    centre_y = newArray(nRand);

    for (nz = 0; nz < nRand; nz++){
        run("Select None");
        centre_z[nz] = centreProfileRand(ct_z, ct_z_half, unc_profile, unc_threshold);
        //centre_z[nz] = centreProfile(ct_z, ct_z_half);

        // Find centre in x and y
        selectWindow("CT");
        setSlice(centre_z[nz]);

        getDimensions(width, height, channels, slices, frames);
        //makeRectangle(0, 0, width, height);
        makeRectangle(0, 0, width, height);
        ct_x = getProfile();

        selectWindow("CT");
        //makeRectangle(0, 0, width, height);
        setKeyDown("alt"); ct_y = getProfile();
        //run("Plot Profile");

        threshold = -1200;
        centre_x[nz] = centreProfileRand(ct_x, threshold, unc_profile, unc_threshold);  
        //centre_x[nz] = centreProfile(ct_x, threshold);  
        threshold = -700;
        centre_y[nz] = centreProfileRand(ct_y, threshold, unc_profile, unc_threshold); 
        //centre_y[nz] = centreProfile(ct_y, threshold); 

        // We now have the centre so we can do the rest of the cylinder definition with random volume
     
        // 	Get a random radius and height
        new_phantomRadius = getGaussian(phantomRadius,radius_perc_unc/100.0*phantomRadius);  
        new_phantomHeight = getGaussian(phantomHeight,height_perc_unc/100.0*phantomHeight);

        selectWindow("CT");
        run("Select None");
        roiManager("reset");

        // Using a modified version which randomly decides on the last slice for even numbers of slices.
        createCylinderRand(centre_x[nz], centre_y[nz], centre_z[nz], new_phantomRadius, new_phantomHeight);

        // Save the CT ROI dataset
        roiManager("Save", savePath + cameraID + "_" + phantomID + roiID + "_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nz + ".zip");

        print("CTotoNM....");

        // Translate to a NM ROI
        makeNucMedVOI();
        
        // Save the CT ROI dataset
        roiManager("Save", savePath + cameraID + "_" + phantomID + roiID + "_NM_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nz + ".zip");

    }

    // Get the position uncertainties
    Array.getStatistics(centre_x, min_x, max_x, mean_x, stdDev_x);
    Array.getStatistics(centre_y, min_y, max_y, mean_y, stdDev_y);
    Array.getStatistics(centre_z, min_z, max_z, mean_z, stdDev_z);

    print("[x] " + m_centre_x + " mean = " + mean_x + " StdDev = " + stdDev_x + " unc [%] = " + 100.0*(stdDev_x/mean_x));
    print("[y] " + m_centre_y + " mean = " + mean_y + " StdDev = " + stdDev_y + " unc [%] = " + 100.0*(stdDev_y/mean_y));
    print("[z] " + m_centre_z + " mean = " + mean_z + " StdDev = " + stdDev_z + " unc [%] = " + 100.0*(stdDev_z/mean_z));


}

function makeNucMedVOI(){
    // Function to reproduce `macros/QI-Image-Anlysis/makeNucMedROI-Spheres.ijm`

    selectWindow("NM");

    // Calculate the alignment of CT and NM in voxels
    delta = calcNMCTalignmentXY("NM", "CT");
    scale = calcNMCTscale("NM", "CT");
    //Array.print(delta);

    // Translate the ROIs from CT to NM in X and Y voxels
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(scale[0]);

    // Translate the ROIs from CT to NM in Z
    ctToNMROImanagerZ("NM", "CT");

  }