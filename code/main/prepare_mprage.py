import os

def prepare_mprage(path_to_mprage, centre_of_gravity, extraction_threshold, output_path):
    
    '''
    Description: 
        This script prepares the MPRAGE image(s) for the analysis. Pipeline:  
        1 - Bias correcting each MPRAGE images
        2 - Registering MPRAGES if there is more than one
        3 - Averaging the registered and target MPRAGE if there is more than one
        4 - Skull stripping the MPRAGE
        5 - x-y flipping the skull stripped MPRAGE for making pseudohemisphere
    Inputs:
        - path_to_mprage: Path to a folder containing one or more T1 images
        - centre_of_gravity: Is a list of coordinates of the middle (gravity) 
        of the brain image. Example: [95,68,102]
        - extraction_threshold: Brain extraction threshold. 0.5 is a good
        value for human brain extraction
        - output_path: Output path. Script creates more folders in this location
        and organizes the output.
    '''
    
    # Find MPRAGE images
    mprage_images = os.listdir(path_to_mprage)
    
    # Biascorrection 
    for i in mprage_images:
        call = "N4BiasFieldCorrection -d 3 -i %s -o %s -v" % (os.path.join(path_to_mprage, i),
                                                              os.path.join(path_to_mprage, i))
        os.system(call)
    
    # Register MPRAGEs if there are two of them 
    preprocessed_mprage_folder = os.path.join(output_path, 'preprocessed_mprage')
    if not os.path.exists(preprocessed_mprage_folder):
        os.system('mkdir %s' % preprocessed_mprage_folder)
        
    if len(mprage_images) > 1: 
        first_mprage = mprage_images[0]
        second_mprage = mprage_images[1]
        print('REGISTERING MPRAGE IMAGES')    
        
        register_call = 'antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s -t r -n 6' % (os.path.join(path_to_mprage, second_mprage),
                                                                                     os.path.join(path_to_mprage, first_mprage),
                                                                                     os.path.join(preprocessed_mprage_folder, 'registered'))
        os.system(register_call)
        registered_image = os.path.join(preprocessed_mprage_folder, 'registeredWarped.nii.gz')
         
        # Average the registered MPRAGE with the target
        print('AVERAGING MPRAGE IMAGES')
        average_call = 'AverageImages 3 %s 1 %s %s' % (os.path.join(preprocessed_mprage_folder, 'averaged_mprages.nii.gz'),
                                                       os.path.join(path_to_mprage, second_mprage),
                                                       registered_image)
        os.system(average_call)
        averaged_mprage = os.path.join(preprocessed_mprage_folder, 'averaged_mprages.nii.gz')
       
        # Brain extraction mask (created by fsl BET)
        print('PERFORMING A BRAIN EXTRACTION')
        extracted_mprage = os.path.join(preprocessed_mprage_folder, 'brain_averaged_mprages.nii.gz')
        extracted_mask = os.path.join(preprocessed_mprage_folder, 'brain_averaged_mprages_mask.nii.gz')
        call = 'bet %s %s -f %s -c %s %s %s -m' % (averaged_mprage, extracted_mprage,
                                                    extraction_threshold,
                                                    centre_of_gravity[0],
                                                    centre_of_gravity[1], 
                                                    centre_of_gravity[2])
        os.system(call)
    
    else:
        averaged_mprage = os.path.join(mprage_images[0]) 
        
    # Brain extraction segmentation (altAnts)
    print('PERFORMING SEGMENTATION FOR THE BRAIN EXTRACTION')    
    call2 = 'brainExtractionSegmentation.pl --input %s --initial-brain-mask %s --bias-correct 0 --output-root %s' % (averaged_mprage,
                                                                                                                     extracted_mask,
                                                                                                                     os.path.join(preprocessed_mprage_folder, 'final')) 
    os.system(call2)
    extracted_brain = os.path.join(preprocessed_mprage_folder, 'finalExtractedBrain.nii.gz')
    
    # Flip the averaged and skull stripped mprage
    print('FLIPPING THE IMAGE')
    flipped_extracted_brain = os.path.join(preprocessed_mprage_folder, 'flipped_finalExtractedBrain.nii.gz')
    flip_call = 'fslswapdim %s x -y z %s' % (extracted_mprage, flipped_extracted_brain)
    os.system(flip_call)
    
    return (preprocessed_mprage_folder, averaged_mprage, extracted_brain, flipped_extracted_brain)

