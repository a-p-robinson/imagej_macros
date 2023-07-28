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
    windowName = "EM1";

    // Itterations
    //itt = newArray(1,2,3,4,5,10,20,30,40,50,60,80,100,2); // Extra element on end for 10 SS
    //itt = newArray(1,2,3,4,5,10,20,30,40,50,60,80,100);
    itt = newArray(1,2,3,4,5,10,20,30,40,50);
    counts = newArray(itt.length);
    unc = newArray(itt.length);
    
    // Loop through NC,AC and ACSC
    corrections = newArray("NC","AC","ACSC");

    for(c = 0; c < corrections.length; c++){

    }

    // Open files
    for (i = 0; i < itt.length; i++){

        // if(i == itt.length-1){

        //     fileName = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/DR/Cylinder/" + windowName + "/SS10_IT1" + "/SPECTCT_"+windowName+"_IRAC001_DS.dcm";
        //     open(fileName);
        //     rename(itt.length-i);            
        // }else{
            fileName = "/home/apr/Science/GE-RSCH/QI/data/Reconstruction/QI_01_09_22/"+cameraID+"/"+phantomID+"/" + windowName + "/SS5_IT" + itt[i] + "/SPECTCT_"+windowName+"_IRAC001_DS.dcm";
            open(fileName);
            run("Fire");
            rename(itt[i]);
        // }

    }
    
    // Loop through files
    for (i = 0; i < itt.length; i++){
        selectWindow(itt[i]);
        counts[i] = sumStack();
        unc[i] = sqrt(counts[i]);
        print("Total : " + itt[i] + " : " + counts[i] + " : " + unc[i]);
    }

    // Plot the data
    Plot.create("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [Total]", "Itterations", "Total Counts");

    Plot.setLineWidth(2);
    Plot.setColor("red");
    Plot.add("circle",itt,counts)

    Plot.setLineWidth(1);
    Plot.setColor("black");
    Plot.add("line",itt,counts)

    Plot.add("error bars", unc);
    
    Plot.setFontSize(14);
    Plot.show();
    Plot.showValuesWithLabels();
    Plot.setLimitsToFit();

    // Now with VOI
    openROI(cameraID,phantomID,roiID);
    // openROI(cameraID,"Cylinder","_CT_NM");
    
    // Loop through files
    for (i = 0; i < itt.length; i++){
        selectWindow(itt[i]);
        counts[i] = countsROImanager();
        unc[i] = sqrt(counts[i]);
        print("VOI   : " + itt[i] + " : " + counts[i] + " : " + unc[i]);
    }

    // Plot the data
    Plot.create("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [VOI]", "Itterations", "VOI Counts");
    
    Plot.setLineWidth(2);
    Plot.setColor("red");
    Plot.add("circle",itt,counts)

    Plot.setLineWidth(1);
    Plot.setColor("black");
    Plot.add("line",itt,counts)

    Plot.add("error bars", unc);

    Plot.setFontSize(14);
    Plot.show();
    Plot.showValuesWithLabels();
    Plot.setLimitsToFit();

    // Save Plots
    selectWindow("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [VOI]");
    saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+roiID+"-VOI");
    // saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+"CylinderVOI"+"-VOI");
 
    // Save Plots
    selectWindow("Conv: " +cameraID+ " - " + phantomID + " " + windowName + " [Total]");
    saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+roiID+"-Total");
    // saveAs("PNG", "Convergence-"+ cameraID+"_"+phantomID+"CylinderVOI"+"-Total");


}