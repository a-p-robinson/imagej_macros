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

}