// Run the unit tests
macro "run_unit_tests"{
    i = 0; // Number of tests completed

    test_closeAllWindows();
    i++;
    test_closeAllimages();
    i++;
    test_printTime();
    i++;
    test_openImage();
    i++;
    // test_loadUserInterface();
    // i++;
    test_parseInputFile();
    i++;
    test_loadTEW();
    i++;
    test_measureWholeImage();
    i++;
    test_generateTEW();
    i++;
    test_analyseTEW();
    i++;
    test_writeTEWinter();
    i++;

    print("+++All unit tests passed [" + i + " total]+++");

    

}