import os

def warp_to_invivo(mprage_image, template_path, output_folder, num_threads, flipped=False): 
    
    if flipped == False:
        convention = 'dog_diff'
    else:
        convention = 'flipped_dog_diff'
        
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
    
    return (warp_results_folder)