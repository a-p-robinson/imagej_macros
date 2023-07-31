// SPDX-License-Identifier: GPL-3.0-or-later
// ***********************************************************************
// * Display 177Lu dual energy window data
// *
// * APR: 04/08/15
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
//---------------------------------------------------------------------------

macro "showROIs" {

    // Prompt for dataset to use
    selectDataSet();

    // Open the data set
    openDataSet6(NMfile1, NMfileSC1, NMfileNC1, NMfile2, NMfileSC2, NMfileNC2, CTfile, nCT);

}
