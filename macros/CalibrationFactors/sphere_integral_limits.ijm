// ***********************************************************************
// * Partial Volume - whole VOI
// * Get the limitis of integration of each voxel in the VOI
// *
// * APR: 04/03/15
// ***********************************************************************

//---------------------------------------------------------------------------
// Global Variables:
var	DataSetID;
var	NMfile;
var     NMfileSC;
var     NMfileNC;
var	NMfile1;
var     NMfileSC1;
var     NMfileNC1;
var	NMfile2;
var     NMfileSC2;
var     NMfileNC2;
var	CTfile;
var	nCT = 90;
var	ROIfile;
var	errorROIfile512;
var	errorROIfile128;
//---------------------------------------------------------------------------

macro "alpha" {

    // Open the image
    run("NucMed Open", "open=/home/apr/Dropbox/SPECT/Analysis/3D_Mird/alpha_calcualtions/1577_mm_sphere.h33");
    rename("CT");

    // Make sure we have picked the correct image
    selectWindow("CT");
    
    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    getDimensions(width, height, channels, slices, frames);

    print ("VOXEL:");
    print(vWidth + " " + vHeight + " " + vDepth + " " + unit);

    // Need to hard code the vDepth
    vDepth = -4.4181;
    
    // Loop through all the voxels
    tc = 0;
    nVoxels = 0;
    print("Start loop through stack");
    for(s=1; s <= nSlices(); s++){
        setSlice(s);
        for(x=0; x<width; x++){ 
            for(y=0; y<height; y++){ 
                pval=getPixel(x,y);

		if (pval !=1) print(pval);
		
    		// Process the voxel
                if(pval > 1){
		    nVoxels = nVoxels + 1;
    		    // Search Y
    		    yone = -99;
    		    ytwo = -99;
    		    for (iy=y-1; iy >= 0; iy--){
    			pval=getPixel(x,iy);
    			if (pval == 3){
    			    yone = iy;
    			    print("y1 = " + yone);
    			}
    		    }
    		    for (iy=y+1; iy < height; iy++){
    			pval=getPixel(x,iy);
    			if (pval == 3){
    			    ytwo = iy;
    			    print("y2 = " + ytwo);
    			}
    		    }

    		    // Search X
    		    xone = -99;
    		    xtwo = -99;
    		    for (ix=x-1; ix >= 0; ix--){
    			pval=getPixel(ix,y);
    			if (pval == 3){
    			    xone = ix;
    			    print("x1 = " + xone);
    			}
    		    }
    		    for (ix=x+1; ix < width; ix++){
    			pval=getPixel(ix,y);
    			if (pval == 3){
    			    xtwo = ix;
    			    print("x2 = " + xtwo);
    			}
    		    }

    		    // Search Z (slices)
    		    zone = -99;
    		    ztwo = -99;
    		    for (iz=s-1; iz >= 1; iz--){
    			setSlice(iz);
    			pval=getPixel(x,y);
    			if (pval == 3){
    			    zone = iz;
    			    print("z1 = " + zone);
    			}
    		    }
    		    for (iz=s+1; iz <= slices; iz++){
    			setSlice(iz);
    			pval=getPixel(x,y);
    			if (pval == 3){
    			    ztwo = iz;
    			    print("z2 = " + ztwo);
    			}
    		    }

    		    // Go back to correct slice
    		    setSlice(s);
		    
    		    print(pval);
    		    print(x+","+y+","+s+" in VOI");
    		    print("yone = " + yone + " ytwo = " + ytwo);
    		    print("xone = " + xone + " xtwo = " + xtwo);
    		    print("zone = " + zone + " ztwo = " + ztwo);

    		    // Calculate the integral limits
    		    if(yone ==-99){
    			yone = y;
    		    }
    		    if(ytwo ==-99){
    			ytwo = y;
    		    }
    		    ylower = -1.0 * ((y - yone)*vHeight + vHeight/2.0);
    		    yupper = (ytwo - y)*vHeight + vHeight/2.0;		    

    		    if(xone ==-99){
    			xone = x;
    		    }
    		    if(xtwo ==-99){
    			xtwo = x;
    		    }
    		    xlower = -1.0 * ((x - xone)*vWidth + vWidth/2.0);
    		    xupper = (xtwo - x)*vWidth + vWidth/2.0;

    		    if(zone ==-99){
    			zone = s;
    		    }
    		    if(ztwo ==-99){
    			ztwo = s;
    		    }
    		    zlower = ((s - zone)*vDepth + vDepth/2.0);
    		    zupper = -1.0 *  (ztwo - s)*vDepth + vDepth/2.0;

    		    print("[[" + x +","+y+","+s+"] x1 = " + xlower + " x2 = " + xupper + " y1 = " + ylower + " y2 = " + yupper + " z1 = " + zlower + " z2 = " + zupper +"]");
	    
    		    tc++;
                }
    		else{

    		}
            }
        }
    }

    print("nVoxels = " + nVoxels + " tc = " + tc);
    
    // Save the output
    selectWindow("Log");
    save("sphere_1600_integral_limits.txt");

}
