// SPDX-License-Identifier: GPL-3.0-or-later
/* 
    Get the value of a measurand using a PDF for a VOI
*/

var DATA_DIR = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/";
var RESULTS_DIR = "/home/apr/Science/GE-RSCH/QI/analysis-clean/image-analysis/results/";
var testPath = "/var/home/apr/Science/rois/"

macro "loop_all_data_unc" {

    cameraID = "DR";
    windowName = "EM2";
    // phantoms = newArray("Cylinder","Sphere1","Sphere2","2-Organ");
    phantoms = newArray(1);
    phantoms[0] = "Sphere1"

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

                zoom_factor = 2.0;
                seed = 2;
                nRand = 100;

                for (r = 0; r < rois.length; r++){
            
                    // Get the "true" measurand value
                    // Open the ROI
                    openROI(cameraID,phantoms[p],rois[r]);
                    selectWindow(itt[i]);
                    m_voiCounts = countsROImanager();
                    m_geometry = newArray(2);
                    m_geometry = getVolumeArea();
                    roiManager("reset")

                    // Array to store the PDF
                    pdf_voiCounts = newArray(nRand);
                    pdf_area = newArray(nRand);
                    pdf_volume = newArray(nRand);

                    // Loop through the VOI perturbations
                    for (nr = 0; nr < nRand; nr++){

                        // Construct the file name
                        roiFile = testPath + cameraID+ "_" + phantomID + rois[r] + "_RoiSet_XYZ_zoom_" + zoom_factor + "_seed_" + seed + "_nr_" + nr + ".zip";
                        print(roiFile);
                        
                        // Open the ROI
                        roiManager("Open",roiFile);
                        roiManager("Sort");

                        // Get counts in VOI for each iteration image
                        selectWindow(itt[i]);
                        voiCounts = countsROImanager();
                        geometry = newArray(2);
                        geometry = getVolumeArea();

                        // Close VOI
                        roiManager("reset")

                        // Save the results to an array
                        pdf_voiCounts[nr] = voiCounts;
                        pdf_volume[nr] = geometry[0];
                        pdf_area[nr] = geometry[1];
                        
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

                    // Get the uncertainty for the VOI
                    Array.getStatistics(pdf_voiCounts, min_voiCounts, max_voiCounts, mean_voiCounts, stdDev_voiCounts);
                    Array.getStatistics(pdf_volume, min_volume, max_volume, mean_volume, stdDev_volume);
                    Array.getStatistics(pdf_area, min_area, max_area, mean_area, stdDev_area);

                    selectWindow("Uncertainties");
                    Table.set("Camera", kk, cameraID);
                    Table.set("Energy", kk, windowName);
                    Table.set("Phantom", kk, phantoms[p]);
                    Table.set("Correction", kk, corrections[c]);
                    Table.set("Iterations", kk, itt[i]);
                    Table.set("Iterations", kk, itt[i]);
                    Table.set("VOI", kk, rois[r]);
                    Table.set("nRand", kk, nRand);                        
                    
                    Table.set("Counts", kk, m_voiCounts);
                    Table.set("Mean(counts)", kk, mean_voiCounts);
                    Table.set("StdDev(counts)", kk, stdDev_voiCounts);
                    Table.set("u(counts) [%]", kk, 100.0*(stdDev_voiCounts/mean_voiCounts));
                    
                    Table.set("VOI Volume (mm^3)", kk, m_geometry[0]);
                    Table.set("Mean(volume)", kk, mean_volume);
                    Table.set("StdDev(volume)", kk, stdDev_volume);
                    Table.set("u(volume) [%]", kk, 100.0*(stdDev_volume/mean_volume));

                    Table.set("VOI Surface Area (mm^2)", kk, m_geometry[1]);
                    Table.set("Mean(area)", kk, mean_area);
                    Table.set("StdDev(area)", kk, stdDev_area);
                    Table.set("u(area) [%]", kk, 100.0*(stdDev_area/mean_area));

                    kk++;

                } // ROI loop

                // Close Image
                close(itt[i]);
    


            }
        }                           
    }
    
    // Save Tables
    selectWindow("VOI");
    Table.update;
    Table.save(testPath + cameraID + "_" + windowName + "_VOIstats.csv"); 
    selectWindow("Uncertainties");
    Table.update;
    Table.save(testPath + cameraID + "_" + windowName + "_VOIuncertainties.csv"); 
    selectWindow("Whole Image");
    Table.update;
    Table.save(testPath + cameraID + "_" + windowName + "_WholeImagestats.csv"); 


}