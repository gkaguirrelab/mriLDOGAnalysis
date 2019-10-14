import os

def prepare_mprage(path_to_mprage, output_folder):
    
    print('REGISTERING MPRAGE IMAGES')
    mprage_images = os.listdir(path_to_mprage)
    for i in mprage_images:
        call = "N4BiasFieldCorrection -d 3 -i %s -o %s -v"%(os.path.join(path_to_mprage, i),
                                                           os.path.join(path_to_mprage, i))
        os.system(call)
  
    # Register two MPRAGEs     
    average_path = os.path.join(output_folder, 'mp_average')
    if not os.path.exists(average_path):
        os.system('mkdir %s' % average_path)
    flirt_call = 'flirt -in %s -ref %s -out %s -omat %s -bins 256 -cost corratio ' \
                 '-searchrx -90 90 -searchry -90 90 ' \
                 '-searchrz -90 90 -dof 6 -interp trilinear' % (os.path.join(path_to_mprage, mprage_images[0]),
                                                                os.path.join(path_to_mprage, mprage_images[1]),
                                                                os.path.join(average_path, 'registered'),
                                                                os.path.join(average_path, 'registered'))
    os.system(flirt_call)
    
    # Average the registered MPRAGE with the target of that registration
    print('AVERAGING MPRAGE IMAGES')
    first_image = os.path.join(path_to_mprage, mprage_images[1])
    second_image = os.path.join(average_path, 'registered.nii.gz')
    average_call = 'AverageImages 3 %s 1 %s %s' % (os.path.join(average_path, 'averaged_mprages.nii.gz'),
                                                   first_image,
                                                   second_image)
    os.system(average_call)
    averaged_mprage = os.path.join(average_path, 'averaged_mprages.nii.gz')
   
    # Flip averaged mprage
    flipped_averaged_mprage = os.path.join(average_path, 'flipped_average.nii.gz')
    flip_call = 'fslswapdim %s x -y z %s' % (averaged_mprage, flipped_averaged_mprage)
    #flip_call = 'mri_convert --in_orientation LAS %s %s'%(averaged_mprage,flipped_averaged_mprage)  #This is freesurfer
    os.system(flip_call)

    return average_path
    return averaged_mprage
    return flipped_averaged_mprage