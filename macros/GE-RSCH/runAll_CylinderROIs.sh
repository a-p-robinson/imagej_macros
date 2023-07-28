#!/bin/bash

# # Generate a cylinder on CT
source rIJm.sh macros/GE-RSCH/cylinderROI.ijm DR Cylinder
source rIJm.sh macros/GE-RSCH/cylinderROI.ijm Optima Cylinder
source rIJm.sh macros/GE-RSCH/cylinderROI.ijm CZT-WEHR Cylinder
source rIJm.sh macros/GE-RSCH/cylinderROI.ijm CZT-MEHRS Cylinder

# Generate NM VOIS from CT
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Cylinder
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Cylinder
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Cylinder
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Cylinder
