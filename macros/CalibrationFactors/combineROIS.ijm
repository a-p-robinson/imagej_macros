// SPDX-License-Identifier: GPL-3.0-or-later
//---------------------------------------------------------------------------
// Global Variables:
var	DataSetID;
var	NMfile;
var     NMfileSC;
var     NMfileNC;
var	CTfile;
var	nCT = 90;
var	ROIfile;
//---------------------------------------------------------------------------

macro "combineROIS" {

    //Open Liver large dataset
    DataSetID = "LiverLarge";
    NMfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/Recon/IRACOSEM001_DS.dcm";
    CTfile = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/2015/Data/99mTc/ABS/Liver/CT/CTTomoHwkLiver001_CT001.dcm";
    nCT = 90;
    ROIfile1 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/Liver_Large_ROI_apr_v1.zip";

    // Open dataset
    openDataSet(NMfile, CTfile, nCT, ROIfile1);

    // Get current number of ROIS
    count1 = roiManager("count"); 
    print("ROIS set 1 = " + count1);

    // Get First slice of ROIS1
    roiManager("select",0);
    firstSliceSet1 = getSliceNumber();

    // Get last slice of ROIS1
    roiManager("select",count1-1);
    lastSliceSet1 = getSliceNumber();
    print(firstSliceSet1 + " " + lastSliceSet1);

    // Open the second ROI dataset
    ROIfile2 = "/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/ROIS/MPHYS/RoiSet_Liver_small8.zip";
    roiManager("Open", ROIfile2);

    // See how many ROIs we have now
    totalCount = roiManager("count");
    print("ROI2 has " + totalCount);

    // Get First slice of ROIS2
    roiManager("select",count1);
    firstSliceSet2 = getSliceNumber();

    // Get last slice of ROIS1
    roiManager("select",totalCount-1);
    lastSliceSet2 = getSliceNumber();
    print(firstSliceSet2 + " " + lastSliceSet2);

    // Calcualte total in set2
    count2 = totalCount - count1;

    // Loop through first ROI set
    // if the matching rois
    // combine them and make new
    // else make new
    limits = newArray(2);
    for (i = 0; i < count1; i++){
	roiManager("select", i); 
	slice = getSliceNumber();

	// Over lapping Rois
	if(slice >= firstSliceSet2 && slice <= lastSliceSet2){
	    // Combine and copy
	    //roiManager("Select", newArray(slice, slice + count2));
	    limits[0] = i;
	    limits[1] = i+count2;
	    Array.print(limits);
	    roiManager("Select", limits);
	    roiManager("Combine");
	    roiManager("Add");
	}
	else{
	    // Copy it
	    roiManager("Add");
	}
    }

    // Remove the previous ROIs
    for (i = 0; i < totalCount; i++){
	print("Deleting " + i);
	roiManager("select", 0);
    	roiManager("Delete");
    }

}










