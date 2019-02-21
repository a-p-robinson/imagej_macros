// ***********************************************************************
// * Load in the NM data and return total counts
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
var     win;
//---------------------------------------------------------------------------

macro "SPECT-testing" {

    // Open NC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP-3.03_nofilter_32_4/NC.dcm");
    rename("NC");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP-3.03_nofilter_32_4/AC.dcm");
    rename("AC");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP-3.03_nofilter_32_4/AC+SC.dcm");
    rename("ACSC");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP-3.03_nofilter_32_4_nodecay/NC.dcm");
    rename("NC_nod");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP-3.03_nofilter_32_4_nodecay/AC.dcm");
    rename("AC_nod");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP-3.03_nofilter_32_4_nodecay/AC+SC.dcm");
    rename("ACSC_nod");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Background/Recon_XP-3.03_NoF_32_4/NC.dcm");
    rename("NC_BG");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Background/Recon_XP-3.03_NoF_32_4/AC.dcm");
    rename("AC_BG");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Background/Recon_XP-3.03_NoF_32_4/AC+SC.dcm");
    rename("ACSC_BG");

    
    // Get total counst in each image
    selectWindow("NC");
    nc = totalCounts();

    selectWindow("AC");
    ac = totalCounts();

    selectWindow("ACSC");
    sc = totalCounts();

    selectWindow("NC_nod");
    nc_nod = totalCounts();

    selectWindow("AC_nod");
    ac_nod = totalCounts();

    selectWindow("ACSC_nod");
    sc_nod = totalCounts();

    selectWindow("NC_BG");
    nc_bg = totalCounts();

    selectWindow("AC_BG");
    ac_bg = totalCounts();

    selectWindow("ACSC_BG");
    sc_bg = totalCounts();

    
    print("Counts [NC No Filter 32x4]: " + nc);
    print("Counts [AC No Filter 32x4]: " + ac);
    print("Counts [SC No Filter 32x4]: " + sc);
    print ("---");
    print("Counts [NC No Filter 32x4 No Decay]: " + nc_nod);
    print("Counts [AC No Filter 32x4 No Decay]: " + ac_nod);
    print("Counts [SC No Filter 32x4 No Decay]: " + sc_nod);
    print ("---");
    print("Counts [NC No Filter 32x4 UNIFORM BG]: " + nc_bg);
    print("Counts [AC No Filter 32x4 UNIFORM BG]: " + ac_bg);
    print("Counts [SC No Filter 32x4 UNIFORM BG]: " + sc_bg);
    

    selectWindow("Log");
    save("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/SPECT-Test_output-XP_3.03.txt");
    
}
