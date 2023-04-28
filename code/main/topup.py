import os

def topup(path_to_epi, total_readout_time_AP, total_readout_time_PA, path_to_recon_fmris, output_folder, fsl_path ='', ants_path=''):
    
    # This script calculates topup and applies it on the EPI images. The AP and
    # PA readout times should be used. This information can be found in the 
    # nifti header.
    
    # Image name 
    image_name = os.path.split(path_to_epi)[1][:-7]
    
    direction_vector_AP = '0 -1 0 %s\n' % str(total_readout_time_AP)
    direction_vector_PA = '0 1 0 %s' % str(total_readout_time_PA)
    acparam_file = os.path.join(path_to_recon_fmris, 'acqparams.txt')
    os.system('touch %s' % acparam_file)
    textfile = open(acparam_file, 'w')
    textfile.write(direction_vector_AP)
    textfile.write(direction_vector_PA)
    textfile.close()
    
    # Find the AP and PA images
    for i in os.listdir(path_to_recon_fmris):
        if i[-2:] == 'gz' or i[-6:] == 'gz':
            if '1' in os.popen('%s %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % (os.path.join(ants_path, 'PrintHeader'), os.path.join(path_to_recon_fmris,i))).read():
                ap_image = os.path.join(path_to_recon_fmris, i)
            if '0' in os.popen('%s %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % (os.path.join(ants_path, 'PrintHeader'), os.path.join(path_to_recon_fmris,i))).read():
                pa_image = os.path.join(path_to_recon_fmris, i)
    
    # If AP and PA images have more than a single TR, only get the first one.
    ap_image_loaded = nib.load(ap_image)
    ap_data = ap_image_loaded.get_fdata().copy()  
    if ap_data.ndim > 3:
        if ap_data[3].shape > 1:
            ap_data = ap_data[:,:,:,0]
            single_tr_ap = nib.Nifti1Image(ap_data, ap_image_loaded.affine, ap_image_loaded.header, ap_image_loaded.extra, ap_image_loaded.file_map)
            nib.save(single_tr_ap, ap_image)
    
    pa_image_loaded = nib.load(pa_image)
    pa_data = pa_image_loaded.get_fdata().copy()  
    if pa_data.ndim > 3:
        if pa_data[3].shape > 1:
            pa_data = pa_data[:,:,:,0]
            single_tr_pa = nib.Nifti1Image(pa_data, pa_image_loaded.affine, pa_image_loaded.header, pa_image_loaded.extra, pa_image_loaded.file_map)
            nib.save(single_tr_pa, pa_image)
    
    # Merge AP and PA singe-rep images into one for topup
    top_up_folder = os.path.join(output_folder, 'top_up')
    if not os.path.exists(top_up_folder):
        os.system('mkdir %s' % top_up_folder)
    os.system('%s -a %s %s %s' % (os.path.join(fsl_path, 'fslmerge'),
                                  os.path.join(top_up_folder, 'AP+PA'),
                                  ap_image,
                                  pa_image))
    
    # Calculate the field
    os.system('%s --imain=%s --datain=%s --config=b02b0.cnf --out=%s --iout=%s --fout=%s' % (os.path.join(fsl_path, 'topup'),
                                                                                              os.path.join(top_up_folder, 'AP+PA.nii.gz'),
                                                                                              acparam_file,
                                                                                              os.path.join(top_up_folder, 'topup_results'),
                                                                                              os.path.join(top_up_folder, 'b0_unwarped'),
                                                                                              os.path.join(top_up_folder, 'fieldmap_Hz')))

    # Apply correction to the EPI image(s)    
    corrected_epi_folder = os.path.join(output_folder, '1topup_corrected_epi')
    if not os.path.exists(corrected_epi_folder):
        os.system('mkdir %s' % corrected_epi_folder)

    if int(os.popen('%s %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % (os.path.join(ants_path, 'PrintHeader') ,path_to_epi)).read()) == 1:
        os.system('%s --imain=%s --inindex=1 --method=jac --datain=%s --topup=%s --out=%s/1topup_%s' % (os.path.join(fsl_path, 'applytopup'),
                                                                                                        path_to_epi,
                                                                                                        acparam_file,
                                                                                                        os.path.join(top_up_folder, 'topup_results'),
                                                                                                        corrected_epi_folder, 
                                                                                                        image_name))
    elif int(os.popen('%s %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % (os.path.join(ants_path, 'PrintHeader') ,path_to_epi)).read()) == 0:
        os.system('%s --imain=%s --inindex=2 --method=jac --datain=%s --topup=%s --out=%s/1topup_%s' % (os.path.join(fsl_path, 'applytopup'),
                                                                                                        path_to_epi,
                                                                                                        acparam_file,
                                                                                                        os.path.join(top_up_folder, 'topup_results'),
                                                                                                        corrected_epi_folder,
                                                                                                        image_name))
    else:
        raise ValueError('Your time series image is neither in AP nor in PA direction')
    
    corrected_epi = os.path.join(corrected_epi_folder, '1topup_' + image_name + '.nii.gz')
    
    # Create a target topuped image for the motion correction
    os.system('%s --imain=%s --inindex=1 --method=jac --datain=%s --topup=%s --out=%s' % (os.path.join(fsl_path, 'applytopup'),
                                                                                          ap_image,
                                                                                          acparam_file,
                                                                                          os.path.join(top_up_folder, 'topup_results'),
                                                                                          os.path.join(top_up_folder, 'AP_topup_corrected')))
    scout_topuped = os.path.join(top_up_folder, 'AP_topup_corrected.nii.gz')
    
    return (image_name, scout_topuped, corrected_epi)
