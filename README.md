# mriLDOGAnalysis
Analysis code for all projects under the LDOG protocol

# Requirements

- FSL for fmri analysis
- ANTs for registrations

# Analysis Instructions

1 - For canine analysis download the design file which has the on>off and off>on event design templates saved inside. This template file is automatically modified by a loop in the preprocAndFirstLvl.py function according to the specific subject information.

2 - Run preprocAndFirstLvl.py function and point it to T1, EPI, Canine Atlas, Design, Output and ANTs folders (don't use a slash at the end of the paths. e.g. /home/Desktop/T1). This function will do the first five steps mentioned under Analysis Details section. Separate folders for registration and 1st level results are created at the output path specified. 

3 - Second-level analysis : Doing the second-level analysis manually is a better option for now. A lot of files need to be modified in order to automate it since the shape and length of the design matrix change depending on many factors (e.g. Size of the data). Might be automated in the future.

4 - Run the postprocess.py (Coming coon) function which (i) applies the deformations obtaied during the preprocAndFirstLvl.py function to the second-level z-score results in order to warp the maps to the volumetric standard canine space (ii) maps the results to canine surface maps.

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

6 - Do the 2nd level analysis for both left-right during off>on and left+right during off>on conditions. 

7 - Transform the Z-stat maps into native space by applying the deformation fields we obtained after non-linear registration (Step 3).

"antsApplyTransforms -d 3 -r |TEMPLATE| -i |ZSTAT_MAP| -t |XXX1Warp.nii.gz| -t |XXX0GenericAffine.mat| -o |out.nii.gz| -v 1"

8 - Generate surface maps (Work in progress)
