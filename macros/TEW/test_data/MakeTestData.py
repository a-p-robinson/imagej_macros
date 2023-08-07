#!/bin/python

import sys
import pydicom 
import numpy as np
import argparse

# Main   
def main():

    # Get the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("dicomfile", help="Original GE Xelris DICOM file")
    parser.add_argument("outputfile", help="Modified DICOM file")
    args = parser.parse_args()

    # Open the input file
    ds = pydicom.read_file(args.dicomfile)
    print(ds)

    # Blank identifying fields
    ds[0x08,0x0070].value = 'None'
    ds[0x08,0x0080].value = 'None'
    ds[0x08,0x0090].value = 'None'
    ds[0x08,0x1010].value = 'None'
    ds[0x09,0x1040].value = 'None'
    ds[0x10,0x0010].value = 'None'
    ds[0x10,0x0020].value = 'None'
    ds[0x18,0x1030].value = 'None'
    ds[0x20,0x0010].value = 'None'

    # Change the data
    arr = ds.pixel_array
    print(arr.shape)
    print(arr.dtype)

    # Create a single frame
    frame_value = 10000
    frame = np.zeros((arr.shape[1], arr.shape[2]), dtype=arr.dtype)
    frame[int(frame.shape[0]*0.25):int(frame.shape[0]*0.75), int(frame.shape[1]*0.25):int(frame.shape[1]*0.75)] = frame_value
    
    # Set each frame
    for i in range(arr.shape[0]) :
        arr[i] = frame
    
    # Copy data to pixeldata
    ds.PixelData = arr

    # Save Data   
    ds.save_as(args.outputfile);


if __name__ == '__main__':
    sys.exit(main())