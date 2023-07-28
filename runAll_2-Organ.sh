#!/bin/bash

# Generate NM VOIS from CT

# cortex:
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR 2-Organ _CT_spleen
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima 2-Organ _CT_spleen
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR 2-Organ _CT_spleen
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS 2-Organ _CT_spleen

# cortex:
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR 2-Organ _CT_cortex
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima 2-Organ _CT_cortex
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR 2-Organ _CT_cortex
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS 2-Organ _CT_cortex

# medulla:
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm DR 2-Organ _CT_medulla
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm Optima 2-Organ _CT_medulla
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-WEHR 2-Organ _CT_medulla
source rIJm.sh macros/GE-RSCH/makeNucMedROI.ijm CZT-MEHRS 2-Organ _CT_medulla
