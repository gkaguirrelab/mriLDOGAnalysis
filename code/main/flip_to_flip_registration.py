import nibabel
import nibabel.processing
import os 

def flip_to_flip_registration(flipped_epi_folder, flipped_extracted_mprage, output_path):
    
    # If the EPI and MPRAGE images do not lie on top of each other after the 
    # flip this function can be used to do an extra rigid transformation.
    
    # Get a single volume EPI sample
    misc = os.path.join(output_path, 'Misc')
    if not os.path.exists(misc):
        os.system('mkdir %s' % misc)
    single_epi = os.path.join(misc, 'single_epi')
    
    os.system('fslroi %s %s 0 1' % (os.listdir(flipped_epi_folder[0]), single_epi))
    
    epi = nibabel.load(single_epi)
    
    # Get the resolution of the epi
    header = epi.header
    res = header.get_zooms()   
    voxel_size = [res[0], res[1], res[2]]
    
    # Calculate linear registration between EPI and Mprage 
    os.system('antsRegistrationSyN.sh -f %s -m %s -o %s -t r -n 4' % (flipped_extracted_mprage,
                                                                      single_epi + '.nii.gz',
                                                                      os.path.join(misc, 'flipped_epi_to_flipped_mprage')))
    
    # Downsample mprage to EPI resolution
    loaded_rage = nibabel.load(flipped_extracted_mprage)
    resampled_img = nibabel.processing.resample_to_output(loaded_rage, voxel_size)  
    lowres_rage = os.path.join(misc, 'lowresmprage.nii.gz')
    nibabel.save(resampled_img, lowres_rage)
    
    # Apply registration to EPI using low res mprage as the target image so no 
    # upsampling occurs after the warp
    for i in os.listdir(flipped_epi_folder):
        os.system('antsApplyTransforms --float --default-value 0 '
                  '--input %s --input-image-type 3 '
                  '--interpolation Linear --output %s '
                  '--reference-image %s '
                  '--transform [ %s, 0 ] '
                  '-v 1' % (os.path.join(flipped_epi_folder, i),
                            os.path.join(flipped_epi_folder, i), 
                            lowres_rage,
                            os.path.join(misc, 'flipped_epi_to_flipped_mprage0GenericAffine.mat')))