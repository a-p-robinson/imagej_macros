// ***********************************************************************
// * Common libary of ImageJ macro functions
// * 
// * Functions can be appended to the end of macro file before running
// * using runM.sh
// 
// * Revised APR: 01/08/22
// ***********************************************************************

// Return the centre slice of a CT image based on the profile
function centreSliceCT(){

    // Get slice thickness 
    getVoxelSize(width, height, depth, unit);
    
    run("Reslice [/]...", "output="+depth+" start=Top");
    selectWindow("Reslice of CT");
    setSlice(nSlices()/2);
    getDimensions(width, height, channels, slices, frames);
    makeRectangle(0, 0, width, height);
    setKeyDown("alt"); ct_z = getProfile();
    //run("Plot Profile");

    ct_z_max = Array.findMaxima(ct_z,0.00001);
    ct_z_min = Array.findMinima(ct_z,0.00001);
    ct_z_half = (ct_z[ct_z_max[0]]+ct_z[ct_z_min[0]])/2;
    
    centre_z = centreProfile(ct_z, ct_z_half);
    close();
    
    return centre_z;
}

// Return the centre of a profile based on values passing threshold twice
function centreProfile(profile, threshold){

    for (i = 0; i < profile.length / 2; i++){
        if (profile[i] < threshold){
            lower = i;
        }
        if (profile[profile.length-i-1] < threshold){
            upper = profile.length-i-1;
        }
    }
    centre = (upper + lower) / 2;

    return centre;
}