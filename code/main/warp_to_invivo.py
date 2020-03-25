import os

def warp_to_invivo(mprage_image, template_path, output_folder, num_threads=4, convention=''): 
    
    '''
    Description:
        This function is a wrapper around ANTs SyN registration. Warps mprage 
        to template.
        
    Inputs:
        - mprage_image: Path to a single mprage image
        - template_path: Path to the template image
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output
        - num_threads: Number. How many threads to use. Default: 4
        - convention: Added in front of the output filename. Can be used when
        working on flipped images. Defult is empty = ''
    '''    
    # Warp to Canine Template (use 5 threads change -n flag in warp_call if you want more threads)
    print('WARPING THE AVERAGED MPRAGE TO INVIVO ATLAS')
    warp_results_folder = os.path.join(output_folder, 'reg_avgmprage2atlas')
    if not os.path.exists(warp_results_folder):
        os.system('mkdir %s' % warp_results_folder)
    
    warp_call = 'antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s -x %s/binaryTemplate.nii.gz -n %s' % (template_path,
                                                                                                    mprage_image,
                                                                                                    os.path.join(warp_results_folder, convention),
                                                                                                    template_path,
                                                                                                    str(num_threads))
    os.system(warp_call)
    warped_mprage = os.path.join(warp_results_folder, convention + 'Warped.nii.gz')
    generic_affine = os.path.join(warp_results_folder, convention + '0GenericAffine.mat')
    
    return (warp_results_folder, warped_mprage, generic_affine)