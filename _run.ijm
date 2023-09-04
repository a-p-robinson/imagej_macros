// SPDX-License-Identifier: GPL-3.0-or-later
/* 
    Get the value of a measurand using a PDF for a VOI
*/

var DATA_DIR = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/";
var RESULTS_DIR = "/home/apr/Science/GE-RSCH/QI/analysis-clean/image-analysis/results/";

// --- Variables ----
var savePath = "/home/apr/Science/rois/sphere2/"
var zoom_factor = 2.0; // ImageJ zoom factor used to define the centres
var nRand = 1000; // Number of random perturbation of VOI
var seed = 2; // Random number seed
var sub_set = 1000;

macro "loop_all_data_unc" {

    setBatchMode(true);

    //cameras = newArray("DR", "Optima","CZT-WEHR","CZT-MEHRS");
    cameraID = "DR";
    windowName = "EM2";
    // phantoms = newArray("Cylinder","Sphere1","Sphere2","2-Organ");
    phantoms = newArray(1);
    phantoms[0] = "Sphere2"

    //corrections = newArray("NC","AC","ACSC");
    corrections = newArray(1);
    corrections[0] = "AC";

    //itt = newArray(1,2,3,4,5,10,20,30,40,50);
    itt = newArray(1);
    itt[0] = 30;

    // Use an array for the output so we can get statistics
    // - Array.getStatistics(array, min, max, mean, stdDev)
    // - Or we coudl use Table.getColumn()?

    // Create output tables
    // Make a Table for output
    table_name = "Whole Image";
    Table.create(table_name);
    ii = 0;
      
    table_name = "VOI";
    Table.create(table_name);
    jj= 0;

    table_name = "Uncertainties";
    Table.create(table_name);
    jj= 0;
    kk=0;

    // Loop through all the phantoms
    for (p = 0; p < phantoms.length; p++){

        phantomID = phantoms[p];

        // Define what VOIs go with that phantom
        if (phantomID == "Cylinder"){
            rois = newArray("_CT_NM");
        }
        
        if (phantomID == "Sphere1"){
            rois = newArray("_CT_Sphere_1_NM","_CT_Sphere_2_NM","_CT_Sphere_3_NM","_CT_Sphere_4_NM","_CT_Sphere_5_NM","_CT_Sphere_6_NM");
        }
        
        if (phantomID == "Sphere2"){
            rois = newArray("_CT_NM");
        }
        
        if (phantomID == "2-Organ"){
            rois = newArray("_CT_spleen_NM","_CT_cortex_NM","_CT_medulla_NM");
        }
        
        // Loop through corrections                                  
        for (c = 0; c < corrections.length; c++){
            
            // Loop through reconstruction itterations
            for (i = 0; i < itt.length; i++){

                print(phantoms[p] + ":" + corrections[c] + ":" + itt[i]);

                // Open the Nuc Med file
                fileName = DATA_DIR+cameraID+"/"+phantomID+"/" + windowName + "/SS5_IT" + itt[i] + "/SPECTCT_"+windowName+"_IR"+corrections[c]+"001_DS.dcm";
                open(fileName);
                rename(itt[i]);
                run("Fire");
              
                // Get total counts for that image
                counts = sumStack();

                // Save results to table
                selectWindow("Whole Image");
                Table.set("Camera", ii, cameraID);
                Table.set("Energy", ii, windowName);
                Table.set("Phantom", ii, phantoms[p]);
                Table.set("Correction", ii, corrections[c]);
                Table.set("Iterations", ii, itt[i]);
                Table.set("Total Counts", ii, counts);
                ii++;
                
                // Loop through rois
                // We have a lot of ROIS to go through now.....!

                for (r = 0; r < rois.length; r++){
            
                    // Get the "true" measurand value
                    // Open the ROI
                    openROI(cameraID,phantoms[p],rois[r]);
                    selectWindow(itt[i]);
                    m_voiCounts = countsROImanager();
                    m_geometry = newArray(2);
                    m_geometry = getVolumeArea();
                    m_nVoxels = voxelsROImanager();

                    roiManager("reset")

                    // Array to store the PDF (we resize these dynamically!)
                    pdf_voiCounts = newArray(sub_set);
                    pdf_area = newArray(sub_set);
                    pdf_volume = newArray(sub_set);
                    pdf_nVoxels = newArray(sub_set);

                    // Loop through the VOI perturbations
                    for (nr = 0; nr < sub_set; nr++){

                        // Construct the file name
                        roiFile = savePath + cameraID + "_" + phantomID + rois[r] + "_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip";
                        print(roiFile);
                        
                        // Open the ROI
                        roiManager("Open",roiFile);
                        roiManager("Sort");

                        // Get counts in VOI for each iteration image
                        selectWindow(itt[i]);
                        voiCounts = countsROImanager();
                        geometry = newArray(2);
                        geometry = getVolumeArea();
                        nVoxels = voxelsROImanager();

                        // Close VOI
                        roiManager("reset")

                        // Save the results to an array
                        pdf_voiCounts[nr] = voiCounts;
                        pdf_volume[nr] = geometry[0];
                        pdf_area[nr] = geometry[1];
                        pdf_nVoxels[nr] = nVoxels;
                        
                        // Save results to table
                        selectWindow("VOI");
                        Table.set("Camera", jj, cameraID);
                        Table.set("Energy", jj, windowName);
                        Table.set("Phantom", jj, phantoms[p]);
                        Table.set("Correction", jj, corrections[c]);
                        Table.set("Iterations", jj, itt[i]);
                        Table.set("nr", jj, nr);                        
                        Table.set("VOI", jj, rois[r]);
                        Table.set("VOI Counts", jj, voiCounts);
                        Table.set("VOI Volume (mm^3)",jj, d2s(geometry[0],2));
                        Table.set("VOI Surface Area (mm^2)",jj, d2s(geometry[1],2));
                        jj++;
                        
                    }

                    // Now that we have the full set of results analyse them to debug

                    // Loop through the results
                    for (rr = 0 ; rr < pdf_voiCounts.length; rr++){

                        // Get the cumulative stats for the sub array
                        Array.getStatistics(Array.trim(pdf_voiCounts,rr), min_voiCounts, max_voiCounts, mean_voiCounts, stdDev_voiCounts);

                        // Save these to a table

                        selectWindow("Uncertainties");
                        Table.set("VOI", kk, rois[r]);
                        Table.set("Seed", kk, seed);                        
                        
                        Table.set("nRand", kk, rr);                        
                        
                        Table.set("Counts", kk, pdf_voiCounts[rr]);                    
                        Table.set("Mean(counts)", kk, mean_voiCounts);
                        Table.set("StdDev(counts)", kk, stdDev_voiCounts);
                        Table.set("u(counts) [%]", kk, 100.0*(stdDev_voiCounts/mean_voiCounts));
                        
                        kk++;


                    }


                    // // Get the uncertainty for the VOI
                    // Array.getStatistics(pdf_voiCounts, min_voiCounts, max_voiCounts, mean_voiCounts, stdDev_voiCounts);
                    // Array.getStatistics(pdf_volume, min_volume, max_volume, mean_volume, stdDev_volume);
                    // Array.getStatistics(pdf_area, min_area, max_area, mean_area, stdDev_area);
                    // Array.getStatistics(pdf_nVoxels, min_nVoxels, max_nVoxels, mean_nVoxels, stdDev_nVoxels);

                    // selectWindow("Uncertainties");
                    // Table.set("Camera", kk, cameraID); windowName +
                    // Table.set("Energy", kk, windowName);
                    // Table.set("Phantom", kk, phantoms[p]);
                    // Table.set("Correction", kk, corrections[c]);
                    // Table.set("Iterations", kk, itt[i]);
                    // Table.set("Iterations", kk, itt[i]);
                    // Table.set("VOI", kk, rois[r]);
                    // Table.set("nRand", kk, sub_set);                        
                    
                    // Table.set("Counts", kk, m_voiCounts);                    
                    // Table.set("Mean(counts)", kk, mean_voiCounts);
                    // Table.set("StdDev(counts)", kk, stdDev_voiCounts);
                    // Table.set("u(counts) [%]", kk, 100.0*(stdDev_voiCounts/mean_voiCounts));
                    
                    // Table.set("VOI Volume (mm^3)", kk, m_geometry[0]);
                    // Table.set("Mean(volume)", kk, mean_volume);
                    // Table.set("StdDev(volume)", kk, stdDev_volume);
                    // Table.set("u(volume) [%]", kk, 100.0*(stdDev_volume/mean_volume));

                    // Table.set("VOI Surface Area (mm^2)", kk, m_geometry[1]);
                    // Table.set("Mean(area)", kk, mean_area);
                    // Table.set("StdDev(area)", kk, stdDev_area);
                    // Table.set("u(area) [%]", kk, 100.0*(stdDev_area/mean_area));

                    // Table.set("nVoxels", kk, m_nVoxels);
                    // Table.set("Mean (nVoxels)", kk, mean_nVoxels);
                    // Table.set("StdDev (nVoxels)", kk, stdDev_nVoxels);
                    // Table.set("u(nVoxels) [%]", kk, 100.0*(stdDev_nVoxels/mean_nVoxels));

                    // kk++;

                } // ROI loop

                // Close Image
                close(itt[i]);
    


            }
        }                           
    }
    
    // Save Tables
    // selectWindow("VOI");
    // Table.update;
    // Table.save(savePath + cameraID + "_" + phantomID + "_" + windowName + "_" + nRand + "_" + sub_set + "_VOIstats.csv"); 
    selectWindow("Uncertainties");
    Table.update;
    Table.save(savePath + cameraID + "_" + phantomID + "_" + windowName + "_" + nRand + "_" + sub_set + "_VOIuncertainties-DEBUG.csv"); 
    // selectWindow("Whole Image");
    // Table.update;
    // Table.save(savePath + cameraID + "_" + phantomID + "_" + windowName + "_" + nRand + "_" + sub_set + "_WholeImagestats.csv"); 


} 
// ***********************************************************************
// * Common library of ImageJ macro functions
// * 
// * Functions can be appended to the end of macro file before running
// * using runM.sh
// 
// * Revised APR: 01/08/22
// ***********************************************************************

// **********************
// * Global Variables
// **********************
var DICOM_DATA_PATH = "/home/apr/Science/GE-RSCH/QI/data/DicomData/";
var roiDirectory = "/home/apr/Science/GE-RSCH/QI/analysis-clean/image-analysis/rois/";

// Parse the passed arguments and get the dataset to open
function parseArguments(){

    // Get the data names from arguments
    args = split(getArgument(), " ");
    cameraID = args[0];
    phantomID = args[1];

    if (args.length < 2){
        print("ERROR: must specify at least 2 arguments (camera phantom");
        Array.print(args);
        exit();
    }
    
    if (phantomID == "Sphere1"){
        if (args.length != 3){
            print("ERROR: must specify 3 arguments (camera phantom sphereID");
            Array.print(args);
            exit();
        }
    }

    if (args.length == 3){
        roiID = args[2];
    }
    else{
        // Default to the CT roi
        roiID = "_CT";
    }
    

    // Construct array to return
    res = newArray(3);
    res[0] = cameraID;
    res[1] = phantomID;
    res[2] = roiID;

    return res;
}

// Open the correct CT image for the specified dataset
function openCTData(cameraID, phantomID){

    if (cameraID == "DR" && phantomID == "Cylinder"){
        CTfile = DICOM_DATA_PATH + "/DR/Cylinder/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
        CTslices = 321;
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Cylinder"){
        CTfile = DICOM_DATA_PATH + "/CZT/WEHR/Cylinder/CT/CTAC5mmCYLINDER_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Cylinder"){
        CTfile = DICOM_DATA_PATH + "/CZT/MEHRS/Cylinder/CT/CTAC5mmCYLINDER_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "Optima" && phantomID == "Cylinder"){
        CTfile = DICOM_DATA_PATH + "/Optima/Cylinder/CT/CTSPECT-CT_H_1001_CT001.dcm";
        CTslices = 161;
    }

    if (cameraID == "DR" && phantomID == "Sphere1"){
        CTfile = DICOM_DATA_PATH + "/DR/Sphere1/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
        CTslices = 321;
    }

    if (cameraID == "Optima" && phantomID == "Sphere1"){
        CTfile = DICOM_DATA_PATH + "/Optima/Sphere1/CT/CTSPECT-CT_H_1001_CT001.dcm";
        CTslices = 161;
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Sphere1"){
        CTfile = DICOM_DATA_PATH + "/CZT/WEHR/Sphere1/CT/CTAC5mmSPHERES1_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Sphere1"){
        CTfile = DICOM_DATA_PATH + "/CZT/MEHRS/Sphere1/CT/CTAC5mmSPHERES1_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "DR" && phantomID == "Sphere2"){
        CTfile = DICOM_DATA_PATH + "/DR/Sphere2/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
        CTslices = 321;
    }

    if (cameraID == "Optima" && phantomID == "Sphere2"){
        CTfile = DICOM_DATA_PATH + "/Optima/Sphere2/CT/CTSPECT-CT_H_1001_CT001.dcm";
        CTslices = 161;
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Sphere2"){
        CTfile = DICOM_DATA_PATH + "/CZT/WEHR/Sphere2/CT/CTAC5mmSPHERES2_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Sphere2"){
        CTfile = DICOM_DATA_PATH + "/CZT/MEHRS/Sphere2/CT/CTAC5mmSPHERES1_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "DR" && phantomID == "2-Organ"){
        CTfile = DICOM_DATA_PATH + "/DR/2-Organ/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
        CTslices = 321;
    }

    if (cameraID == "Optima" && phantomID == "2-Organ"){
        CTfile = DICOM_DATA_PATH + "/Optima/2-Organ/CT/CTSPECT-CT_H_1001_CT001.dcm";
        CTslices = 161;
    }

    if (cameraID == "CZT-WEHR" && phantomID == "2-Organ"){
        CTfile = DICOM_DATA_PATH + "/CZT/WEHR/2-Organ/CT/CTAC5mmTomoLu-177_H_1001_CT001.dcm";
        CTslices = 80;
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "2-Organ"){
        CTfile = DICOM_DATA_PATH + "/CZT/WEHR/2-Organ/CT/CTAC5mmTWOORGANMEHRS_H_1001_CT001.dcm";
        CTslices = 80;
    }

    run("Image Sequence...", "open=" + CTfile + " number=" + CTslices + " starting=1 increment=1 scale=100 file=[] sort");
    rename("CT");
}

// Open the ROI set
function openROI(cameraID, phantomID, roiID){

    roiFile = roiDirectory+cameraID+ "_" + phantomID + roiID + "_RoiSet_XYZ.zip";
    roiManager("Open",roiFile);
    roiManager("Sort");

}

// Open the Sphere Centres
function openCTsphereCentres(cameraID, phantomID){

    roiFile =roiDirectory + "centres/"+cameraID+ "_" + phantomID + "_CT_Centres_RoiSet.zip";
    roiManager("Open",roiFile);

}

// Open the correct NM image for the specified dataset
function openNMData(cameraID, phantomID){

    if (cameraID == "DR" && phantomID == "Cylinder"){
        NMfile = DICOM_DATA_PATH + "DR/Cylinder/Recon/SPECTCT_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Cylinder"){
        NMfile = DICOM_DATA_PATH + "CZT/WEHR/Cylinder/Recon/CYLINDER_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Cylinder"){
        NMfile = DICOM_DATA_PATH + "CZT/MEHRS/Cylinder/Recon/CYLINDER_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "Optima" && phantomID == "Cylinder"){
        NMfile = DICOM_DATA_PATH + "Optima/Cylinder/Recon/SPECT-CT_EM2_IRAC001_DS.dcm";      
    }

    if (cameraID == "DR" && phantomID == "Sphere1"){
        NMfile = DICOM_DATA_PATH + "DR/Sphere1/Recon/SPECTCT_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Sphere1"){
        NMfile = DICOM_DATA_PATH + "CZT/WEHR/Sphere1/Recon/SPHERES1_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Sphere1"){
        NMfile = DICOM_DATA_PATH + "CZT/MEHRS/Sphere1/Recon/SPHERES1MEHRS_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "Optima" && phantomID == "Sphere1"){
        NMfile = DICOM_DATA_PATH + "Optima/Sphere1/Recon/SPECT-CT_EM2_IRAC001_DS.dcm";      
    }

    if (cameraID == "DR" && phantomID == "Sphere2"){
        NMfile = DICOM_DATA_PATH + "DR/Sphere2/Recon/SPHERES2_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "Optima" && phantomID == "Sphere2"){
        NMfile = DICOM_DATA_PATH + "Optima/Sphere2/Recon/SPECT-CT_EM2_IRAC001_DS.dcm";      
    }

    if (cameraID == "CZT-WEHR" && phantomID == "Sphere2"){
        NMfile = DICOM_DATA_PATH + "CZT/WEHR/Sphere2/Recon/SPHERES2_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "Sphere2"){
        NMfile = DICOM_DATA_PATH + "CZT/MEHRS/Sphere2/Recon/SPHERES2MEHRS_EM2_IRAC001_DS.dcm";
    }


    if (cameraID == "DR" && phantomID == "2-Organ"){
        NMfile = DICOM_DATA_PATH + "DR/2-Organ/Recon/SPECTCT_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "Optima" && phantomID == "2-Organ"){
        NMfile = DICOM_DATA_PATH + "Optima/2-Organ/Recon/SPECT-CT_EM2_IRAC001_DS.dcm";      
    }

    if (cameraID == "CZT-WEHR" && phantomID == "2-Organ"){
        NMfile = DICOM_DATA_PATH + "CZT/WEHR/2-Organ/Recon/TomoLu-177_EM2_IRAC001_DS.dcm";
    }

    if (cameraID == "CZT-MEHRS" && phantomID == "2-Organ"){
        NMfile = DICOM_DATA_PATH + "CZT/MEHRS/2-Organ/Recon/TWOORGANMEHRS_EM2_IRAC001_DS.dcm";
    }

    open(NMfile);
    rename("NM");
    run("Fire");
}

// Return the centre slice of a CT image based on the profile
function centreSliceCT(){

    // Get slice thickness 
    getVoxelSize(width, height, depth, unit);
    
    run("Reslice [/]...", "output="+depth+" start=Top avoid");
    selectWindow("Reslice of CT");
    setSlice(nSlices()/2);
    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    setKeyDown("alt"); ct_z = getProfile();
    //run("Plot Profile");

    ct_z_max = Array.findMaxima(ct_z,0.00001);
    ct_z_min = Array.findMinima(ct_z,0.00001);
    ct_z_half = (ct_z[ct_z_max[0]]+ct_z[ct_z_min[0]])/2;

    //print(ct_z[ct_z_max[0]] + " "+ ct_z[ct_z_min[0]] + " " + ct_z_half);
    
    centre_z = centreProfile(ct_z, ct_z_half);
        
    return round(centre_z);
}

// Return the centre of a profile based on values passing threshold twice
function centreProfile(profile, threshold){

    for (i = 0; i < profile.length / 2; i++){
        if (profile[i] < threshold){
            lower = i;
        }
        if (profile[profile.length-i-1] < threshold){
            upper = profile.length-i-1;
        }
    }
    centre = (upper + lower) / 2;
    //print("lower: " + lower + " upper: " + upper + " centre: " + centre);
    
    return centre;
}


// Return the centre of a profile based on values passing threshold twice
// - unc_profile = % unc for intensity of each profile position (gauss)
// - unc_threshold = % to vary threshold within (rect)
function centreProfileRand(profile, threshold, unc_profile, unc_threshold){

    // Randomly vary the voxel values within the uncertainty
    //Array.print(profile);
    p_two = newArray(profile.length);

    for (i = 0; i < profile.length; i++){
        p_two[i] = getGaussian(profile[i],unc_profile/100.0*profile[i]);
    }

    // Array.print(p_two);
    //Plot.create("New profile", "X", "Y", p_two);

    // Randomly vary the threshold
    new_threshold = getRectangular(threshold,unc_threshold/100.0*threshold);
    // print("new_threshold = " + new_threshold);

    for (i = 0; i < p_two.length / 2; i++){
        if (p_two[i] < new_threshold){
            lower = i;
        }
        if (p_two[profile.length-i-1] < new_threshold){
            upper = profile.length-i-1;
        }
    }
    centre = (upper + lower) / 2;
    // print("lower: " + lower + " upper: " + upper + " centre: " + centre);
    
    return centre;
}

//------------------------------------------------------------------
// creatCylinder but with a random choice of last slice
function createCylinderRand(x, y, z, R, H){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
  
    // See how many slices we need
    ns = round(H / depth);
    print("H = " + H + " nSlices = " + ns + " depth = " + depth);

    // If this is odd then we add an even number of slices either slide of z
    // If it is even then we have to go 1 more slice on one slide or the other...!
    if (ns%2 == 1){
        first_slice = z - floor(ns/2);
        last_slice  = z + floor(ns/2);
    }
    if (ns%2 == 0){
        // Decide randomly which way to place the first and last slices
        if (random() < 0.5){
            //print("One");
            first_slice = z - floor(ns/2);
            last_slice  = z + floor(ns/2) - 1; 
        }
        else{
            //print("Two");
            first_slice = z - floor(ns/2) + 1;
            last_slice  = z + floor(ns/2);
        }

    }

    // Check we haven't gone off the end of image
    if(first_slice < 0){
        first_slice = 1;
    }
    if(last_slice > nSlices){
        last_slice = nSlices;
    }
    // print("First: " + first_slice + " Last: :" + last_slice);
    // print(floor(ns/2));
    // print(z);

    for (i = first_slice; i <= last_slice; i++){
        createCircle(x, y, i, R);
    }
	    
}

//------------------------------------------------------------------
// Generate cylindrical VOI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius in mm
//  - H is the height in mm
function createCylinder(x, y, z, R, H){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
  
    // See how many slices we need
    ns = round(H / depth);
    print("H = " + H + " nSlices = " + ns + " depth = " + depth);

    // If this is odd then we add an even number of slices either slide of z
    // If it is even then we have to go 1 more slice on one slide or the other...!
    if (ns%2 == 1){
        first_slice = z - floor(ns/2);
        last_slice  = z + floor(ns/2);
    }
    if (ns%2 == 0){
        first_slice = z - floor(ns/2);
        last_slice  = z + floor(ns/2) - 1;
    }

    // Check we haven't gone off the end of image
    if(first_slice < 0){
        first_slice = 1;
    }
    if(last_slice > nSlices){
        last_slice = nSlices;
    }
    // print("First: " + first_slice + " Last: :" + last_slice);
    // print(floor(ns/2));
    // print(z);

    for (i = first_slice; i <= last_slice; i++){
        createCircle(x, y, i, R);
    }
	    
}

//------------------------------------------------------------------
// Generate circular ROI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius in mm
function createCircle(x, y, z, R){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
    // width = abs(width);
    // height = abs(height);
    // depth = abs(depth);
    
    // Convert R to voxels
    r = R / width;
    //print("Radius = " + R + " mm = " + r + " voxels");
	
    setSlice(z);
    makeOval(x-r, y-r, 2*r, 2*r);
	roiManager("Add");
	    
}


//------------------------------------------------------------------
// Calculate the alignment between NM and CT from Infinia Hawkeye 4
// NMname is the open nuclear medicine image to use
// CTname is the open CT image to use
//
// Return an array with dX, dY in voxels
function calcNMCTalignmentXY(NMname, CTname){

    // Extract the Dicom fields -> 0020,0032  Image Position (Patient): 
    selectWindow(NMname);
    NMdicom = split( getInfo("0020,0032"),"\\");
    getVoxelSize(nm_width, nm_height, nm_depth, nm_unit);
    selectWindow(CTname);
    CTdicom = split( getInfo("0020,0032"),"\\");
    getVoxelSize(ct_width, ct_height, ct_depth, ct_unit);

    // Calculate the shifts in mm
    // - The centre of the first voxels are in differnet place so we need to shift the CT ROIS over by this amount before scaling
    // - The DICOM headers have the positions in mm but we also need to account for imagej using the top of the voxel as zero and shift by an extra half voxel for each modaility in the SAME direction so +  one a - the other
    // - Finally we convert mm to CT voxels for shifting the CT ROIS

    delta = newArray(2);
    delta[0] = (parseFloat(CTdicom[0]) - parseFloat(NMdicom[0] )+ nm_width/2 - ct_width/2) / ct_width;
    delta[1] = (parseFloat(CTdicom[1]) - parseFloat(NMdicom[1]) + nm_height/2 -ct_height /2) / ct_height;
    
    return delta;
}

//------------------------------------------------------------------
// Calculate the scale between NM and CT from Infinia Hawkeye 4
// NMname is the open nuclear medicine image to use
// CTname is the open CT image to use
//
// Return an array with scaleX, scaleY and scaleZ 
function calcNMCTscale(NMname, CTname){

    // Extract the voxel sizes
    selectWindow(NMname);
    getVoxelSize(nm_width, nm_height, nm_depth, nm_unit);
    selectWindow(CTname);
    getVoxelSize(ct_width, ct_height, ct_depth, ct_unit);
    
    //print(nm_width + " " + nm_height+ " " + nm_depth+ " " + nm_unit);
    //print(ct_width + " " + ct_height+ " " + ct_depth+ " " + ct_unit);


    // Calculate the scale
    // [0] = x (CT / NM), [1] = y (CT / NM), [2] =**Need to fix problem with CZT smallest sphere being only 1 slice thick (does not save ROI set)** z (NM / CT)
    delta = newArray(3);
    delta[0] = ct_width / nm_width;
    delta[1] = ct_height / nm_height;
    delta[2] = ct_depth / nm_depth;

    return delta;
}

//------------------------------------------------------------------
// Loop through ROI manger and translate all ROIs
// We can move the ROIs by an amount dZ through the stack
// All values in mm
function translateROImanagerdXdY(dX, dY){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("transdXdY start = " + current);
    
    for (i = 0; i < count; i++) { 
	    roiManager("select", i);
	
	    //print("[" + i + "] Current Slice = " + getSliceNumber());

	    // Translate in X and Y
	    translateROIdXdY(dX, dY); 
	    roiManager("update");
    }

}

//------------------------------------------------------------------
// Translate the selected ROI (will remove the old ROI)
// Position is in mm
function translateROIdXdY(dX, dY) { 

    // Move the ROI in X and Y
    //type = selectionType();
    type = Roi.getType ;
    getSelectionCoordinates(x, y); 
    
    //print("shift = " + dX + " " + dY);

    for (i = 0; i < x.length; i++) { 
        // print ("Old = " + x[i] + " :" + y[i]);
        x[i] = x[i] + dX; 
        y[i] = y[i] + dY; 
        // print ("New = " + x[i] + " :" + y[i]);
    } 
    makeSelection(type, x, y); 

} 
//------------------------------------------------------------------

//------------------------------------------------------------------
// Loop through ROI manger and rescale all ROIs
function scaleROImanager(factor){
    count = roiManager("count"); 
    current = roiManager("index"); 
    //print("scale start = " + current);

    for (i = 0; i < count; i++) { 
        roiManager("select", i);
        //print("selected " + i);
        scaleROI(factor); 
        //print("scaled " + i);
        roiManager("update");
        //print("updated " + i);
    }
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Scale the currently selected ROI and overwrite
// Position is in mm
function scaleROI(factor) { 
    //type = selectionType();
    type = Roi.getType ; 
    getSelectionCoordinates(x, y); 
    for (i = 0; i < x.length; i++) { 
        //print ("OLD:" + x[i] + " :" + y[i]);
        x[i] = x[i] * factor; 
        y[i] = y[i] * factor;
        //print ("NEW:" + x[i] + " :" + y[i]);
    } 

    makeSelection(type, x, y); 
} 
//------------------------------------------------------------------


//------------------------------------------------------------------
// Loop through ROI manger and move each ROI to the corresponding NM slice
// - NMname = Nuclear medicine image to use
// - CTname = CT image to use
function ctToNMROImanagerZ(NMname, CTname){

    // Extract the voxel sizes
    selectWindow(NMname);
    getVoxelSize(nm_width, nm_height, nm_depth, nm_unit);
    nmSlicesMax = nSlices;

    selectWindow(CTname);
    getVoxelSize(ct_width, ct_height, ct_depth, ct_unit);

    // Get the starting position for NM slices
    selectWindow("NM");
    setSlice(1);
    NMdicom = split( getInfo("0020,0032"),"\\");
    nmStart = parseFloat(NMdicom[2]);


    // Loop through all the rois
    count = roiManager("count"); 
    current = roiManager("index"); 

    for (i = 0; i < count; i++) { 
        selectWindow("CT");
        roiManager("select", 0); // New ROI goes to bottom so always pick "top" next

        // Get the position of this slice
        CTdicom = split(getInfo("0020,0032"),"\\");
        ctSlice = getSliceNumber();

        // Calculate the NM slice for that position
        nmSlice = ((parseFloat(CTdicom[2]) - nmStart) / nm_depth) +1;


        // // Check we are not going off the end of the NM image
        // if (round(nmSlice) > nmSlicesMax-1){
        //     nmSlice = nmSlicesMax-1;
        // }

        //print("[" + i +"] CT Slice: " + ctSlice + " ---> NM Slice: " + nmSlice + " (" + round(nmSlice) + ")" );

        selectWindow("NM");
        moveROIslice(round(nmSlice));

    }

    // Now merge the ROIS on the same slice (only need to do this if we have multiple ROIs)
    currentSlice = -99;
    if (count > 1){
    
        //print("will process " + count + " rois");

        //Keep track of how many ROIS we merged
        nMerged = 0;
        for (i = 0; i < count; i++) { 
            
            roiManager("select", i);
            thisSlice = getSliceNumber();
            //print("i="+i+ " slice = " + thisSlice);
            if (i == 0){
                currentSlice = thisSlice;
                mergeArray = newArray(1);
                mergeArray[0] = 0;
                //print("FIRST set: " + currentSlice);
            }
            else{            
                if (thisSlice == currentSlice){
                    // Add to the array of slices to merge
                    mergeArray = Array.concat(mergeArray, i);
                }
                if ((thisSlice > currentSlice) || (thisSlice < currentSlice) || (i == count-1)){
                    // Merge the array and set current slice
                    //print(thisSlice + " < or > " + currentSlice);
                    //print("Will merge ROIs:");
                    //Array.print(mergeArray);
                
                    currentSlice = thisSlice;
                
                    // Do the merge
                    if(mergeArray.length > 1){
                        roiManager("select", mergeArray);
                        roiManager("Or");
                        roiManager("Add");
                        //print("MERGED");
                        nMerged = nMerged + mergeArray.length;
                        //print("nMERGED = "+ nMerged);
                    }
                    else{
                        // We may have a single ROI on a  slice in which we don't need to merge
                        roiManager("select", mergeArray);
                        roiManager("Add");
                        nMerged = nMerged + mergeArray.length;
                        //print("nMERGED = "+ nMerged);
                    }
                    // Reset array
                    mergeArray = newArray(1);
                    mergeArray[0] = i;
                }
            }
        }

        //print("Need to delete "+ nMerged);

        // Delete the original ROIS (can I do this in one loop?)
        for (i = 0; i < nMerged; i++) { 
            roiManager("deselect");
            //print("Deleting " + i);
            roiManager("select", 0);
            roiManager("delete");   
        }
    }
    
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Move current ROI to new slice
function moveROIslice(nmSlice){ 

    // Store the ROi we were called with
    called = roiManager("index"); 
    //called = 0;    

    // Calculate the new slice
    roiManager("Remove Slice Info");
    setSlice(nmSlice);

    // Move the ROI to the current slice
     roiManager("select", called);
     roiManager("Add");

     // Delete the old ROI we were called with
     roiManager("select", called);
     roiManager("Delete");
} 
//------------------------------------------------------------------

//------------------------------------------------------------------
// Get total voxels in ROI manager
function voxelsROImanager(){
    DEBUG = 0;

    count = roiManager("count"); 
    current = roiManager("index"); 

    // Variable for output
    results = 0;

    for (i = 0; i < count; i++) { 
	    roiManager("select", i); 

        Roi.getContainedPoints(t_x, t_y)
        results = results + t_x.length;
    
    }

    return results;
}
//------------------------------------------------------------------


//------------------------------------------------------------------
// Get total counts in ROI manager
function countsROImanager(){
    DEBUG = 0;

    count = roiManager("count"); 
    current = roiManager("index"); 

    // Variable for output
    results = 0;

    // Set the measurements we want to make
    run("Set Measurements...", "integrated stack display redirect=None decimal=5");

    for (i = 0; i < count; i++) { 
	    roiManager("select", i); 
	
    
        if (DEBUG > 0){
            run("Measure");                                                                    
            if (getResult("RawIntDen") != NaN){
                results += getResult("RawIntDen");               
            }
        }
        else{
            List.setMeasurements;
            if (List.getValue("RawIntDen") != NaN){
                results = results + List.getValue("RawIntDen");
            }
            List.clear();
        }	

	    roiManager("update");
    }

    return results;
}
//------------------------------------------------------------------

//---------------------------------------------------------------------------
// Measure total counts in stack
// - Return the total counts in image
function sumStack(){
    run("Z Project...", "projection=[Sum Slices]");
    rename("_sum");

    // Set the measurements we want to make 
    run("Set Measurements...", "area min bounding shape integrated stack display redirect=None decimal=5");

    // Measure
    List.setMeasurements;
    results = List.getValue("RawIntDen");
    List.clear();

    close("_sum");

    return results;
    
}
//---------------------------------------------------------------------------


//------------------------------------------------------------------
// Loop through ROI manger and return the volume and surface area defined by ROI
// For surface area no interpolation is applied
function getVolumeArea(){
    count = roiManager("count"); 
    current = roiManager("index"); 

    // Get the scale of image
    getVoxelSize(width, height, depth, unit);
    width = abs(width);
    height = abs(height);
    depth = abs(depth);
    
    // Array for output [0] = area [1] = perimeter
    results = newArray(2);

    // How much area did the last ROI enclose?
    lastArea = 0.0;

    // Set the measurements we want to make
    run("Set Measurements...", "area perimeter stack display redirect=None decimal=10");

    for (i = 0; i < count; i++) { 
        roiManager("select", i); 
        
        // Run the measurements
        List.setMeasurements;

        // Sum volumes for each slice
        results[0] += List.getValue("Area") * depth;
        
        // Sum the "strips" of surface area defined by perimeter
        results[1] += List.getValue("Perim.") * depth;
        
        // For the first slice add the surface area of the outside face
        if (i == 0){
            results[1] += List.getValue("Area");
            lastArea = List.getValue("Area");
        }
        // For all other slices add the difference between areas (the overlap in Z)
        else{
            results[1] += abs(List.getValue("Area") - lastArea);
            lastArea = List.getValue("Area");
            
            // If we are on the last slice then add the area of the other end face
            if (i == count - 1){
                results[1] += List.getValue("Area");
            }
        }
        
        List.clear();
        roiManager("update");
    }

    return results;
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Generate a spherical ROI data on the open image centered on (x,y,z)
//  - x,y,z are given in terms of slice or voxel
//  - R is the radius of the sphere in mm
function createSphere(x, y, z, R){

    // Get image stats
    getVoxelSize(width, height, depth, unit);
    width = abs(width);
    height = abs(height);
    depth = abs(depth);
        
    // Calculate how many slices we need in each direction
    numberSlices = round(R / depth);
    numberSlices = numberSlices + 2; // Make sure we go past the end with the calculation (but not the slices)

    for(i = 0; i <= numberSlices; i++) {
        
        // Get the radius for this slice
        // Move the position of the first slice up by the rounding error
        //roundError = round(R / depth) - (R /depth);
        roundError = 0;
        r = getSegmentRadius(R, i*depth + roundError);
        r = r /width;

        // Make sure the radius is valid for this slice
        if(r > 0){
            
            // If first slice just one ROI
            if (i == 0){
                setSlice(z);
                makeOval(x-r, y-r, 2*r, 2*r);
                roiManager("Add");
            }
            else{
                setSlice(z+i);
                makeOval(x-r, y-r, 2*r, 2*r);
                roiManager("Add");
                setSlice(z-i);
                makeOval(x-r, y-r, 2*r, 2*r);
                roiManager("Add");
            }
        }
}

roiManager("Sort");
    
}
//------------------------------------------------------------------

//------------------------------------------------------------------
// Given a radius and a height from the centre return segment radius
function getSegmentRadius(r,h){

    if ((r*r - h*h) < 1){
	    a = -99;
    }
    else{
        a = sqrt(r*r - h*h);
    }
    
    return a;
    
}
//------------------------------------------------------------------

//---------------------------------------------------------------------------
// Close all open windows with out saving
//
function closeAllWindows(){
    list = getList("window.titles"); 
    for (i=0; i<list.length; i++){ 
	winame = list[i]; 
     	selectWindow(winame); 
	run("Close"); 
    } 
}
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------
// Close all open images without saving
//
function closeAllImages(){
    while (nImages>0) { 
        selectImage(nImages); 
        close(); 
    } 
}
//---------------------------------------------------------------------------



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

//---------------------------------------------------------------------------                                                        
// Return a nicely formatted time stamp string                                                                                       
function printTime() {
    MonthNames = newArray("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
    DayNames = newArray("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    TimeString = "Date: " + DayNames[dayOfWeek] + " ";
    if (dayOfMonth < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + dayOfMonth + "-" + MonthNames[month] + "-" + year + " Time: ";
    if (hour < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + hour + ":";
    if (minute < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + minute + ":";
    if (second < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + second;

    return TimeString;
}
//---------------------------------------------------------------------------   