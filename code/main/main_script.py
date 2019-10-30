import os 
import pandas as pd 
from prepare_mprage import prepare_mprage
from warp_to_invivo import warp_to_invivo
from topup import topup
from moco import moco
from apply_warp import apply_warp
from flip_epi import flip_epi
from average_org_and_flipped import average_org_and_flipped
from first_level_feat import first_level_feat
from trick_fsl import trick_fsl


# Set some paths
output_folder = '/home/ozzy/Desktop/canine2/results'
path_to_mprage = '/home/ozzy/Desktop/canine2/T1'
template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/invivoTemplate.nii.gz'
binary_template = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/binaryTemplate.nii.gz'
resampled_template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz'
path_to_recon_fmris = '/home/ozzy/Desktop/canine2/Recon'
path_to_epi = '/home/ozzy/Desktop/canine2/EPI'
first_level_design_folder = '/home/ozzy/Desktop/canine2/design'
number_of_threads = 6

# Set some variables
total_readout_time_AP = 0.0217349 # total readout time for AP (can be found in nifti header)
total_readout_time_PA = 0.0217349 # total readout time for PA (can be found in nifti header)
centre_of_gravity = [95, 62, 87] # center of the T1 image. Doesn't have to be exact

# Create the output folder if it does not exist
if not os.path.exists(output_folder):
    os.system('mkdir %s' % output_folder)

####################### Structure prerocessing ################################
            
# Prepare the mprage images and save averaged mprages path
average_path, extracted_brain, flipped_extracted_brain = prepare_mprage(path_to_mprage, binary_template, centre_of_gravity, output_folder)

# Warp the averaged mprage and save the file path to a variable 
warp_results_folder = warp_to_invivo(extracted_brain, template_path, output_folder, number_of_threads, False)

# Warp the flipped and average mprage
warp_to_invivo(flipped_extracted_brain, template_path, output_folder, number_of_threads, True)

########################  EPI prerocessing ####################################

# Perform topup and save the path to corrected results 
top_up_folder, corrected_epi = topup(total_readout_time_AP, total_readout_time_PA, path_to_recon_fmris, path_to_epi, output_folder)

# Motion correction and time derivative calculation. Doing this with the topup
# results. Save motion covariate folder. Overwrites the original EPIs
moco_cov = moco(corrected_epi, top_up_folder, output_folder)

# Flip EPI images 
flipped_epi = flip_epi(corrected_epi, output_folder)

# Apply warps to the standard and flipped EPI images downsample to 2mm using 
# the downsampled image as the template.
standard_generic = os.path.join(warp_results_folder, 'dog_diff0GenericAffine.mat')
flipped_generic = os.path.join(warp_results_folder, 'flipped_dog_diff0GenericAffine.mat')
warped_epi = apply_warp(corrected_epi, resampled_template_path, output_folder, standard_generic, False)
flipped_warped_epi = apply_warp(flipped_epi, resampled_template_path, output_folder, flipped_generic, True)

# Average flipped and unflipped EPI images
final_epi = average_org_and_flipped(warped_epi, flipped_warped_epi, output_folder)

############################# FEAT ############################################

# Do the first level analyses
first_lvl_res = first_level_feat(path_to_epi, first_level_design_folder, resampled_template_path, moco_cov, output_folder)
    
# Trick FSL
trick_fsl(first_lvl_res)

