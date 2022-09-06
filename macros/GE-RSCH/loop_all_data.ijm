/* 
    Get the stats for all datasets into a table
*/
macro "loop_all_data" {

    cameraID = "DR";
    windowName = "EM1";

    // Create output tables
    // Make a Table for output
    table_name = "Whole Image";
    Table.create(table_name);
    ii = 0;
      
    table_name = "VOI";
    Table.create(table_name);
    jj= 0;

    // Loop through all the phantoms
    phantoms = newArray("Cylinder","Sphere1","Sphere2","2-Organ");

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
        corrections = newArray("NC","AC","ACSC");
                                   
        for (c = 0; c < corrections.length; c++){
            
            // Loop through reconstruction itterations
            itt = newArray(1,2,3,4,5,10,20,30,40,50);

            for (i = 0; i < itt.length; i++){

                print(phantoms[p] + ":" + corrections[c] + ":" + itt[i]);

                // Open the Nuc Med file
                fileName = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/"+cameraID+"/"+phantomID+"/" + windowName + "/SS5_IT" + itt[i] + "/SPECTCT_"+windowName+"_IR"+corrections[c]+"001_DS.dcm";
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
                for (r = 0; r < rois.length; r++){
            
                    // Open the ROI
                    openROI(cameraID,phantoms[p],rois[r]);

                    // Get counts in VOI for each iteration image
                    selectWindow(itt[i]);
                    voiCounts = countsROImanager();
                    geometry = newArray(2);
                    geometry = getVolumeArea();
                    
                    // Close VOI
                    roiManager("reset")

                    // Save results to table
                    selectWindow("VOI");
                    Table.set("Camera", jj, cameraID);
                    Table.set("Energy", jj, windowName);
                    Table.set("Phantom", jj, phantoms[p]);
                    Table.set("Correction", jj, corrections[c]);
                    Table.set("Iterations", jj, itt[i]);
                    Table.set("VOI", jj, rois[r]);
                    Table.set("VOI Counts", jj, voiCounts);
                    Table.set("VOI Volume (mm^3)",jj, d2s(geometry[0],2));
                    Table.set("VOI Surface Area (mm^2)",jj, d2s(geometry[1],2));
                    jj++;

                    print(phantoms[p] + ":" + corrections[c] + ":" + itt[i] + ":" + rois[r]);

                }

                // Close Image
                close(itt[i]);
    
            }
        }                           
    }
    
    // Save Tables
    selectWindow("VOI");
    Table.update;
    Table.save(cameraID + "_" + windowName + "_VOIstats.csv"); 
    selectWindow("Whole Image");
    Table.update;
    Table.save(cameraID + "_" + windowName + "_WholeImagestats.csv"); 

}