import os

def topup(total_readout_time_AP, total_readout_time_PA, path_to_recon_fmris, path_to_epi, output_folder):
     
    print('STARTING TOPUP')
    direction_vector_AP = '0 -1 0 %s\n' % str(total_readout_time_AP)
    direction_vector_PA = '0 1 0 %s' % str(total_readout_time_PA)
    acparam_file = os.path.join(path_to_recon_fmris, 'acqparams.txt')
    os.system('touch %s' % acparam_file)
    textfile = open(acparam_file, 'w')
    textfile.write(direction_vector_AP)
    textfile.write(direction_vector_PA)
    textfile.close()
    
    for i in os.listdir(path_to_recon_fmris):
        if 'AP' in i:
            print('found the AP single-rep fmri')
            ap_image = os.path.join(path_to_recon_fmris, i)
            print('Full path to the single-rep AP: %s' % ap_image)
        if 'PA' in i:
            print('found the PA single-rep fmri')
            pa_image = os.path.join(path_to_recon_fmris, i)
            print('Full path to the single-rep PA: %s' % pa_image)

    print('STARTING TOPUP')
    top_up_folder = os.path.join(output_folder, 'top_up')
    if not os.path.exists(top_up_folder):
        os.system('mkdir %s' % top_up_folder)
    os.system('fslmerge -a %s %s %s' % (os.path.join(top_up_folder, 'AP+PA'),
                                        ap_image,
                                        pa_image))
    
    os.system('topup --imain=%s --datain=%s '
              '--config=b02b0.cnf --out=%s --iout=%s --fout=%s' % (os.path.join(top_up_folder, 'AP+PA.nii.gz'),
                                                                   acparam_file,
                                                                   os.path.join(top_up_folder, 'topup_results'),
                                                                   os.path.join(top_up_folder, 'b0_unwarped'),
                                                                   os.path.join(top_up_folder, 'fieldmap_Hz')))

    AP_images_temporary = os.path.join(output_folder, 'APimages')
    PA_images_temporary = os.path.join(output_folder, 'PAimages')
    if not os.path.exists(AP_images_temporary):
        os.system('mkdir %s' % AP_images_temporary)
    if not os.path.exists(PA_images_temporary):
        os.system('mkdir %s' % PA_images_temporary)

    for i in os.listdir(path_to_epi):
        if 'AP' in i:
            os.system('cp %s %s' % (os.path.join(path_to_epi, i), os.path.join(AP_images_temporary, i)))
        elif 'PA' in i:
            os.system('cp %s %s' % (os.path.join(path_to_epi, i), os.path.join(PA_images_temporary, i)))
        else:
            raise ValueError('You did not rename and put AP or PA in one of your EPI images')
    
    os.system('applytopup --imain=%s --inindex=1 '
              '--method=jac --datain=%s --topup=%s --out=%s' % (os.path.join(path_to_recon_fmris, 'AP.nii.gz'),
                                                                acparam_file,
                                                                os.path.join(top_up_folder, 'topup_results'),
                                                                os.path.join(top_up_folder, 'register_to_this')))

    corrected_epi = os.path.join(output_folder, 'corrected_epi')
    if not os.path.exists(corrected_epi):
        os.system('mkdir %s' % corrected_epi)
    for i in os.listdir(AP_images_temporary):
        os.system('applytopup --imain=%s --inindex=1 '
                  '--method=jac --datain=%s --topup=%s --out=%s/corrected_%s' % (os.path.join(AP_images_temporary, i),
                                                                    acparam_file,
                                                                    os.path.join(top_up_folder, 'topup_results'),
                                                                    corrected_epi, i))
    for i in os.listdir(PA_images_temporary):
        os.system('applytopup --imain=%s --inindex=2 '
                  '--method=jac --datain=%s --topup=%s --out=%s/corrected_%s' % (os.path.join(PA_images_temporary, i),
                                                                    acparam_file,
                                                                    os.path.join(top_up_folder, 'topup_results'),
                                                                    corrected_epi, i))
    return (top_up_folder, corrected_epi)