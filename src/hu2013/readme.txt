SOURCE CODE FOR "HDR Deghosting: How to deal with Saturation ?"
Jun Hu, Orazo Gallo, Kari Pulli, Xiaobai Sun
CVPR, Portland, Oregan. June, 2013

Copyright 2013 by Duke University and Jun Hu

Running this package

1. Open patchmatch-2.1 and compile them to generate mex files.
   If success, you should find three mex files with name:
   nnmex, votemex and patchdist.

2. Copy all test cases into dir 'Data', each test case has a
   individual sub dir as 'Lady'.

3. Make sure the images are sorted according to their exposure times.

4. By default, the middle image is selected as reference. 
   Optional: To use the other image as the reference, 
   please change line 58 in main.m 

5. Run 'main.m'

6. For each test case, a mat file named after the corresponding sub
   dir name is built. Inside mat file, you can find
   imgStack  :   input stack
   latentImgs:   output aligned stack (result)
   ppIMFs    :   intensity mapping functions between neighbouring imgs
                 of the input stack
   invppIMFs :   inverse function of ppIMFs
   uv        :   dense correspondence for patches from neighbouring imgs
                 of the input stack


Please Contact Jun Hu at junhu@cs.duke.edu if you find any bugs or have
comments/questions.  

Jun Hu
Aug, 2013