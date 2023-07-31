// SPDX-License-Identifier: GPL-3.0-or-later
// ***********************************************************************
// * Display an ROI in 3D
// *
// * APR: 04/03/15
// ***********************************************************************

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

macro "showROIs" {

    // Prompt for dataset to use
    selectDataSet();

    // Open dataset
    openDataSet(NMfile, CTfile, nCT, ROIfile);

    // Select CT
    selectWindow("CT");
    run("Fire");

    // Clear the data outside the ROI
    clearoutsideROImanager();

    // Create 3D Projection
    run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice=4.42 initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=100 interior=50 interpolate");

    // Save as an avi file
    run("AVI... ", "compression=JPEG frame=7 save=[/home/apr/Dropbox/SPECT/Analysis/3D_Mird/recovery_factors/" + DataSetID + "_ROI_visual.avi]");

}
