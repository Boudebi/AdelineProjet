# -*- coding: utf-8 -*-
"""
Éditeur de Spyder

Ceci est un script temporaire.
"""
##This script will open up a fits image and crop it according to the boundaries
##contained in the arguments, xstart, xstop, ystart ,ystop
##


import os
import pyfits
import csv
import numpy as np



def CropFits(FileName,XStart,XStop,YStart,YStop,NbGal):


#Create a directory for Astrometry output
	Dir = os.path.dirname(FileName)	
	OutDir = Dir+'Cropped'
	if not os.path.exists(OutDir): os.mkdir(OutDir)

	FitsHDU = pyfits.open(FileName)
	Im = FitsHDU[0].data
	FitsHeader = FitsHDU[0].header

#Crop the image
	Im = Im[XStart:XStop, YStart:YStop]
	FitsHDU[0].data=Im

	outlist = pyfits.PrimaryHDU(Im.astype('float32'),FitsHeader)
	Newheader = outlist.header
	Newheader['HISTORY'] = 'Cropped by CropFits'
    
#Write it to a new file
	OutFile = OutDir+'Galaxy'+str(NbGal)+'_'+'Cropped.fits'
	if os.path.exists(OutFile) : os.remove(OutFile)
	FitsHDU.writeto(OutFile)
	
	FitsHDU.close()

def Cropcsv(FileName, NbGal):
	File = np.loadtxt(open('taillescrops.csv'), delimiter=';')
	Galaxy = File[:,0]
	XStart = File[:,7]
	XStop = File[:,8]
	YStart = File[:,5]
	YStop = File[:,6]
	
	for i in range(len(Galaxy)):
		if Galaxy[i] == NbGal:
			CropFits(FileName,XStart[i],XStop[i],YStart[i],YStop[i],NbGal)

Cropcsv('h_udf_wfc_i_drz_img.fits',542)

