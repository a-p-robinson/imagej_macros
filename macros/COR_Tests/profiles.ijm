// ***********************************************************************
// * Simple profiles
// *
// ***********************************************************************



macro "profiles" {

    // Open NC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Tomo/00000001.dcm");
    rename("Test");

    selectWindow("Test");
    makeRectangle(0, 0, 128, 128);

    setSlice(1);
    xProfile = getProfile();

    setKeyDown("alt");
    yProfile = getProfile();
    
    // Open output file
    f = File.open("/home/apr/xProfile.txt");
    // Write data to output
    for (i=0; i < xProfile.length; i++){
    	print(f, i + " " + xProfile[i] + "\n");
    }

    // Close the output file
    File.close(f);

    // Open output file
    f = File.open("/home/apr/yProfile.txt");
    // Write data to output
    for (i=0; i < yProfile.length; i++){
    	print(f, i + " " + yProfile[i] + "\n");
    }

    // Close the output file
    File.close(f);

}
