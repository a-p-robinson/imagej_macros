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

    // Open Tomo
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Background/Tomo/EM.dcm");
    rename("EM");

    // Open NC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Background/Recon_XP_NoF_32_4/AC.dcm");
    rename("AC_DC");

    // Open AC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Background/Recon_XP_NoF_NOD_32_4/AC.dcm");
    rename("AC_NOD");

    // Open Tomo
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/Microsphere_Position1/Tomo/00000001.dcm");
    rename("EM2");

    // Open NC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_nodecay_32_4/NC.dcm");
    rename("NC2");

    // Open AC Image - Adaptive
    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_nodecay_32_4/AC.dcm");
    rename("AC2");

    open("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DATA/NEMA_6Spheres/Recon_XP_nofilter_nodecay_32_4/ACSC.dcm");
    rename("ACSC2");

    // Get total counst in each image
    selectWindow("EM");
    em = totalCounts();

    selectWindow("AC_DC");
    ac_dc = totalCounts();

    selectWindow("AC_NOD");
    ac_nod = totalCounts();

    selectWindow("EM2");
    em2 = totalCounts();

    selectWindow("NC2");
    nc2 = totalCounts();
    
    selectWindow("AC2");
    ac2 = totalCounts();

    selectWindow("ACSC2");
    sc2 = totalCounts();

    print("Microsphere BG");
    print("Counts [Projection]: " + em);
    print("Counts [AC    Decay Corr. 32x4]: " + ac_dc);
    print("Counts [AC No Decay Corr. 32x4]: " + ac_nod);
    print("---");
    print("NEMA");
    print("Counts [Projection]: " + em2);
    print("Counts [NC 32x4]: " + nc2);
    print("Counts [AC 32x4]: " + ac2);
    print("Counts [SC 32x4]: " + sc2);
    
    selectWindow("Log");
    save("/mnt/tdrive/DATA/SPECT/AR12/SPECT-Tests/DecayCorr-Test_output.txt");
    
}
