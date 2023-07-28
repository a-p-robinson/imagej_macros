// *************************************************
// * SPECT projection TEW/DEW scatter corrcetion
// * (based on Ogawa et al 1991)
// *
// * Generate TEW for all 177Lu data
// *
// * Requirements:
// *  - Interfile_TP
// *
// * APR: 17/01/14 (v1)
// * Revised: 22/08/19
// *************************************************

//---------------------------------------------------------------------------
// Global Variables:

// User options:
var useFloat = 1;        // Use float or integer arthimetic
var scanName;              // Name to use for interfile (and also report)
var outputPath;            // Path to save Interfile to
var reportFileName;        // Name of file to write report to
var saveIF;                // Should we save to Interfile (interactive mode)
var createReport;          // Should we create a report (interactive mode)
var getWidths;             // Should we use the window widths in the DICOM file (Default) (batch mode only) 

var pathEM;                // Path to EM file
var pathSC1;               // Path to SC1 file
var pathSC2;               // Path to SC2 file

// Energy Window variables:
var w_em;                  // Width of EM1
var w_sc1;                 // Width of SC1
var w_sc2;                  // Width of SC2
var p_em;                  // Peak EM1
var p_sc1;                 // Peak SC1
var p_sc2;                 // Peak SC2
var scaleFac1;             // Scale factor SC1 (from Width and Peak)
var scaleFac2;             // Scale factor SC2 (from Width and Peak)

// Window ID variables (set automatically):
var emID;                  // EM window
var sc1ID;                 // SC1 window
var sc2ID;                 // SC2 window
var sc1ContID;             // Contribution of SC1 to TEW correction
var sc2ContID;             // Contribution of SC1 to TEW correction
var tewID;                 // TEW corrcetion
var em_tewID_f;            // EM - TEW (floating point arithmetic)
var em_tewID_nozero;       // EM - TEW (no non-zero pixels)
var em_tewID_unsigned;     // EM - TEW (integer arithmetic)

// Data format
var useRaw = 0;            // By default we do not use RAW
var rawSize;
var rawNum;
var rawType;
var rawEndian;

// Debug:
var DEBUG = 0;             // 0 = no info / 1 = show measuremnts / 2 = "full" debug statements
//---------------------------------------------------------------------------

macro "TEW_DEW_Scatter_Correction" {



    runTEWInteractive();
    //runTEWBatch("./input_sensitivity_raw_EM1.txt");
    //runTEWBatch("./input_sensitivity_raw_EM2.txt");

}

//---------------------------------------------------------------------------
// Run the parts of the TEW routine in interactive mode
function runTEWInteractive() {

    // Ask for user input...
    loadUserInterface();

    // Load data
    loadTEW();

    // Generate the TEW correction
    generateTEW(emID, sc1ID, sc2ID);

    // Write results to interfile
    if (saveIF == 1) {
        writeTEWinter(scanName, outputPath);
    }

    // Generate the analysis report
    if (createReport == 1) {
        analyseTEW(reportFileName);
    }

    print("FINISHED.");
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Run the parts of the TEW routine in batch mode
function runTEWBatch(inputFile) {

    // Ask for user input...
    //loadUserInterface();

    // Load variables from an input file
    parseInputFile(inputFile);

    // Load data
    loadTEW();

    // Generate the TEW correction
    generateTEW(emID, sc1ID, sc2ID);

    // Write results to interfile
    writeTEWinter(scanName, outputPath);

    // Generate the analysis report
    analyseTEW(reportFileName);

    // CLose all images and windows when done (so we can run again)
    closeAllImages();
    closeAllWindows();

}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Open a user interface for doing TEW correction
function loadUserInterface() {

    // See what the users home directory is for default save location
    userHome = getDirectory("home");

    // Select DICOM files
    pathEM = File.openDialog("TEW Correction: Select EM1 file.");
    pathSC1 = File.openDialog("TEW Correction: Select SC1 file.");
    pathSC2 = File.openDialog("TEW Correction: Select SC2 file.");

    // Get user options from dialog box
    title = "TEW Correction: Options";
    width = 1200; height = 512;
    Dialog.create(title);
    Dialog.addString("EM1:", pathEM, lengthOf(pathEM));
    Dialog.addString("SC1:", pathSC1, lengthOf(pathSC1));
    Dialog.addString("SC2:", pathSC2, lengthOf(pathSC2));

    Dialog.addChoice("Arthimetic:", newArray("Float", "Int"));

    Dialog.addCheckbox("Save to interfile?", true);
    Dialog.addString("Save path", userHome, 30);
    Dialog.addString("File Name", "TEW-Correction", 30);
    Dialog.addCheckbox("Generate Report?", true);
    Dialog.addString("Report Name", "TEW-report", 30);
    Dialog.show();

    pathEM = Dialog.getString();
    pathSC1 = Dialog.getString();
    pathSC2 = Dialog.getString();
    arithmetic = Dialog.getChoice();
    saveIF = Dialog.getCheckbox();
    savePath = Dialog.getString();
    saveFileName = Dialog.getString();
    createReport = Dialog.getCheckbox();
    saveReportName = Dialog.getString();

    // Process user options
    //print(pathEM);
    //print(pathSC1);
    //print(pathSC2);
    //print(arthmetic);
    if (arithmetic == "Int") {
        useFloat = 0;
    }
    if (saveIF == 1) {
        scanName = saveFileName;
        outputPath = savePath;
    }
    if (createReport == 1) {
        reportFileName = saveReportName;
    }
    //print(saveIF);
    //print(savePath);
    //print(saveFileName);
    //print(createReport);
    //print(saveReportName);

    // Get the widths from the DICOM files
    getWidths = 1;

}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Parse the input file for parameters
//  - Takes file with details as parameter
//
// line  1: EM window file
// line  2: SC1 window file
// line  3: SC2 window file
// line  4: Use floats for calculations? (0=no / 1=yes)
// line  5: Output filename
// line  6: Scan Name
// line  7: Path to write output to
// line  8: (opt) Width EM1
// line  9: (opt) Energy EM1
// line 10: (opt) Width SC2
// line 11: (opt) Energy SC2
// line 12: (opt) Width SC2
// line 13: (opt) Energy SC2
function parseInputFile(inputFile) {

    // Open input file and read lines
    str = File.openAsString(inputFile);
    lines = split(str, "\n");
    if (DEBUG > 1) print("InputFile = " + inputFile);
    if (DEBUG > 1) print("Read in " + lines.length + " lines");

    print("** Reading input from: " + inputFile);

    // Set variables
    pathEM = lines[0];
    pathSC1 = lines[1];
    pathSC2 = lines[2];
    useFloat = parseInt(lines[3]);
    reportFileName = lines[4];

    scanName = lines[5];
    outputPath = lines[6];
    getWidths = 1;

    if (lines.length > 7) {
        getWidths = 0;
        w_em = parseFloat(lines[7]);
        p_em = parseFloat(lines[8]);
        w_sc1 = parseFloat(lines[9]);
        p_sc1 = parseFloat(lines[10]);
        w_sc2 = parseFloat(lines[11]);
        p_sc2 = parseFloat(lines[12]);

        print("Will use provided windows:");
        print("  EM  = " + p_em + " w_em  = " + w_em);
        print("  SC1 = " + p_sc1 + " w_sc1 = " + w_sc1);
        print("  SC2 = " + p_sc2 + " w_sc2 = " + w_sc2);

    }

    print("lines = " + lines.length);

    // See if we are using "raw" data files
    if (lines.length > 13) { 
    if (lines[13] == "raw") {
        print("Will open as " + lines[13]);
        useRaw = 1;
        rawSize   = lines[14];
        rawNum    = lines[15];
        rawType   = lines[16];
        rawEndian = lines[17];
    }
}
    
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Read in the data for TEW (EM, SC1, SC2)
function loadTEW() {

    // Check if we are using floats ?
    if (useFloat == 1) {
        print("Using floats for analysis (useFloat = " + useFloat + ")");
    }
    if (useFloat == 0) {
        print("Using integers for analysis (useFloat = " + useFloat + ")");
    }

    // DICOM:
    if (useRaw == 0) {
        //---------------------------------------------------------------------------
        // Load x3 images (EM, SC1, SC2) and get the window widths

        // Load EM and convert to 32bit
        if (DEBUG > 1) print("EM:");
        emID = openImage(pathEM);
        rename("EM");
        if (useFloat == 1) {
            if (DEBUG > 1) print("Changing type to 32-bit");
            run("32-bit");
        }

        // Get window widths
        if (getWidths == 1) {
            emLow = getInfo("0054,0014");
            emHig = getInfo("0054,0015");
            w_em = parseFloat(emHig) - parseFloat(emLow);
            p_em = (parseFloat(emLow) + parseFloat(emHig)) / 2.0;
            if (DEBUG > 1) print("w_em =  " + w_em + " (" + emLow + " - " + emHig + ") keV");
        }
        print("w_em =  " + w_em + " keV");

        // Load SC1 and convert to 32bit
        if (DEBUG > 1) print("SC1:");
        sc1ID = openImage(pathSC1);
        rename("SC1");
        if (useFloat == 1) {
            if (DEBUG > 1) print("Changing type to 32-bit");
            run("32-bit");
        }

        // Get window widths
        if (getWidths == 1) {
            sc1Low = getInfo("0054,0014");
            sc1Hig = getInfo("0054,0015");
            w_sc1 = parseFloat(sc1Hig) - parseFloat(sc1Low);
            p_sc1 = (parseFloat(sc1Low) + parseFloat(sc1Hig)) / 2.0;
            if (DEBUG > 1) print("w_sc1 =  " + w_sc1 + " (" + sc1Low + " - " + sc1Hig + ") keV");
        }
        print("w_sc1 =  " + w_sc1 + " keV");

        // Load SC2 and convert to 32bit
        if (DEBUG > 1) print("SC2:");
        sc2ID = openImage(pathSC2);
        rename("SC2");
        if (useFloat == 1) {
            if (DEBUG > 1) print("Changing type to 32-bit");
            run("32-bit");
        }

        // Get window widths
        if (getWidths == 1) {
            sc2Low = getInfo("0054,0014");
            sc2Hig = getInfo("0054,0015");
            w_sc2 = parseFloat(sc2Hig) - parseFloat(sc2Low);
            p_sc2 = (parseFloat(sc2Low) + parseFloat(sc2Hig)) / 2.0;
            if (DEBUG > 1) print("w_sc2 =  " + w_sc2 + " (" + sc2Low + " - " + sc2Hig + ") keV");
        }
        print("w_sc2 =  " + w_sc2 + " keV");

        print("\n** DICOM files loaded.");
    }
    //---------------------------------------------------------------------------

    // RAW:
    if (useRaw == 1) {
        print("Opening as RAW");

        // EM
        run("Raw...", "open=" + pathEM + " image=[" + rawType + "] width=" + rawSize + " height=" + rawSize + " number=" + rawNum + " " + rawEndian);
        emID = getImageID();
        rename("EM");
        if (useFloat == 1) {
            if (DEBUG > 1) print("Changing type to 32-bit");
            run("32-bit");
        }
        print("w_em =  " + w_em + " keV");

        // SC1
        run("Raw...", "open=" + pathSC1 + " image=[" + rawType + "] width=" + rawSize + " height=" + rawSize + " number=" + rawNum + " " + rawEndian);
        sc1ID = getImageID();
        rename("SC1");
        if (useFloat == 1) {
            if (DEBUG > 1) print("Changing type to 32-bit");
            run("32-bit");
        }
        print("w_sc1 =  " + w_sc1 + " keV");

        // SC2
        run("Raw...", "open=" + pathSC2 + " image=[" + rawType + "] width=" + rawSize + " height=" + rawSize + " number=" + rawNum + " " + rawEndian);
        sc2ID = getImageID();
        rename("SC2");
        if (useFloat == 1) {
            if (DEBUG > 1) print("Changing type to 32-bit");
            run("32-bit");
        }
        print("w_sc2 =  " + w_sc1 + " keV");

        print("\n** RAW files loaded.");

    }


}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Generate the TEW correction
//
// Calculate the TEW correction and generate a report on it
//
// Takes imageIDs for EM, Sc1 and SC2 as arguments
function generateTEW(emID, sc1ID, sc2ID) {

    print("\n** Generating TEW correction and corrected images");

    //---------------------------------------------------------------------------
    // Scale SC1 and SC2 by widths to new image

    // SC1: Duplicate the image and store new ID
    selectImage(sc1ID);
    dup = "title=SC1_contribution duplicate range=1-" + nSlices;
    run("Duplicate...", dup);
    sc1ContID = getImageID();
    if (DEBUG > 1) print("sc1ContID = " + sc1ContID);

    // Calculate scaling factor
    scaleFac1 = w_em / (2 * w_sc1);

    // Scale the new image by scaleFac1
    selectImage(sc1ContID);
    value = "value=" + scaleFac1;
    print("SC1 multiplying by " + value);
    run("Multiply...", value);

    // SC2: Duplicate the image and store new ID
    selectImage(sc2ID);
    dup = "title=SC2_contribution duplicate range=1-" + nSlices;
    run("Duplicate...", dup);
    sc2ContID = getImageID();
    if (DEBUG > 1) print("sc2ContID = " + sc2ContID);

    // Calculate scaling factor
    scaleFac2 = w_em / (2 * w_sc2);

    // Scale the new image by scaleFac2
    selectImage(sc2ContID);
    value = "value=" + scaleFac2;
    print("SC2 multiplying by " + value);
    run("Multiply...", value);
    //---------------------------------------------------------------------------

    //---------------------------------------------------------------------------
    // Sum the SC1 and SC2 contributions
    imageCalculator("Add create 32-bit stack", "SC1_contribution", "SC2_contribution");
    selectWindow("Result of SC1_contribution");
    rename("TEW");
    tewID = getImageID();
    //---------------------------------------------------------------------------

    //---------------------------------------------------------------------------
    // Scatter correct the emission image 
    // We do this in three ways:
    // - create a float version (most accurate)
    // - create a nozero (unsigned version)
    // - create a integer (floor not round) version

    // Scatter correct as float
    imageCalculator("Subtract create 32-bit stack", "EM", "TEW");
    selectWindow("Result of EM");
    rename("EM-TEW_float");
    em_tewID_f = getImageID();

    // Duplicate and set negative values to zero (unsigned)
    selectImage(em_tewID_f);
    dup = "title=EM-TEW_nozero duplicate range=1-" + nSlices;
    run("Duplicate...", dup);
    em_tewID_nozero = getImageID();

    selectImage(em_tewID_nozero);
    getMinAndMax(min, max);
    if (DEBUG > 1) print("min value = " + min + " max value = " + max);
    changeValues(min, 0.0, 0.0);

    // Duplicate the image and floor values (round down)
    selectImage(em_tewID_nozero);
    dup = "title=EM-TEW_unsigned duplicate range=1-" + nSlices;
    run("Duplicate...", dup);
    em_tewID_unsigned = getImageID();

    // Loop through all slices and pixels and round all the pixels (floor)
    selectImage(em_tewID_unsigned);
    getDimensions(width, height, channels, slices, frames);
    if (DEBUG > 1) print("Start loop through stack");
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                pval = getPixel(x, y);
                setPixel(x, y, floor(pval));
            }
        }
    }
    if (DEBUG > 1) print("End loop through stack");
    //---------------------------------------------------------------------------

}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Write the TEW correction and corrcected emission image out to file
// - Takes name of scan and output path as parameters
function writeTEWinter(scanName, outputPath) {

    // Append delimiter to putput path (linux at least
    outputPath = outputPath + "/";

    print("\n** Writing interfiles to " + outputPath + scanName);

    winNameOrig = "TEW";
    winName16 = winNameOrig + "16bit";

    // Close the windows that we don't want
    selectWindow(winNameOrig);

    // Duplicate the image and convert to 16bit
    dup = "title=" + winName16 + " duplicate range=1-" + nSlices;
    run("Duplicate...", dup);
    run("16-bit");

    // Create data arrays for each image
    getDimensions(width, height, channels, slices, frames);
    dataORIG = newArray(width * height * slices);

    // Read data into arrays for comparison
    selectWindow(winNameOrig);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                dataORIG[ind++] = getPixel(x, y);
            }
        }
    }

    // Copy data to new image
    selectWindow(winName16);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                setPixel(x, y, round(dataORIG[ind++]));
            }
        }
    }

    // Save the resulting image as interfile
    selectWindow(winName16);
    run("Save As Interfile", "patient=TEW patient=TEW study=TEW view=[] save=" + outputPath + scanName + "_TEW.hdr");
    print("[TEW Correction] " + outputPath + scanName + "_TEW.hdr");

    // Write out EM-TEW
    winNameOrig = "EM-TEW_nozero";
    winName16 = winNameOrig + "16bit";

    // Close the windows that we don't want
    selectWindow(winNameOrig);

    // Duplicate the image and convert to 16bit
    dup = "title=" + winName16 + " duplicate range=1-" + nSlices;
    run("Duplicate...", dup);
    run("16-bit");

    // Create data arrays for each image
    getDimensions(width, height, channels, slices, frames);
    dataORIG = newArray(width * height * slices);

    // Read data into arrays for comparison
    selectWindow(winNameOrig);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                dataORIG[ind++] = getPixel(x, y);
            }
        }
    }

    // Copy data to new image
    selectWindow(winName16);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                setPixel(x, y, round(dataORIG[ind++]));
            }
        }
    }

    // Save the resulting image as interfile
    selectWindow(winName16);
    run("Save As Interfile", "patient=EM-TEW patient=EM-TEW study=EM-TEW view=[] save=" + outputPath + scanName + "_EM-TEW.hdr");
    print("[EM - TEW] " + outputPath + scanName + "_EM-TEW.hdr");
}
//---------------------------------------------------------------------------



//---------------------------------------------------------------------------
// Analyse the effect of the TEW corrections
//
// Create a report on the effect of TEW
function analyseTEW(outputName) {

    print("\n** Analysing TEW correction");

    // Open output file
    if (useFloat == 1) {
        outputReportName = outputName + "_float.txt";
        f = File.open(outputReportName);
        print(f, "Using floating point arithemtic (useFloat = " + useFloat + ")\n\n");

    }
    if (useFloat == 0) {
        outputReportName = outputName + "_int.txt";
        f = File.open(outputReportName);
        print(f, "Using integer arithemtic (useFloat = " + 0 + ")\n");
    }

    print("Writing report to " + outputReportName);

    print(f, printTime() + "\n\n");

    // Get the counts in each image
    countsEM = measureWholeImageNC(emID);
    countsSC1 = measureWholeImageNC(sc1ContID);
    countsSC2 = measureWholeImageNC(sc2ContID);
    countsTEW = measureWholeImageNC(tewID);

    countsEM_TEW_f = measureWholeImageNC(em_tewID_f);
    countsEM_TEW_nozero = measureWholeImageNC(em_tewID_nozero);
    countsEM_TEW_unsigned = measureWholeImageNC(em_tewID_unsigned);


    // Loop through EM and get number of effected pixels for each correction
    selectImage(emID);
    getDimensions(width, height, channels, slices, frames);
    if (DEBUG > 1) print("Start loop through stack");

    // Initialse counting variables
    pixelEM = 0;
    pixelTEW = 0;
    pixelTEW_nozero = 0;
    pixelTEW_unsigned = 0;

    // As the overhead for selecting an image is huge we have to read the data into arrays to do any comparisons
    // This (hopefully) explains the horrible use of loops coming up !

    // Create data arrays for each image
    dataEM = newArray(width * height * slices);
    dataTEW = newArray(width * height * slices);
    dataTEW_nozero = newArray(width * height * slices);
    dataTEW_unsigned = newArray(width * height * slices);

    // Read data into arrays for comparison
    selectImage(emID);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                dataEM[ind] = getPixel(x, y);

                //Count total pixles
                pixelEM++;

                // Increment array index
                ind++;
            }
        }
    }

    selectImage(em_tewID_f);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                dataTEW[ind] = getPixel(x, y);

                // Increment array index
                ind++;
            }
        }
    }

    selectImage(em_tewID_nozero);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                dataTEW_nozero[ind] = getPixel(x, y);

                // Increment array index
                ind++;
            }
        }
    }

    selectImage(em_tewID_unsigned);
    ind = 0;
    for (s = 1; s <= nSlices(); s++) {
        setSlice(s);
        //print("Slice = " + s + "\n");
        for (x = 0; x < width; x++) {
            for (y = 0; y < height; y++) {
                //Store data
                dataTEW_unsigned[ind] = getPixel(x, y);

                // Increment array index
                ind++;
            }
        }
    }

    // Loop through data arrays and compare pixels
    for (i = 0; i < dataEM.length; i++) {
        if (dataTEW[i] != dataEM[i]) {
            pixelTEW++;
        }
        if (dataTEW_nozero[i] != dataEM[i]) {
            pixelTEW_nozero++;
        }
        if (dataTEW_unsigned[i] != floor(dataEM[i])) {
            pixelTEW_unsigned++;
        }
    }

    if (DEBUG > 1) print("End loop through stack");

    print(f, "---------------\n");
    print(f, "Energy Windows:\n");
    print(f, "---------------\n\n");

    print(f, "EM:  Width = " + w_em + " keV (Peak = " + p_em + " keV) [+/-" + 50.0 * (w_em / p_em) + "%]\n");
    print(f, "SC1: Width = " + w_sc1 + " keV (Peak = " + p_sc1 + " keV) [+/-" + 50.0 * (w_sc1 / p_sc1) + "%]\n");
    print(f, "SC2: Width = " + w_sc2 + " keV (Peak = " + p_sc2 + " keV) [+/-" + 50.0 * (w_sc2 / p_sc2) + "%]\n\n");

    print(f, "SC1 Scale Factor = " + scaleFac1 + "\n");
    print(f, "SC2 Scale Factor = " + scaleFac2 + "\n\n");

    print(f, "----------------------\n");
    print(f, "Correction Statistics:\n");
    print(f, "----------------------\n\n");

    print(f, "|---------------------------------------- ---------------|\n");
    print(f, "|                      | Counts | (% of EM) | (% of TEW) |\n");
    print(f, "|--------------------------------------------------------|\n");
    print(f, "| EM photopeak         | " + countsEM[0] + " | " + 100.0 * countsEM[0] / countsEM[0] + " | " + 100.0 * countsEM[0] / countsTEW[0] + "|\n");
    print(f, "| SC1 TEW contribution | " + countsSC1[0] + " | " + 100.0 * countsSC1[0] / countsEM[0] + " | " + 100.0 * countsSC1[0] / countsTEW[0] + "|\n");
    print(f, "| SC2 TEW contribution | " + countsSC2[0] + " | " + 100.0 * countsSC2[0] / countsEM[0] + " | " + 100.0 * countsSC2[0] / countsTEW[0] + "|\n");
    print(f, "| TEW total            | " + countsTEW[0] + " | " + 100.0 * countsTEW[0] / countsEM[0] + " | " + 100.0 * countsTEW[0] / countsTEW[0] + "|\n");
    print(f, "|--------------------------------------------------------|\n\n");

    print(f, "---------------------\n");
    print(f, "Effect of correction:\n");
    print(f, "---------------------\n\n");

    print(f, "Total pixels: " + pixelEM + " (" + width + "x" + height + "x" + slices + ")\n\n");

    print(f, "|------------------------------------------------------------------------------------------|\n");
    print(f, "|                       | Pixels changed | (% of total) | # negative pixels | (% of total) |\n");
    print(f, "|------------------------------------------------------------------------------------------|\n");
    print(f, "| TEW signed float      |" + pixelTEW + " | " + 100.0 * pixelTEW / pixelEM + " | " + pixelTEW - pixelTEW_nozero + " | " + 100.0 * (pixelTEW - pixelTEW_nozero) / pixelEM + "|\n");
    print(f, "| TEW (unsigned float)  |" + pixelTEW_nozero + " | " + 100.0 * pixelTEW_nozero / pixelEM + " | " + pixelTEW_nozero - pixelTEW_nozero + " | " + 100.0 * (pixelTEW_nozero - pixelTEW_nozero) / pixelEM + "|\n");
    print(f, "| TEW (unsigned int)    |" + pixelTEW_unsigned + " | " + 100.0 * pixelTEW_unsigned / pixelEM + " | " + pixelTEW_unsigned - pixelTEW_nozero + " | " + 100.0 * (pixelTEW_unsigned - pixelTEW_nozero) / pixelEM + "|\n");
    print(f, "|------------------------------------------------------------------------------------------|\n\n");

    print(f, "-------------\n");
    print(f, "Final Images:\n");
    print(f, "-------------\n\n");

    print(f, "|------------------------------------------------------------------------------|\n");
    print(f, "|                         | Counts | (% of EM) | Counts subtracted | (% of EM) |\n");
    print(f, "|------------------------------------------------------------------------------|\n");
    print(f, "| EM-TEW signed float          | " + countsEM_TEW_f[0] + " | " + 100.0 * (countsEM_TEW_f[0] / countsEM[0]) + " | " + countsEM[0] - countsEM_TEW_f[0] + " | " + 100.0 * (countsEM[0] - countsEM_TEW_f[0]) / countsEM[0] + " |\n");
    print(f, "| EM-TEW (unsigned float) | " + countsEM_TEW_nozero[0] + " | " + 100.0 * (countsEM_TEW_nozero[0] / countsEM[0]) + " | " + countsEM[0] - countsEM_TEW_nozero[0] + " | " + 100.0 * (countsEM[0] - countsEM_TEW_nozero[0]) / countsEM[0] + " |\n");
    print(f, "| EM-TEW (unsigned int)   | " + countsEM_TEW_unsigned[0] + " | " + 100.0 * (countsEM_TEW_unsigned[0] / countsEM[0]) + " | " + countsEM[0] - countsEM_TEW_unsigned[0] + " | " + 100.0 * (countsEM[0] - countsEM_TEW_unsigned[0]) / countsEM[0] + " |\n");
    print(f, "|------------------------------------------------------------------------------|\n");

    // Close the output file
    File.close(f);

}
//---------------------------------------------------------------------------



///////////////////////
// Library Functions //
///////////////////////


//---------------------------------------------------------------------------
// Measure total counst in stack on the image specified by sourceID 
// - Return the total counts in image (use an array for compatability with measureROIs())
function measureWholeImageNC(sourceID) {

    if (DEBUG > 1) print("Analysing W.I...");

    // Set the measurements we want to make                                                                                          
    run("Set Measurements...", "area min bounding shape integrated stack display redirect=None decimal=5");

    // Create output variable                                                                                                        
    sumCounts = newArray(1);

    // Initalse the output array                                                                                                     
    sumCounts[0] = 0;

    // Select the image                                                                                                              
    selectImage(sourceID);

    // Loop through all slices                                                                                                       
    for (i = 1; i <= nSlices(); i++) {
        setSlice(i);

        if (DEBUG == 0) {
            List.setMeasurements;
            sumCounts[0] += List.getValue("RawIntDen");
            List.clear();
        }
        if (DEBUG > 0) {
            run("Measure");
            sumCounts[0] += getResult("RawIntDen");
        }

    }

    return sumCounts;

}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------                                                       
// Open the specified image and return the ImageID                                                                                   
function openImage(imageName) {

    // Open the file                                                                                                                
    open(imageName);

    // Get the imageID                                                                                                               
    sourceID = getImageID();

    if (DEBUG > 1) print("Opened: " + imageName + " as ImageID " + sourceID);

    return sourceID;
}
//---------------------------------------------------------------------------    

//---------------------------------------------------------------------------                                                        
// Return a nicely formatted time stamp string                                                                                       
function printTime() {
    MonthNames = newArray("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
    DayNames = newArray("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    TimeString = "Date: " + DayNames[dayOfWeek] + " ";
    if (dayOfMonth < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + dayOfMonth + "-" + MonthNames[month] + "-" + year + " Time: ";
    if (hour < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + hour + ":";
    if (minute < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + minute + ":";
    if (second < 10) { TimeString = TimeString + "0"; }
    TimeString = TimeString + second;

    return TimeString;
}
//---------------------------------------------------------------------------                                                        

//---------------------------------------------------------------------------
// Close all open windows with out saving
//
function closeAllWindows() {
    list = getList("window.titles");
    for (i = 0; i < list.length; i++) {
        winame = list[i];
        selectWindow(winame);
        run("Close");
    }
}
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------
// Close all open images without saving
//
function closeAllImages() {
    while (nImages > 0) {
        selectImage(nImages);
        close();
    }
}
//---------------------------------------------------------------------------
