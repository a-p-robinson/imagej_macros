/* 
Get the statistics from the VOI for all files in a directory
*/
macro "getVOIstatsDir" {

    // Get the data names from arguments
    args = parseArguments();    
    cameraID = args[0];
    phantomID = args[1];
    roiID = args[2];

    // Open the ROIs
    openROI(cameraID, phantomID, roiID);
    
    // Make a Table for output
    table_name = "NM Measurements";
    Table.create(table_name);

    // Loop through all images in a directory
    //
    // Set the path to open
    if (cameraID == "CZT-WEHR" || cameraID == "CZT-MEHRS"){
        tmp = split(cameraID,"-");
        inputDir = "/home/apr/Science/GE-RSCH/QI/data/DicomData/" + tmp[0] + "/" + tmp[1] + "/" + phantomID +"/Recon/";    
    }
    else{
        inputDir = "/home/apr/Science/GE-RSCH/QI/data/DicomData/" + cameraID + "/" + phantomID +"/Recon/";
    }

    // Get list of files in directory
    fileList = getFileList(inputDir);
    for (i = 0; i < fileList.length; i++){
        
        // Process the image
        print(i + " : " + fileList[i]);

        open(inputDir+fileList[i]);
        rename("NM");
        run("Fire");

        // Get the VOI stats
        //
        // Total counts in image
        selectWindow("NM");
        totalCounts = sumStack();
        print(" Sum stack counts : " + totalCounts);
        
        // Get total counts in VOI
        selectWindow("NM");
        voiCounts = countsROImanager();
        print(" VOI Counts : " + voiCounts);

        // Measure volume and surface area
        geometry = newArray(2);
        geometry = getVolumeArea();
        print(" VOI volume : " + geometry[0] + " mm^3");
        print(" VOI surface area : " + geometry[1] + " mm^2");

        // Save results to table
        selectWindow(table_name);
        Table.set("Camera", i, cameraID);
        Table.set("Phantom", i, phantomID);
        Table.set("VOI", i, roiID);
        Table.set("File", i, fileList[i]);
        Table.set("Total Counts", i, totalCounts);
        Table.set("VOI Counts", i, voiCounts);
        Table.set("VOI Volume (mm^3)",i, d2s(geometry[0],2));
        Table.set("VOI Surface Area (mm^2)",i, d2s(geometry[1],2));

        selectWindow("NM");
        close();

    }

    // Update table and save
    Table.update;
    Table.save(cameraID + "_" + phantomID + "_" + roiID + "VOIstats.csv"); 
    
}