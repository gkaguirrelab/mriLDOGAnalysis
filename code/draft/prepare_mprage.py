import os

def prepare_mprage(path_to_mprage, binary_template, centre_of_gravity, output_folder):

    # Set paths 
    mprage_images = os.listdir(path_to_mprage)
    average_path = os.path.join(output_folder, 'mp_average')
    first_mprage = mprage_images[0]
    second_mprage = mprage_images[1]
    
    # Biascorrection 
    for i in mprage_images:
        call = "N4BiasFieldCorrection -d 3 -i %s -o %s -v" % (os.path.join(path_to_mprage, i),
                                                              os.path.join(path_to_mprage, i))
        os.system(call)
    
    # Register two MPRAGEs        
    print('REGISTERING MPRAGE IMAGES')    
    if not os.path.exists(average_path):
        os.system('mkdir %s' % average_path)
    flirt_call = 'flirt -in %s -ref %s -out %s -omat %s -bins 256 -cost corratio ' \
                 '-searchrx -90 90 -searchry -90 90 ' \
                 '-searchrz -90 90 -dof 6 -interp trilinear' % (os.path.join(path_to_mprage, first_mprage),
                                                                os.path.join(path_to_mprage, second_mprage),
                                                                os.path.join(average_path, 'registered'),
                                                                os.path.join(average_path, 'registered'))
    os.system(flirt_call)
    
    # Average the registered MPRAGE with the target of that registration
    print('AVERAGING MPRAGE IMAGES')
    registered_image = os.path.join(average_path, 'registered.nii.gz')
    average_call = 'AverageImages 3 %s 1 %s %s' % (os.path.join(average_path, 'averaged_mprages.nii.gz'),
                                                   os.path.join(path_to_mprage, second_mprage),
                                                   registered_image)
    os.system(average_call)
    
    averaged_mprage = os.path.join(average_path, 'averaged_mprages.nii.gz')
   
    # Brain extraction
    print('PERFORMING A BRAIN EXTRACTION WITH THE SPECIFIED VOXELS')
    extracted_mprage = os.path.join(average_path, 'brain_averaged_mprages.nii.gz')
    extracted_mask = os.path.join(average_path, 'brain_averaged_mprages_mask.nii.gz')
    call = 'bet %s %s -f 0.1 -c %s %s %s -m' % (averaged_mprage, extracted_mprage,
                                         centre_of_gravity[0],
                                         centre_of_gravity[1], 
                                         centre_of_gravity[2])
    os.system(call)
    
    print('PERFORMING SEGMENTATION FOR THE BRAIN EXTRACTION')
    
    call2 = 'brainExtractionSegmentation.pl --input %s --initial-brain-mask %s --bias-correct 0 --output-root %s' % (averaged_mprage,
                                                                                                                     extracted_mask,
                                                                                                                     os.path.join(average_path, 'final')) 
    os.system(call2)
    extracted_brain = os.path.join(average_path, 'finalExtractedBrain.nii.gz')
    
    # Flip averaged skull stripped mprage
    print('FLIPPING THE IMAGE')
    flipped_extracted_brain = os.path.join(average_path, 'flipped_finalExtractedBrain.nii.gz')
    flip_call = 'fslswapdim %s x -y z %s' % (extracted_mprage, flipped_extracted_brain)
    #flip_call = 'mri_convert --in_orientation LAS %s %s'%(averaged_mprage,flipped_averaged_mprage)  #This is freesurfer
    os.system(flip_call)
    
    return (average_path,extracted_brain,flipped_extracted_brain)

