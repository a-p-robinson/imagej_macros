/* Define a cylindrical ROI based on the centre of the phantom

 */
macro "cylinderROI" {


    // Open the CT image
    CTfile = "/home/apr/Science/GE-RSCH/QI/data/DicomData/DR/Cylinder/CT/CTSoftTissue1.25mmSPECTCT_H_1001_CT001.dcm";
    CTslices = 321;
    run("Image Sequence...", "open=" + CTfile + " number=" + CTslices + " starting=1 increment=1 scale=100 file=[] sort");

    // Find the centre in Z
    selectWindow("CT");
    centreCT = newArray(3);
    centreCT[2] = centreSliceCT();

    // Find centre in x and y
    setSlice(centreCT[2]);
    threshold = -50;

    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    ct_x = getProfile();
    setKeyDown("alt"); ct_y = getProfile();

    centreCT[0] = centreProfile(ct_x, threshold);
    centreCT[1] = centreProfile(ct_y, threshold);

    Array.print(centreCT);

    makePoint(centreCT[0], centreCT[1], "small yellow hybrid");
    makePoint(256, 256, "small green hybrid");

    // setKeyDown("alt"); ct_z = getProfile();
    // run("Plot Profile");

    // ct_z_max = Array.findMaxima(ct_z,0.00001);
    // ct_z_min = Array.findMinima(ct_z,0.00001);
    // ct_z_half = (ct_z[ct_z_max[0]]+ct_z[ct_z_min[0]])/2;

    // print(ct_z[ct_z_max[0]]);
    // print(ct_z[ct_z_min[0]]);
    // print((ct_z[ct_z_max[0]]+ct_z[ct_z_min[0]])/2);
    
    // for (i = 0; i < ct_x.length / 2; i++){
    //     if (ct_x[i] < threshold){
    //         lower = i;
    //     }
    //     if (ct_x[ct_x.length-i-1] < threshold){
    //         upper = ct_x.length-i-1;
    //     }
    // }

    // centre_z = (upper + lower)/ 2;

    // print(lower);
    // print(upper);
    // print(centre_z);




}