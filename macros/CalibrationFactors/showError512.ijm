// SPDX-License-Identifier: GPL-3.0-or-later
// ***********************************************************************
// * Display a CT image and associated ROIs
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

macro "showError512" {

    // Prompt for dataset to use
    selectDataSet();

    // Open the data set
    openDataSet(NMfile, CTfile, nCT, errorROIfile512);

}
