#!/bin/bash

# Generate a set of spheres on CT
# Sphere1:
# source rIJm.sh macros/GE-RSCH/sphereROI.ijm DR Sphere1 abc
source rIJm.sh macros/GE-RSCH/sphereROI.ijm Optima Sphere1 abc
# source rIJm.sh macros/GE-RSCH/sphereROI.ijm CZT-WEHR Sphere1 abc
# source rIJm.sh macros/GE-RSCH/sphereROI.ijm CZT-MEHRS Sphere1 abc

# Sphere2:
# source rIJm.sh macros/GE-RSCH/sphereROI-Sphere2.ijm DR Sphere2
# source rIJm.sh macros/GE-RSCH/sphereROI-Sphere2.ijm Optima Sphere2
# source rIJm.sh macros/GE-RSCH/sphereROI-Sphere2.ijm CZT-WEHR Sphere2
# source rIJm.sh macros/GE-RSCH/sphereROI-Sphere2.ijm CZT-MEHRS Sphere2

# # Generate NM VOIS from CT
# Sphere1:
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere1 _CT_Sphere_1
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere1 _CT_Sphere_2
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere1 _CT_Sphere_3
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere1 _CT_Sphere_4
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere1 _CT_Sphere_5
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere1 _CT_Sphere_6

source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere1 _CT_Sphere_1
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere1 _CT_Sphere_2
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere1 _CT_Sphere_3
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere1 _CT_Sphere_4
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere1 _CT_Sphere_5
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere1 _CT_Sphere_6

# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere1 _CT_Sphere_1
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere1 _CT_Sphere_2
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere1 _CT_Sphere_3
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere1 _CT_Sphere_4
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere1 _CT_Sphere_5
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere1 _CT_Sphere_6

# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere1 _CT_Sphere_1
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere1 _CT_Sphere_2
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere1 _CT_Sphere_3
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere1 _CT_Sphere_4
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere1 _CT_Sphere_5
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere1 _CT_Sphere_6

# Sphere2:
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR Sphere2
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima Sphere2
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR Sphere2
# source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS Sphere2