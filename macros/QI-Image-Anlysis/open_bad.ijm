// SPDX-License-Identifier: GPL-3.0-or-later
/* 
    Get the value of a measurand using a PDF for a VOI
*/

var DATA_DIR = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/";
var RESULTS_DIR = "/home/apr/Science/GE-RSCH/QI/analysis-clean/image-analysis/results/";

// --- Variables ----
var savePath = "/home/apr/Science/rois/debug/"
var zoom_factor = 1.0;
var nRand = 1000; // Number of random perturbation of VOI
var seed = 2; // Random number seed
var sub_set = 150;

macro "loop_all_data_unc" {

    cameraID = "DR";
    windowName = "EM2";
    phantomID = "Cylinder"
    itt = 30;
    corrections = "AC";
    rois = "_CT_NM";

    // Open the Nuc Med file
    fileName = DATA_DIR+cameraID+"/"+phantomID+"/" + windowName + "/SS5_IT" + itt + "/SPECTCT_"+windowName+"_IR"+corrections+"001_DS.dcm";
    open(fileName);
    rename(itt);
    run("Fire");

    // Open ROI
    nr = 131;
    roiFile = savePath + cameraID + "_" + phantomID + rois + "_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip";
    print(roiFile);
    roiManager("Open",roiFile);
    roiManager("Sort");
}