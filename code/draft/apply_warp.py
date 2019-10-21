import os 

def apply_warp(epi_folder, template_path, output_folder, path_to_generic_affine):

   # Warp EPI images to invivo template
    print('WARPING EPI IMAGES TO INVIVO TEMPLATE')
    warped_epi = os.path.join(output_folder, 'warped_epi')
    if not os.path.exists(warped_epi):
        os.system('mkdir %s' % warped_epi)
    for i in os.listdir(epi_folder):
        os.system('antsApplyTransforms --float --default-value 0 '
                  '--input %s --input-image-type 3 '
                  '--interpolation Linear --output %s/warped_%s '
                  '--reference-image %s '
                  '--transform [ %s, 0 ] '
                  '-v 1' % (os.path.join(epi_folder, i),
                            warped_epi, i,
                            template_path,
                            path_to_generic_affine))
    
        #os.system('antsApplyTransforms -d 4 -o %s/warped_%s -t %s/dog_diff4DCollapsedWarp.nii.gz -t %s/dog_diff1Warp.nii.gz -r %s/2mreplicated_invivo.nii.gz -i %s/%s'%(warped_epi,i,warp_results_folder,warp_results_folder,warp_results_folder,corrected_epi,i))
    
    return (warped_epi)