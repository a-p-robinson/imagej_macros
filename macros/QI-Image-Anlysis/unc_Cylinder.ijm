// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Define a cylindrical ROI based on the centre of the phantom using CT
*/

var savePath = "/var/home/apr/Science/rois/x1000/"
var zoom_factor = 2.0; // ImageJ zoom factor used to define the centres
var radius_perc_unc = 0.33; // Sphere radius percentage uncertainty%
var nRand = 100; // Number of random perturbation of VOI
var seed = 2; // Random number seed
var doRadiusUnc = 1;
var doPositionUnc = 1;

macro "cylinderROI" {

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

        // closeAllWindows();
        closeAllImages();

    }

}

function run_me(args){

    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    random("seed",2);

    // Open the CT image
    // cameraID = "DR";
    // phantomID = "Cylinder";
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

    // Find the "real" centre
    m_centre_z = centreProfile(ct_z, ct_z_half);

    // Find the centre of the profile (With random fluctuations)
    centre_z = newArray(nRand);
    centre_x = newArray(nRand);
    centre_y = newArray(nRand);
    unc_threshold = 10; //%
    unc_profile = 5; //%
    
    for (nz = 0; nz < nRand; nz++){
        centre_z[nz] = centreProfileRand(ct_z, ct_z_half, unc_profile, unc_threshold);
        print(nz);  
    }

    run("Select None");
    
    for (nx = 0; nx < nRand; nx++){

        // Find centre in x and y
        selectWindow("CT");
        setSlice(centre_z[nx]);
        getDimensions(width, height, channels, slices, frames);
        makeRectangle(0, 0, width, height);
        ct_x = getProfile();

        selectWindow("CT");
        //makeRectangle(0, 0, width, height);
        setKeyDown("alt"); ct_y = getProfile();
        //run("Plot Profile");

        threshold = -1200;
        centre_x[nx] = centreProfileRand(ct_x, threshold, unc_profile, unc_threshold);  
        threshold = -700;
        centre_y[nx] = centreProfileRand(ct_y, threshold, unc_profile, unc_threshold); 
    }


    Array.getStatistics(centre_x, min_x, max_x, mean_x, stdDev_x);
    Array.getStatistics(centre_y, min_y, max_y, mean_y, stdDev_y);
    Array.getStatistics(centre_z, min_z, max_z, mean_z, stdDev_z);


    print("[x] " + m_centre_x + " mean = " + mean_x + " StdDev = " + stdDev_x + " unc [%] = " + 100.0*(stdDev_x/mean_x));
    print("[y] " + m_centre_y + " mean = " + mean_y + " StdDev = " + stdDev_y + " unc [%] = " + 100.0*(stdDev_y/mean_y));
    print("[z] " + m_centre_z + " mean = " + mean_z + " StdDev = " + stdDev_z + " unc [%] = " + 100.0*(stdDev_z/mean_z));


    
    // // Find the centre of the profile
    // for (i = 0; i < 100; i++){
    //     // Modify the threshold and see how the values change
    //     centre_z = centreProfile(ct_z, ct_z_half-i);    
    //     print("[" + i + "] threhsold = " + ct_z_half-i + " centre_z = " + centre_z);
    //     centre_z = centreProfile(ct_z, ct_z_half+i);    
    //     print("[" + i + "] threhsold = " + ct_z_half+1 + " centre_z = " + centre_z);
    // }
    
    // print("------------------");
    // for (i = 0; i < 100; i++){
    //     centre_z = centreProfileRand(ct_z, ct_z_half,50);
    //     print("[Random] threshold = " + ct_z_half + " centre_z = " + centre_z);
    // }

    // What if we randomly fluctuate each pixel in the profile within an uncertainty
    // - use a new function for this..




    // // Find centre in x and y
    // selectWindow("CT");
    // setSlice(centreCT[2]);

    // getDimensions(width, height, channels, slices, frames);
    // makeRectangle(0, 0, width, height);
    // ct_x = getProfile();
    // //run("Plot Profile");

    // //exit();
    // selectWindow("CT");
    // //makeRectangle(0, 0, width, height);
    // setKeyDown("alt"); ct_y = getProfile();
    // //run("Plot Profile");

    // threshold = -1200;
    // centreCT[0] = centreProfile(ct_x, threshold);
    // threshold = -700;
    // centreCT[1] = centreProfile(ct_y, threshold);

    // Array.print(centreCT);

    // // Make ROIS
    // // 	Cylinder inside diameter: 21.6 cm * 130 % = 28.08 cm
    // // 	Cylinder inside height: 18.6 cm * 120 % = 22.32 cm
    // phantomRadius = 216 * 1.3 / 2.0;
    // phantomHeight = 186 * 1.2;
    // //phantomRadius = 216  / 2.0;
    // //phantomHeight = 186;

    // selectWindow("CT");
    // run("Select None");
    // roiManager("reset");

    // createCylinder(centreCT[0], centreCT[1], centreCT[2], phantomRadius, phantomHeight);

    // // Save the ROI dataset
    // //roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis/rois/";
    // roiManager("Save", roiDirectory + cameraID + "_" + phantomID + roiID + "_RoiSet_XYZ.zip");


}

