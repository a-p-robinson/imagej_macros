// SPDX-License-Identifier: GPL-3.0-or-later
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

    // Prompt for dataset to use
    selectDataSet();

    // Define the rescale factor we want to use
    factor = 0.25;

    // Open the data set
    openDataSet3(NMfile, NMfileSC, NMfileNC, CTfile, nCT, ROIfile);
    print("***[Data Set = " + DataSetID + "]***\n");

    // Calculate the alignment of CT and NM
    delta = calcNMCTalignment(NMfile, CTfile);

    // Translate the ROIs from CT to NM in X and Y
    selectWindow("CT");
    translateROImanagerdXdY(delta[0], delta[1]);

    // Scale the ROIS to NM on CT (most accrate)
    selectWindow("CT");
    scaleROImanager(factor);

    // Translate the ROIs from CT to NM in Z
    selectWindow("NM");
    translateROImanagerdZ(-1*delta[2]);

    // Clear the region ouside the ROIs
    clearoutsideROImanager();
    setvalueROImanager(1);

    // Make sure we have picked the correct image
    selectWindow("NM");
    
    // Get the original image properties
    getVoxelSize(vWidth, vHeight, vDepth, unit);
    getDimensions(width, height, channels, slices, frames);

    print ("VOXEL:");
    print(vWidth + " " + vHeight + " " + vDepth + " " + unit);
    
    // Now measure the total counts in the whole image = number of voxels
    nVoxels = countsROImanager();

    // Loop through all the voxels
    tc = 0;
    print("Start loop through stack");
    for(s=1; s <= nSlices(); s++){
        setSlice(s);
        for(x=0; x<width; x++){ 
            for(y=0; y<height; y++){ 
                pval=getPixel(x,y);

    		// Process the voxel
                if(pval > 32768){

    		    // Search Y
    		    yone = -99;
    		    ytwo = -99;
    		    for (iy=y-1; iy >= 0; iy--){
    			pval=getPixel(x,iy);
    			if (pval == 32769){
    			    yone = iy;
    			    print("y1 = " + yone);
    			}
    		    }
    		    for (iy=y+1; iy < height; iy++){
    			pval=getPixel(x,iy);
    			if (pval == 32769){
    			    ytwo = iy;
    			    print("y2 = " + ytwo);
    			}
    		    }

    		    // Search X
    		    xone = -99;
    		    xtwo = -99;
    		    for (ix=x-1; ix >= 0; ix--){
    			pval=getPixel(ix,y);
    			if (pval == 32769){
    			    xone = ix;
    			    print("x1 = " + xone);
    			}
    		    }
    		    for (ix=x+1; ix < width; ix++){
    			pval=getPixel(ix,y);
    			if (pval == 32769){
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
    			if (pval == 32769){
    			    zone = iz;
    			    print("z1 = " + zone);
    			}
    		    }
    		    for (iz=s+1; iz <= slices; iz++){
    			setSlice(iz);
    			pval=getPixel(x,y);
    			if (pval == 32769){
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
    save(DataSetID + "_integral_limits.txt");

}
