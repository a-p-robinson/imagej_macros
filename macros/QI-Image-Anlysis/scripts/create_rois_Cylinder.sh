#!/bin/bash

# Generate a cylinder VOI on CT
source rIJm.sh macros/GE-RSCH/cylinderROI.ijm DR Cylinder
source rIJm.sh macros/GE-RSCH/makeNucMedROI-Cylinder.ijm
# source rIJm.sh macros/GE-RSCH/cylinderROI.ijm Optima Cylinder
# source rIJm.sh macros/GE-RSCH/cylinderROI.ijm CZT-WEHR Cylinder
# source rIJm.sh macros/GE-RSCH/cylinderROI.ijm CZT-MEHRS Cylinder

# # # Generate NM VOI from CT
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Cylinder
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Cylinder
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Cylinder
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Cylinder
