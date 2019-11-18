import os 

def apply_warp(epi_folder, template_path, output_folder, path_to_generic_affine, flipped=False):
    
    # This function applies the pre-calculated warps using the GenericAffine.mat
    
    # Warp EPI images to invivo template
    print('WARPING EPI IMAGES TO INVIVO TEMPLATE')
    if flipped == False:
        warped_epi = os.path.join(output_folder, 'warped_epi')
        conv = 'warped'
    else:
        warped_epi = os.path.join(output_folder, 'flipped_warped_epi')
        conv = 'flipped_warped'      
    if not os.path.exists(warped_epi):
        os.system('mkdir %s' % warped_epi)
        
    for i in os.listdir(epi_folder):
        os.system('antsApplyTransforms --float --default-value 0 '
                  '--input %s --input-image-type 3 '
                  '--interpolation Linear --output %s/%s_%s '
                  '--reference-image %s '
                  '--transform [ %s, 0 ] '
                  '-v 1' % (os.path.join(epi_folder, i),
                            warped_epi, conv, i,
                            template_path,
                            path_to_generic_affine))
              
    return (warped_epi)