// SPDX-License-Identifier: GPL-3.0-or-later
/* 
Define a cylindrical ROI based on the centre of the phantom using CT
*/

macro "voi" {

    
    args = newArray(3);
    args[0] = "DR";
    args[1] = "Sphere1";
    args[2] = "_CT";
    
    run_me(args);

}

function run_me(args){

    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Make a random image for testing
    //newImage("Test", "16-bit noise", 512, 512, 321);

    newImage("Test", "16-bit noise", 128, 128, 120);

    // // Make a rectangle
    // makeRectangle(0, 0, 3, 3);
    // run("Measure");

    // makeRectangle(0, 0, 1, 1);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 1, 1);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0, 0, 2, 2);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 2, 2);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0, 0, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0, 0, 4, 4);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 4, 4);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0, 0, 5, 5);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 5, 5);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0, 0, 6, 6);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 6.1, 6.0);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0, 0, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0.00001, 0.00001, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0.999999, 0.999999, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeRectangle(0.00001, 0.00001, 3.00001, 3.00001);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");


    // // Make Oval
    // makeOval(0, 0, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(0, 0, 3.0000001, 3.00000001);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(1, 1, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // makeOval(1.5, 1.5, 3, 3);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");


    // makeOval(1.5, 1.5, 3.000001, 3.000001);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");

    // // Make Oval
    // makeOval(0, 0, 3.1, 3.1);
    // run("Measure");
    
    // // Make Oval
    // makeOval(0, 0, 3.5, 3.5);
    // run("Measure");

    // // Make Oval
    // makeOval(0, 0, 3.7, 3.7);
    // run("Measure");

    // // Make Oval
    // makeOval(0, 0, 4.0, 4.0);
    // run("Measure");
    // Roi.getContainedPoints(xpoints, ypoints);
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");
    

    // // Make a rectangle
    // makeRectangle(0, 0, 2, 2);
    // Roi.getContainedPoints(xpoints, ypoints)
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // print (" ");
    // run("Measure");

    // makeRectangle(2, 2, 2, 2);
    // Roi.getContainedPoints(xpoints, ypoints)
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // run("Measure");

    // print (" ");

    // makeRectangle(1.9, 1.9, 2, 2);
    // Roi.getContainedPoints(xpoints, ypoints)
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // run("Measure");
    // print (" ");
    
    // makeRectangle(2.1, 2.1, 2, 2);
    // Roi.getContainedPoints(xpoints, ypoints)
    // for(i = 0; i < xpoints.length; i++){
    //     print("["+i+"] "+ xpoints[i] + ", " + ypoints[i]);
    // }
    // run("Measure");


    // Open the CT image
    // cameraID = "DR";
    // phantomID = "Cylinder";
    openCTData(cameraID, phantomID); 
    roiManager("Open", "/var/home/apr/Science/GE-RSCH/QI/analysis/rois/centres/DR_Sphere1_CT_Centres_RoiSet.zip");
    roiManager("select", 0);

    // Get the position
    getSelectionCoordinates(x, y);
    print(x[0] + " , " +y[0]);


    // // Find the centre in Z
    // selectWindow("CT");
    // centreCT = newArray(3);
    // centreCT[2] = centreSliceCT();

    // // Find centre in x and y
    // setSlice(centreCT[2]);

    // getDimensions(width, height, channels, slices, frames);
    // makeRectangle(0, 0, width, height);
    // ct_x = getProfile();

    // selectWindow("CT");
    // setKeyDown("alt"); ct_y = getProfile();

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
    // // roiManager("Save", roiDirectory + cameraID + "_" + phantomID + roiID + "_RoiSet_XYZ.zip");


}