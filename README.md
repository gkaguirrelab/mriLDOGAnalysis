# mriLDOGAnalysis
Analysis code for all projects under the LDOG protocol

# Analysis steps (might change)

1 - Two MPRAGE images were registered using FSL's flirt Rigid Body transformation (6DOF) 

"flirt -in <INPUT> -ref <REFERENCE> -out <OUTPUT> -omat <OUTPUT_MATRIX> -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6  -interp trilinear"

2 - Registered T1 images were averaged using ANTs' AverageImages

"AverageImages 3 <OUTPUT> 1 <IMAGE> <IMAGE>"

3 - Averaged T1-with-skull images were non-linearly registered (warped) to a canine template-without-skull (Datta et al., 2012) and a warp image and deformation matrix were obtained. ANTs is used for non-linear registration since it works better with non-brain-extracted volumes.

"antsRegistrationSyN -d 3 -f <TEMPLATE> -m <T1> -o <OUTPUT_NAME>"

4 - FSL's 1st level feat fmri analysis was performed on the individual EPIs. FSL does 1st level analysis in the native space. It creates a registration folder during this stage which will be applied during the group analysis. If you do not specify any registration in the 1st step, your group analysis will fail because it look for the registration files but won't be able to find them. Therefore, do a registration to a template in the first level by selecting any template. It does not really matter what you register to because the registration will not be applied until the second level. We just want to do this to trick fsl into creating registration files. Later we will replace those registration files with identity matrices so no registration will be performed.

5 - Tricking FSL to do the group analysis without registration:
   . Make sure the folder called reg_standard does not appear in your 1st level analysis directories. Delete if it appears. It usually appears when the registration is applied to the data which we don't want it to happen.
   . Copy an identity matrix from FSLdir into the reg folder of each of your 1st level directories and name the matrices example_func2standard.mat.
	"cp $FSLDIR/etc/flirtsch/ident.mat reg/example_func2standard.mat"
   . Overwrite the standard.nii.gz image which is located in the same reg directory with the mean_func.nii.gz image in your main 1st level directory so no interpolation will take place either.
  	"cp mv mean_func.nii.gz reg/standard.nii.gz"
   . Check if everything looks alright. Voxel intensities between stats/cope#.nii.gz and reg_standard/stats/cope#.nii.gz should be exactly the same and data dimension and pixel size should be same as mean_func

6 - Do the FSL's 2nd level (Group) analysis.

7 - Transform the Z-stat maps into native space by applying the deformation fields we obtained after non-linear registration (Step 3).

"antsApplyTransforms -d 3 -r <TEMPLATE> -i <ZSTAT_MAP> -t <XXX1Warp.nii.gz> -t <XXX0GenericAffine.mat> -o <out.nii.gz> -v 1"
