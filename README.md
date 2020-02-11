# mriLDOGAnalysis
Analysis code and Flywheel gears for all projects under the LDOG protocol

# Software Requirements
- Python3 (Python2 should also work but not tested)
- FSL 
- ANTs 
- Freesurfer
- altAntsBrainExtraction - https://github.com/cookpa/altAntsBrainExtraction
- ITK-Snap

# Python package requirements
- nibabel
- matplotlib
- imageio
- pandas
- numpy

# ldog_struct steps

1 - MPRAGE images are bias corrected.

    "N4BiasFieldCorrection -d 3 -i |IMAGE| -o |OUTPUT|"

2 - If more than one MPRAGE is used, they are linearly registered together.

    "antsRegistrationSyN.sh -d 3 -t |TRANSFORM-TYPE| -f |FIXED| -m |MOVING| -o |OUTPUT| -n 6"

3 - Registered MPRAGES are averaged.

    "AverageImages 3 |OUTPUT| 1 |/images/*| 

4 - A brain extraction mask is created with FSL Bet.

    "bet |INPUT| |OUTPUT| -f |EXTRACTION THRESHOLD| -c |CENTER VOXEL X| |CENTER VOXEL Y| |CENTER VOXEL Z| -m'

5 - Segmentation function from altAntsBrainExtraction is used to skull strip. The mask obtained from the previous stage is used here.

    "brainExtractionSegmentation.pl --input |WHOLE-HEAD IMAGE| --initial-brain-mask |MASK| --bias-correct 0 --output-root |OUTPUT ROOT NAME|

6 - The images are non-linearly registered (warped) to a skull stripped canine template (Datta et al., 2012) and a warp image and deformation matrix were obtained.

    "antsRegistrationSyN -d 3 -f |TEMPLATE| -m |T1| -o |OUTPUT_NAME|"

# ldog_func steps

1 - Topup is performed on the data for AP and PA directions:

a) Two single-rep images are merged together
    
    "fslmerge -a |AP+PA.nii.gz| |AP_image.nii.gz| |PA_image.nii.gz|

b) Field map is calculated using the merged image and acquisition parameters text file which includes the phase encoding directions and times:
    
    "topup --imain=|AP+PA.nii.gz| --datain=|Acqparams.txt| --config=b02b0.cnf --out=topup_results --iout=b0_unwarped --fout=fieldmap_Hz"

c) Correction is applied to each EPI image:
    
    "applytopup --imain=EPI_AP.nii.gz --inindex=1 --method=jac --datatin=Acqparams.txt --topup=topup_results --out=corrected.nii.gz"
    
    "applytopup --imain=EPI_PA.nii.gz --inindex=2 --method=jac --datatin=Acqparams.txt --topup=topup_results --out=corrected.nii.gz"

2 - Motion correction is performed. Topup corrected AP scout image is used as the target. Time derivatives and squares are calculated. 

    "mcflirt -in |INPUT| -o |OUTPUT| -reffile |TARGET IMAGE| -dof 12 -plots
   
3 - The warp field and affine matrix obtained from the ldog_struct gear is applied to each time series. 

    "antsApplyTransforms --float --default-value 0 --input |INPUT| --input-image-type 3 --interpolation Linear --output |OUTPUT| --reference-image |TARGET| --transform |WARP| --transform |AFFINE MAT|"

4 - Using the template as reference the BOLD images are skull stripped.

# ldog_fix steps

1 - Data is smoothed:

    "fslmaths |INPUT| -kernel gauss |VALUE| -fmean |OUTPUT|

2 - Signal is converted to percentage change


# Additional processing 

1 - For fMRI analysis, the preprocessed images are used as inputs for the forwardModel gear which performs non-linear model fitting.

2 - Maps are warped to the ex-vivo surface template with a 3-step registration:

a) Linear registration to the original surfer volume (located in Woofsurfer/mri/T1.nii)
       
    "flirt -in |INVIVO| -ref |T1.nii| -out |OUTPUT_LINEAR_IMAGE| -omat |OUTPUT MATRIX| -bins 256 -cost corratio -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12  -interp trilinear

b) The omat obtained from above step is coverted to ITK style matrix by using ITK-Snap tool 
    
    "c3d_affine_tool -ref |T1.nii| -src |INVIVO| |FSL OUTPUT MATRIX| -fsl2ras -oitk |ITK NEW MATRIX NAME.mat|

c) A warp between the output of the step a) and original surfer volume
    
    "antsRegistrationSyN.sh -d 3 -t so -f |T1.nii| -m |OUTPUT_LINEAR_IMAGE| -o |OUTPUT| -n 6

d) Applying the warp by combining the linear matrix with the warp field
       
    "antsApplyTransforms --float --default-value 0 --input |INPUT_MAP| --input-image-type 3 --interpolation Linear --output |FINAL_MAP| --reference-image |T1.nii| --transform |WARP| --transform |GENERIC_AFFINE| --transform |AFFINE MAT_converted_from_fsl|"

3 - Create a register.dat matrix by using an FSL identity matrix. Using the output of the previous step (final warped image) as the moving and target:

    "tkregister2 --mov |ALREADY_WARPED_INVIVO| --fsl |IDENTITY.MAT| --targ |ALREADY_WARPED_INVIVO| --noedit --reg register.dat" 

4 - Create surface maps. Using the output of the previous step (final warped image) as the moving and target again:

    "mri_vol2surf --mov |ALREADY_WARPED_INVIVO| --ref |ALREADY_WARPED_INVIVO| --reg |REGISTER.DAT| --srcsubject Woofsurfer --hemi |WHICH HEMI| --o |OUTPUT|  

