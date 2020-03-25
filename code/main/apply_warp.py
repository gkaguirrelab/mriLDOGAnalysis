import os 

def apply_warp(epi_folder, template_path, output_folder, path_to_generic_affine, path_to_warp, path_to_generic_affine2='NA', path_to_warp2='NA', flipped=False):

    ''' 
    Description:
        Applies warps that are calculated with ANTs to images
    
    Inputs:
        - epi_folder = Folder containing the EPI images
        - template_path = Path to target atlas
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output   
        - path_to_genetic_affine = Path to ANTs File0GenericAffine.mat file 
        - path_to_warp = Path to ANTs File1Warp.gz file
        - path_to_genetic_affine2 = Optional 2nd affine file if combining 2 warps
        - path_to_warp2 = Optional 2nd warp file if combining 2 warps
        - flipped = This flag adds a "flipped" label if used. Used if working on
        making pseudohemisphere images that are left-right flipped
    '''
        
    # Warp EPI images to invivo template
    if flipped == False:
        warped_epi = os.path.join(output_folder, 'preprocessed_epi')
        conv = 'preprocessed'
    else:
        warped_epi = os.path.join(output_folder, 'flipped_preprocessed_epi')
        conv = 'flipped_preprocessed'      
    if not os.path.exists(warped_epi):
        os.system('mkdir %s' % warped_epi)
    
    if path_to_warp2 == 'NA' and path_to_generic_affine2 == 'NA':
        for i in os.listdir(epi_folder):
            os.system('/usr/lib/ants/antsApplyTransforms --float --default-value 0 '
                      '--input %s --input-image-type 3 '
                      '--interpolation Linear --output %s/%s_%s '
                      '--reference-image %s '
                      '--transform %s --transform %s '
                      '-v 1' % (os.path.join(epi_folder, i),
                                warped_epi, conv, i[6:],
                                template_path,
                                path_to_warp,
                                path_to_generic_affine))
   
    elif path_to_warp2 != 'NA' and path_to_generic_affine2 != 'NA':
        for i in os.listdir(epi_folder):
            os.system('/usr/lib/ants/antsApplyTransforms --float --default-value 0 '
                      '--input %s --input-image-type 3 '
                      '--interpolation Linear --output %s/%s_%s '
                      '--reference-image %s '
                      '--transform %s --transform %s --transform %s --transform %s '
                      '-v 1' % (os.path.join(epi_folder, i),
                                warped_epi, conv, i[6:],
                                template_path,
                                path_to_warp2,
                                path_to_generic_affine2,
                                path_to_warp,
                                path_to_generic_affine))         
    else:
        print('There is smoething wrong with the function')
        
    return (warped_epi)