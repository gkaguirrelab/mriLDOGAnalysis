# mriLDOGAnalysis
Analysis code for all projects under the LDOG protocol

# Requirements

- Python 2 (Python 3 should also work but not tested)
- FSL for fmri analysis
- ANTs for registrations

# Analysis Instructions

1 - Create an empty analysis folder where you will place your MRI images and where the results folder will be created.

2 - Download the design folder which has the on>off and off>on event design templates saved inside and place it into the analysis folder you created in step 1. This template file is automatically modified by a loop by the python function according to the specific subject information.

2 - Download the Atlas folder which contains the canine atlases and in-vivo --> ex-vivo transformations. Place it in the main analysis folder.

3 - Download your EPI and MPRAGE images and place them into two different subfolders inside the main analysis folder.

4 - If you want to do the full analysis also download the second_lvl_design folder and place it in the main analysis folder.

2 - Run fullAnalysis.py function and point it to the T1, EPI, Canine Atlas, Design, Second level design, Output and ANTs scripts folders (don't use a slash at the end of the paths. Use it like /home/Desktop/T1). This function will do the first seven steps mentioned under "Analysis Details" section. It creates a main results folder at the specified path. All of your results such as registrations, 1st and 2nd level outputs, and final in-vivo deformed maps will be saved into this folder.

Warning: fullAnalysis.py performs second level analysis and takes a fixed effects single group average. If you want to compare right and left eyes or employ a different model, you need to do the second level analysis manually. In this case, you can first use onlyPreprocAndFirstLvl.py function to do preprocessing and 1st lvl analysis, then do your group analysis yourself, and finally run onlyPostprocess.py (coming soon) to map the data to in-vivo and surface templates.

# Analysis Details

1 - Two MPRAGE images were registered using FSL's flirt Rigid Body transformation (6DOF) 

"flirt -in |INPUT| -ref |REFERENCE| -out |OUTPUT| -omat |OUTPUT_MATRIX| -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6  -interp trilinear"

2 - Registered T1 images were averaged using ANTs' AverageImages

"AverageImages 3 |OUTPUT| 1 |IMAGE| |IMAGE|"

3 - Averaged T1-with-skull images were non-linearly registered (warped) to a canine template-without-skull (Datta et al., 2012) and a warp image and deformation matrix were obtained. ANTs is used for non-linear registration since it works better with non-brain-extracted volumes.

"antsRegistrationSyN -d 3 -f |TEMPLATE| -m |T1| -o |OUTPUT_NAME|"

4 - FSL's 1st level fmri analysis was performed on the individual EPIs. 
Notes: FSL does the 1st level analysis in the native space. It creates registration files in each 1st level output folder but does not apply the transformations until the 2nd level analysis. If you do not specify any registration in the 1st step, your 2nd level analysis will fail because FSL looks for a registration file during this stage. In order to be able to do the 2nd level analysis without any transformations we need to trick FSL. For this we need to do the registrations in the first level to have FSL create the necessary files but then we replace those files with identity matrices so no transformation takes place.
   Tricking FSL to do the group analysis without registration:
   . Make sure the folder called reg_standard does not appear in your 1st level analysis directories. Delete if it appears. It usually appears when some registration is applied to the data which we don't want at this stage.
   . Copy an identity matrix from FSL's main directory to the reg subfolder of each of your 1st level output folders and rename the matrices example_func2standard.mat.
	"cp $FSLDIR/etc/flirtsch/ident.mat reg/example_func2standard.mat"
   . Overwrite the standard.nii.gz image which is located in the same reg directory with the mean_func.nii.gz image in your main 1st level directory so that no interpolation will take place either.
  	"cp mv mean_func.nii.gz reg/standard.nii.gz"
   . Check if everything looks alright. Voxel intensities between stats/cope#.nii.gz and reg_standard/stats/cope#.nii.gz should be exactly the same and data dimension and pixel size should be the same as mean_func

6 - Do the 2nd level fixed effects averaging analysis for both off>on and on>off conditions. 

7 - Transform the Z-stat maps into native space by applying the deformation fields we obtained after non-linear registration (Step 3).

"antsApplyTransforms -d 3 -r |TEMPLATE| -i |ZSTAT_MAP| -t |XXX1Warp.nii.gz| -t |XXX0GenericAffine.mat| -o |out.nii.gz| -v 1"

8 - Generating surface maps: In vivo deformed z-stats can be overlaid with the mgz converted ex-vivo atlas (lives in Woofsurfer/mri/orig/001.mgz) or with original and inflated surface images by using Freesurfer's freeview or tksurfer. Both of these methods can accept another registration matrix, which we prepared by linearly registering the invivo template to exvivo, as an input which will transform maps one more time to freesurface space. register.dat transformation matrix which lives in the Atlas/intoex/ folder can be selected as a transformation matrix during visualizations.

Note: In-vivo to ex-vivo atlas transformation was performed by FSL's linear transfromation (FLIRT) with 12 DOF. Then, the transformation matrix created by FLIRT was converted to freesurfer .dat format by tkregister2 command:

"tkregister2 --mov invivoTemplate.nii.gz --fsl intoex.mat --targ SurfaceTemplate/Woofsurfer/mri/orig/001.mgz --noedit --reg register.dat"

