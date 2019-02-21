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
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_Adaptive_32_4/NC.dcm");
    rename("NC_adp");

    // Open AC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_Adaptive_32_4/AC.dcm");
    rename("AC_adp");

    // Open ACSC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_Adaptive_32_4/ACSC.dcm");
    rename("SC_adp");

    // Open NC Image - nofilter
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_32_4/NC.dcm");
    rename("NC_nof");

    // Open AC Image - nofilter
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_32_4/AC.dcm");
    rename("AC_nof");

    // Open ACSC Image - nofilter
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_32_4/ACSC.dcm");
    rename("SC_nof");

    // Open NC Image - nofilter 12x4
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_12_4/NC.dcm");
    rename("NC_nof_12_4");

    // Open AC Image - nofilter 12x4
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_12_4/AC.dcm");
    rename("AC_nof_12_4");

    // Open ACSC Image - nofilter 12x4
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_12_4/ACSC.dcm");
    rename("SC_nof_12_4");

    // Open NC Image - nofilter 64x8
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_64_8/NC.dcm");
    rename("NC_nof_64_8");

    // Open AC Image - nofilter 64x8
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_64_8/AC.dcm");
    rename("AC_nof_64_8");

    // Open ACSC Image - nofilter 64x8
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_64_8/ACSC.dcm");
    rename("SC_nof_64_8");

    // Open NC Image - nofilter 20x8 XP3D
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP3D_nofilter_20_8/NC.dcm");
    rename("NC_nof_20_8");

    // Open AC Image - nofilter20x8 XP3D
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP3D_nofilter_20_8/AC.dcm");
    rename("AC_nof_20_8");


    // Open NC Image - nofilter - no decay
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_nodecay_32_4/v2/NC.dcm");
    rename("NC_nof_nod");

    // Open AC Image - nofilter- no decay
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_nodecay_32_4/v2/AC.dcm");
    rename("AC_nof_nod");

    // Open ACSC Image - nofilter- no decay
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_nodecay_32_4/v2/ACSC.dcm");
    rename("SC_nof_nod");

    
    // Get total counst in each image
    selectWindow("NC_adp");
    nc_adp = totalCounts();

    selectWindow("AC_adp");
    ac_adp = totalCounts();

    selectWindow("SC_adp");
    sc_adp = totalCounts();

    selectWindow("NC_nof");
    nc_nof = totalCounts();

    selectWindow("AC_nof");
    ac_nof = totalCounts();

    selectWindow("SC_nof");
    sc_nof = totalCounts();

    selectWindow("NC_nof_12_4");
    nc_nof_12_4 = totalCounts();

    selectWindow("AC_nof_12_4");
    ac_nof_12_4 = totalCounts();

    selectWindow("SC_nof_12_4");
    sc_nof_12_4 = totalCounts();

    selectWindow("NC_nof_64_8");
    nc_nof_64_8 = totalCounts();

    selectWindow("AC_nof_64_8");
    ac_nof_64_8 = totalCounts();

    selectWindow("SC_nof_64_8");
    sc_nof_64_8 = totalCounts();

    selectWindow("NC_nof_20_8");
    nc_nof_20_8 = totalCounts();

    selectWindow("AC_nof_20_8");
    ac_nof_20_8 = totalCounts();

    selectWindow("NC_nof_nod");
    nc_nof_nod = totalCounts();

    selectWindow("AC_nof_nod");
    ac_nof_nod = totalCounts();

    selectWindow("SC_nof_nod");
    sc_nof_nod = totalCounts();
    
    print("Counts [NC Adaptive 32x4]: " + nc_adp);
    print("Counts [AC Adaptive 32x4]: " + ac_adp);
    print("Counts [SC Adaptive 32x4]: " + sc_adp);
    print ("---");
    print("Counts [NC No Filter 32x4]: " + nc_nof);
    print("Counts [AC No Filter 32x4]: " + ac_nof);
    print("Counts [SC No Filter 32x4]: " + sc_nof);
    print ("---");
    print("Counts [NC No Filter 12x4]: " + nc_nof_12_4);
    print("Counts [AC No Filter 12x4]: " + ac_nof_12_4);
    print("Counts [SC No Filter 12x4]: " + sc_nof_12_4);
    print ("---");
    print("Counts [NC No Filter 64x8]: " + nc_nof_64_8);
    print("Counts [AC No Filter 64x8]: " + ac_nof_64_8);
    print("Counts [SC No Filter 64x8]: " + sc_nof_64_8);
    print ("---");
    print("Counts [NC No Filter 20x8 (XP3D)]: " + nc_nof_20_8);
    print("Counts [AC No Filter 20x8 (XP3D)]: " + ac_nof_20_8);
    print ("---");
    print("Counts [NC No Filter No Decay 32x4]: " + nc_nof_nod);
    print("Counts [AC No Filter No Decay 32x4]: " + ac_nof_nod);
    print("Counts [SC No Filter No Decay 32x4]: " + sc_nof_nod);
    selectWindow("Log");
    save("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/SPECT-Test_output.txt");
    
}
