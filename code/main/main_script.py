import os 
import pandas as pd 
import nibabel as nib
import matplotlib.pyplot as plt
from prepare_mprage import prepare_mprage
from warp_to_invivo import warp_to_invivo
from topup import topup
from moco import moco
from apply_warp import apply_warp
from flip_epi import flip_epi
from average_org_and_flipped import average_org_and_flipped
from first_level_feat import first_level_feat
from trick_fsl import trick_fsl
from make_overlay_plot import make_overlay_plot
'''
This script does the statistical analysis of LDOG mri images with FSL. However, 
the actual analysis performed by the Flywheel gears utilizes several different 
functions and slightly modified versions of the functions provided here. This 
script outlines the pipeline and can be used with other projects if FSL is the
main choice for analysis.
'''

# Set path to the folder containing mprage images ONLY
path_to_mprage = '/home/ozzy/Desktop/canineonepseudo/T1'

# Set path to the folder containing EPI images ONLY
path_to_epi = '/home/ozzy/Desktop/canineonepseudo/EPI/part3'

# Set path to the Atlas (template) you want to use
template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/invivoTemplate.nii.gz'

# If you have a downsampled version of the atlas provide it here. If you use a
# high-res Atlas only , your EPI images will be upsampled and large in size and 
# it might cause some FSL memory issues .
resampled_template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz'

# Path to recon MRIs. This is a folder containing single volume AP and PA images.
# This is used to calculate topup if you collected your images in tho directions
path_to_recon_fmris = '/home/ozzy/Desktop/canineonepseudo/Recon/part3'

# Output path where the results will be written. The function will create 
# extra folders in this path.
output_folder = '/home/ozzy/Desktop/canineonepseudo/results'

# This is LDOG specific. Does the first level analysis
first_level_design_folder = '/home/ozzy/Desktop/canineonepseudo/design'

# Set some variables
make_pseudo_hemispheres = False # Decides if a pseudo hemi will be created through a left-right hemisphere averaging
number_of_threads = 6 # Number of threads to use for registrations
extraction_threshold = 0.2 # Number of threshold used for brain extraction 0.5 for human brain is a good threshold
centre_of_gravity = [91, 42, 95] # center of the T1 image. Required for brain extraction. Does not need to be exact
total_readout_time_AP = 0.0217349 # total readout time for AP (can be found in nifti header)
total_readout_time_PA = 0.0217349 # total readout time for PA (can be found in nifti header)

# Create the output folder if it does not exist
if not os.path.exists(output_folder):
    os.system('mkdir %s' % output_folder)

####################### Structure prerocessing ################################
            
# Run prepare_mprage
preprocessed_mprage_folder, averaged_mprage, extracted_brain, flipped_extracted_brain = prepare_mprage(path_to_mprage, centre_of_gravity, extraction_threshold, output_folder)

# Saves a brain extraction diagnostic image
diagnostic_images = make_overlay_plot(averaged_mprage, extracted_brain, 'Brain Extraction Results', 'brain_extraction_qa.png', output_folder)

# Warps the averaged mprage to the template 
warp_results_folder, warped_mprage, standard_generic = warp_to_invivo(extracted_brain, template_path, output_folder, number_of_threads, 'dog_diff')

# Saves some more diagnostic images for standard and flipped registrations
make_overlay_plot(template_path, warped_mprage, 'Warp results', 'mprage2template_qa.png', output_folder)

if make_pseudo_hemispheres:
    # Warps the flipped-averaged mprage to the template
    _, flipped_warped_mprage, flipped_generic = warp_to_invivo(flipped_extracted_brain, template_path, output_folder, number_of_threads, 'flipped_dog_diff')
    make_overlay_plot(template_path, flipped_warped_mprage, 'Flipped Warp results', 'flipped_mprage2template_qa.png', output_folder)
    
#######################  EPI prerocessing ####################################

# Calculate and apply topup
top_up_folder, corrected_epi = topup(path_to_recon_fmris, path_to_epi, total_readout_time_AP, total_readout_time_PA, output_folder)

# Motion correction and time derivative calculation. Overwrites the original 
# EPI images !!!
moco_cov = moco(corrected_epi, top_up_folder, output_folder)

# Apply warps to the standard and flipped EPI images and downsample to res using 
# the downsampled image as the target.
warped_epi = apply_warp(corrected_epi, resampled_template_path, output_folder, standard_generic, False)

if make_pseudo_hemispheres:
    # Flip the EPI images 
    flipped_epi = flip_epi(corrected_epi, output_folder)

    # Apply warps to the flipped epi and downsample to template res
    flipped_warped_epi = apply_warp(flipped_epi, resampled_template_path, output_folder, flipped_generic, True)

    # Average flipped and unflipped EPI images
    final_epi = average_org_and_flipped(warped_epi, flipped_warped_epi, output_folder)
########################## FEAT ############################################

# Do the first level analyses
first_lvl_res = first_level_feat(final_epi, first_level_design_folder, resampled_template_path, moco_cov, output_folder)
    
# Trick FSL
trick_fsl(first_lvl_res)
