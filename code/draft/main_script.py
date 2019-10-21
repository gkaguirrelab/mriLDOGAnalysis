import os 
import pandas as pd 
from prepare_mprage import prepare_mprage
from warp_to_invivo import warp_to_invivo
from topup import topup
from moco import moco
from apply_warp import apply_warp
from flip_epi import flip_epi


# Set some paths
output_folder = '/home/ozzy/Desktop/canine4/results'
path_to_mprage = '/home/ozzy/Desktop/canine4/T1'
template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/invivoTemplate.nii.gz'
binary_template = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/binaryTemplate.nii.gz'
resampled_template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz'
path_to_recon_fmris = '/home/ozzy/Desktop/canine4/Recon'
path_to_epi = '/home/ozzy/Desktop/canine4/EPI'
total_readout_time_AP = 0.0217349
total_readout_time_PA = 0.0217349
centre_of_gravity = [94, 41, 92]

# Create the output folder if it does not exist
if not os.path.exists(output_folder):
    os.system('mkdir %s' % output_folder)

####################### Structure processing ################################## 
            
# Prepare the mprage images and save averaged mprages path
average_path, averaged_mprage, flipped_averaged_mprage, extracted_mprage = prepare_mprage(path_to_mprage, binary_template, centre_of_gravity, output_folder)

# Warp the averaged mprage and save the file path to a variable 
warp_results_folder = warp_to_invivo(averaged_mprage, template_path, output_folder, False )

# Warp the flipped and average mprage
warp_to_invivo(flipped_averaged_mprage, template_path, output_folder, True)

########################  EPI Processing ######################################

# Perform topup and save the path to corrected results 
top_up_folder, corrected_epi = topup(total_readout_time_AP, total_readout_time_PA, path_to_recon_fmris, path_to_epi, output_folder)

# Motion correction and time derivative calculation. Doing this with the topup
# results. Save motion covariate folder. Overwrites the original EPIs
moco_cov = moco(corrected_epi, top_up_folder, output_folder)

# Flip EPI images 
flipped_epi = flip_epi(corrected_epi, output_folder)

# Apply warps to the standard and flipped EPI images
standard_generic = os.path.join(warp_results_folder, 'dog_diff0GenericAffine.mat')
flipped_generic = os.path.join(warp_results_folder, 'flipped_dog_diff0GenericAffine.mat')
warped_epi = apply_warp(corrected_epi, resampled_template_path, output_folder, standard_generic)
apply_warp(flipped_epi, resampled_template_path, output_folder, flipped_generic)


