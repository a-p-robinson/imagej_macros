/* 
Testing convergence
*/
macro "convergence_test" {

    // Get the camera and phantom and ROI
    args = parseArguments();
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Secifiy Window Name
    windowName = "EM2";

    // Itterations
    //itt = newArray(1,2,3,4,5,10,20,30,40,50,60,80,100,2); // Extra element on end for 10 SS
    //itt = newArray(1,2,3,4,5,10,20,30,40,50,60,80,100);
    itt = newArray(1,2,3,4,5,10,20,30,40,50);
    counts = newArray(itt.length);
    unc = newArray(itt.length);
    
    // Open the VOI
    openROI(cameraID,phantomID,roiID);

    // Loop through NC,AC and ACSC
    corrections = newArray("NC","AC","ACSC");
    
    countsNCtotal = newArray(itt.length);
    uncNCtotal = newArray(itt.length);
    countsACtotal = newArray(itt.length);
    uncACtotal = newArray(itt.length);
    countsACSCtotal = newArray(itt.length);
    uncACSCtotal = newArray(itt.length);
    
    countsNCvoi = newArray(itt.length);
    uncNCvoi = newArray(itt.length);
    countsACvoi = newArray(itt.length);
    uncACvoi = newArray(itt.length);
    countsACSCvoi = newArray(itt.length);
    uncACSCvoi = newArray(itt.length);
    

    for(c = 0; c < corrections.length; c++){

        // Open the files for this correction
        for (i = 0; i < itt.length; i++){
            fileName = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/"+cameraID+"/"+phantomID+"/" + windowName + "/SS5_IT" + itt[i] + "/SPECTCT_"+windowName+"_IR"+corrections[c]+"001_DS.dcm";
            open(fileName);
            run("Fire");
            rename(itt[i]);
        }

        // Get the numbers and save in array
        for (i = 0; i < itt.length; i++){
            selectWindow(itt[i]);

            if (c == 0){
                countsNCtotal[i] = sumStack();
                uncNCtotal[i] = sqrt(countsNCtotal[i]);
                countsNCvoi[i] = countsROImanager();
                uncNCvoi[i] = sqrt(countsNCvoi[i]);
            }
            if (c == 1){
                countsACtotal[i] = sumStack();
                uncACtotal[i] = sqrt(countsACtotal[i]);
                countsACvoi[i] = countsROImanager();
                uncACvoi[i] = sqrt(countsACvoi[i]);
            }
            if (c ==2){
                countsACSCtotal[i] = sumStack();
                uncACSCtotal[i] = sqrt(countsACSCtotal[i]);
                countsACSCvoi[i] = countsROImanager();
                uncACSCvoi[i] = sqrt(countsACSCvoi[i]);
            }


            // Get VOI counts

            // Close this image
            close();

        }        

    }
    

    Array.print(countsNCtotal);
    Array.print(countsACtotal);
    Array.print(countsACSCtotal);
    

    
    // Plot the data
    Plot.create("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [Total]", "Itterations", "Total Counts");
    Plot.setFontSize(14);
    
    Plot.setLineWidth(2);
    Plot.setColor("black");
    // Plot.add("circle",itt,countsNCtotal);
    // Plot.add("error bars", uncNCtotal);
    // Plot.setColor("red");
    // Plot.add("circle",itt,countsACtotal);
    // Plot.add("error bars", uncACtotal);
    // Plot.setColor("blue");
    Plot.add("circle",itt,countsACSCtotal);
    Plot.add("error bars", uncACSCtotal);

    Plot.setLegend("NC (total)\tAC (total)\tACSC (total)","top-right");
    Plot.show();
    Plot.setLimitsToFit();


    // Plot the data
    Plot.create("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [VOI]", "Itterations", "VOI Counts");
    Plot.setFontSize(14);
    
    Plot.setLineWidth(2);
    Plot.setColor("black");
    // Plot.add("circle",itt,countsNCvoi);
    // Plot.add("error bars", uncNCvoi);
    // Plot.setColor("red");
    // Plot.add("circle",itt,countsACvoi);
    // Plot.add("error bars", uncACvoi);
    // Plot.setColor("blue");
    Plot.add("circle",itt,countsACSCvoi);
    Plot.add("error bars", uncACSCvoi);

    Plot.setLegend("NC (voi)\tAC (voi)\tACSC (voi)","top-right");
    Plot.show();
    Plot.setLimitsToFit();


    
    // Plot.setLineWidth(1);
    // Plot.setColor("black");
    // Plot.add("line",itt,counts)

    // 
    
    // Plot.show();
    // Plot.showValuesWithLabels();
    
    // // Now with VOI
    // openROI(cameraID,phantomID,roiID);
    // // openROI(cameraID,"Cylinder","_CT_NM");
    
    // // Loop through files
    // for (i = 0; i < itt.length; i++){
    //     selectWindow(itt[i]);
    //     counts[i] = countsROImanager();
    //     unc[i] = sqrt(counts[i]);
    //     print("VOI   : " + itt[i] + " : " + counts[i] + " : " + unc[i]);
    // }

    // // Plot the data
    // Plot.create("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [VOI]", "Itterations", "VOI Counts");
    
    // Plot.setLineWidth(2);
    // Plot.setColor("red");
    // Plot.add("circle",itt,counts)

    // Plot.setLineWidth(1);
    // Plot.setColor("black");
    // Plot.add("line",itt,counts)

    // Plot.add("error bars", unc);

    // Plot.setFontSize(14);
    // Plot.show();
    // Plot.showValuesWithLabels();
    // Plot.setLimitsToFit();

    // // Save Plots
    // selectWindow("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [VOI]");
    // saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+roiID+"-VOI");
    // // saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+"CylinderVOI"+"-VOI");
 
    // // Save Plots
    // selectWindow("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [Total]");
    // saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+roiID+"-Total");
    // // saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+"CylinderVOI"+"-Total");


}