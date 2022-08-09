/* 
Show the sphere ROIS
*/
macro "showSphere" {

    // Get the data names from arguments
    args = split(getArgument(), " ");

    if (args.length != 2){
        print("ERROr: must specify 2 arguments (camera phantom");
        Array.print(args);
        exit();
    }

    cameraID = args[0];
    phantomID = args[1];

    // Open the CT image
    openCTData(cameraID, phantomID); 

    // Open the NM image
    openNMData(cameraID, phantomID);

    // Open the ROIs
    openROI(cameraID, phantomID, "_CT_Sphere_6_NM");

}