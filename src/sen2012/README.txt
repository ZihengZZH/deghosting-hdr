SOURCE CODE FOR ROBUST PATCH-BASED HDR RECONSTRUCTION OF DYNAMIC SCENES

This package is a MATLAB implementation of the patch-based high-dynamic range
(HDR) reconstruction algorithm described in:


P. Sen, N. K. Kalantari, M. Yaesoubi, S. Darabi, D. Goldman, E. Shechtman,
"Robust Patch-Based HDR Reconstruction of Synamic Scenes", 
ACM Transaction on Graphics, Volume 31, Number 6, Article 203, November 2012. 


The definitive version of the paper can be found in the ACM Digital Library:
http://dl.acm.org/citation.cfm?doid=2366145.2366222

More information can also be found on the authors' project webpage:
http://www.ece.ucsb.edu/~psen/hdr/


Initial release implementation by Nima K. Kalantari, 2012.


-------------------------------------------------------------------------
I. LICENSE CONDITIONS

Copyright (2012), the authors.

This software for producing an HDR image from a set of LDR inputs is
provided for individual research use only.  Any commercial use or any
redistribution of this software requires a license from the University
of New Mexico.

The following provisional patent application has been submitted for
the methods embodied in this software:
#61/625,333 - "SYSTEM AND METHODS FOR RECONSTRUCTING HIGH DYNAMIC RANGE 
IMAGES FROM A SEQUENTIAL SET OF LOW DYNAMIC RANGE INPUTS"

For commercial inquiries regarding the HDR reconstruction algorithm
presented in this paper, please contact Ms. Jovan Heusser at the UNM
technology transfer office STC.UNM. Her telephone number is
(505) 272-7908 and email address is jheusser@stc.unm.edu.

THE UNIVERSITY OF NEW MEXICO, ADOBE, AND THE AUTHORS MAKE NO REPRESENTATIONS
OR WARRANTIES OF ANY KIND CONCERNING THIS SOFTWARE OR DATA SETS.

This license file must be retained with all copies of the software, including 
any modified or derivative versions.  Please cite our original paper if you 
use this code or data sets in a scientific publication.


-------------------------------------------------------------------------
II. OVERVIEW

This algorithm takes in a set of sequential low-dynamic range (LDR) images
at different exposures (in .tif format) and produces an HDR image that 
is aligned with a user-specified reference but contains information from
all LDRs.  The algorithm also produces a set of LDR images that have been
"aligned" to match the selected reference.

The current code expects to find the input images in a directory in the
"Scenes" folder and will output the results in the "Results" directory.
This folder will contain two kinds of results.  First, it will output
the aligned, LDR reconstructions in .tif format that can be merged with 
any standard HDR merging algorithm (as if the scene had been static).
Second, it will output the final HDR result in .hdr format that can then
be tonemapped with existing software.

The code was written in MATLAB 2012a, and tested on Windows 7. It uses four
.mex files, two of which are "nnmex" and "votemex" from the PatchMatch paper
[Barnes et al. 2009] that can be found here:

http://gfx.cs.princeton.edu/pubs/Barnes_2009_PAR/index.php

They have been slightly modified to handle floating point precision 
vote and MBDS.


-------------------------------------------------------------------------
III. RUNNING THIS PACKAGE ON THE SCENE FILES PROVIDED

1. Download "Scenes.zip", unzip it, and copy the desired scene folders (e.g., 
   "SantasLittleHelper") into the "Scenes" folder of the source distribution. 
   Each scene folder contains a set input images in .tif format and a text 
   file with the exposure values for each image.  This version of the 
   algorithm will be run on one scene at a time. 

2. Open "main.m" in MATLAB.

3. At the top of the file there is a list of scene filenames. Uncomment the 
   one to be processed, making sure the scene is in the proper folder.

4. Next, set the quality/speed profile to be either "normal", "medium", 
   or "high" (from fastest/lowest quality to slowest/highest quality). 
   To achieve the results comparable to those shown in the paper, the 
   code was run in 'normal' mode."

5. Run the code.  The results will be saved in the "Results" directory as
   described above.

Note that this is a random algorithm because of the use of PatchMatch to find 
correspondences between images.  Therefore, slightly different results will be 
obtained every time the code is run on a scene.


-------------------------------------------------------------------------
IV. PREPARING CAMERA RAW IMAGES (.CR2) TO BE USED AS INPUT TO OUR CODE

We now describe our pipeline for preparing the raw .CR2 images taken by 
the camera for input into our algorithm.  In our case we used various
Canon cameras, but this process might work for other kinds of cameras
as well.

1. Download the "dcraw" program available here: 
   http://www.insflug.org/raw/Downloads
  
   This executable converts raw images to .pgm files which are readable by 
   MATLAB.

2. Use the following command to convert your raw images to pgm:
   dcraw.exe -d -4 filename

   This will write a .pgm file with the same name as the original raw image.

3. After performing step 2 for all the raw images, put the .pgm files into a
   separate folder in the "Scenes" directory of the code distribution.

4) Open the "ImagePreprocess.m" file from our distribution in MATLAB.

5) Set the parameters on the top of the code to the values desired. The
   "sensorAlignment" variable is the Bayer pattern configuration and might
   be different from the default depending on the camera. To learn more about 
   it, visit the following link:

   http://www.mathworks.com/help/images/ref/demosaic.html

6. Run ImagePreprocess. It will create a .tif file for every one of the .pgm 
   files.  These .tif files are 16-bit so they preserve all of the dynamic 
   range captured in the original raw LDR images.

7. Make sure the images are sorted according to their exposure times.

8. Crate a text file in the same directory as the .tif images and write the 
   exposure value (EV) for each image.  Use one line per exposure value.

9. Run the code as described in Sec. III, making sure that the name of the
   scene has been changed to this new one.


For demonstration purposes, we provide our raw images for the "ChristmasRider" 
scene in the "Scene.zip" file.


-------------------------------------------------------------------------
V. ADDITIONAL SETTINGS AND DEBUGGING MODES

It is possible to save all intermediate patch-voted images during the 
multi-scale search and vote process. By default, writing out the intermediate 
results is disabled. If you want to activate it, simply open 
Functions\InitParams.m and set the "saveIntermediateResults" to true. These
images will be written in Results\Intermediate.


-------------------------------------------------------------------------
VI. VERSION HISTORY

v1.1 - Mar. 28 2013

Changes since v1.0
	- fixed a bug in the HDR merge
	- mex files for Linux and Mac has been included
	- updated the unweightCohMex and upscaleNN mex files  

Please download and use all the files (mex and MATLAB files) included in this 
package. Taking the mex files from this package and using them in v1.0 will not 
work since the MATLAB code in this new version has been modified to adapt with the
changes in the mex files.	
	
v1.0 - Initial release   (Nov. 28, 2012)

-------------------------------------------------------------------------

If you find any bugs or have comments/questions, please contact 
Nima K. Kalantari at nima@umail.ucsb.edu.

Santa Barbara, California
Mar. 28, 2013