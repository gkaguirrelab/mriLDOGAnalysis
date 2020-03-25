import os

def topup(path_to_recon_fmris, path_to_epis, total_readout_time_AP, total_readout_time_PA, output_folder):
    
    '''
    Desription:
        Calculates topup from two images in AP and PA directions and applies
        that topup to a set of functional images
        
    Inputs:
        - path_to_recon_fmris: Path to a folder containing one single volume AP
        and one single volume PA images
        - path_to_epis: Path to a folder that contains the epi images
        - total_readout_time_AP: total readout for AP images. Can be found in
        nifti headers
        - total_readout_time_PA: total readout for AP images. Can be found in
        nifti headers
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output
    '''
    
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
            if '1' in os.popen('/usr/lib/ants/PrintHeader %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % os.path.join(path_to_recon_fmris,i)).read():
                ap_image = os.path.join(path_to_recon_fmris, i)
            if '0' in os.popen('/usr/lib/ants/PrintHeader %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % os.path.join(path_to_recon_fmris,i)).read():
                pa_image = os.path.join(path_to_recon_fmris, i)

    # Merge AP and PA singe-rep images into one for topup
    top_up_folder = os.path.join(output_folder, 'top_up')
    if not os.path.exists(top_up_folder):
        os.system('mkdir %s' % top_up_folder)
    os.system('FSLDIR=/usr/lib/fsl/5.0;. /etc/fsl/5.0/fsl.sh;PATH=${FSLDIR}:${PATH};export FSLDIR PATH;/usr/lib/fsl/5.0/fslmerge -a %s %s %s' % (os.path.join(top_up_folder, 'AP+PA'),
                                                                                                                                                 ap_image,
                                                                                                                                                 pa_image))
    
    # Calculate the field
    os.system('FSLDIR=/usr/lib/fsl/5.0;. /etc/fsl/5.0/fsl.sh;PATH=${FSLDIR}:${PATH};export FSLDIR PATH;/usr/lib/fsl/5.0/topup --imain=%s --datain=%s '
              '--config=b02b0.cnf --out=%s --iout=%s --fout=%s' % (os.path.join(top_up_folder, 'AP+PA.nii.gz'),
                                                                   acparam_file,
                                                                   os.path.join(top_up_folder, 'topup_results'),
                                                                   os.path.join(top_up_folder, 'b0_unwarped'),
                                                                   os.path.join(top_up_folder, 'fieldmap_Hz')))

    # Apply correction to the EPI image(s)    
    corrected_epi = os.path.join(output_folder, 'topup_corrected_epi')
    if not os.path.exists(corrected_epi):
        os.system('mkdir %s' % corrected_epi)

    for i in os.listdir(path_to_epis):
        if int(os.popen('/usr/lib/ants/PrintHeader %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % os.path.join(path_to_epis, i)).read()) == 1:
            os.system('FSLDIR=/usr/lib/fsl/5.0;. /etc/fsl/5.0/fsl.sh;PATH=${FSLDIR}:${PATH};export FSLDIR PATH;/usr/lib/fsl/5.0/applytopup --imain=%s --inindex=1 --method=jac --datain=%s --topup=%s --out=%s/1topup_%s' % (os.path.join(path_to_epis, i),
                                                                                                                                                                                                                                                acparam_file,
                                                                                                                                                                                                                                                os.path.join(top_up_folder, 'topup_results'),
                                                                                                                                                                                                                                                corrected_epi, 
                                                                                                                                                                                                                                                i))
        elif int(os.popen('/usr/lib/ants/PrintHeader %s | grep descrip | grep phase |  cut -d \';\' -f 3 | cut -d \'=\' -f 2' % os.path.join(path_to_epis, i)).read()) == 0:
            os.system('FFSLDIR=/usr/lib/fsl/5.0;. /etc/fsl/5.0/fsl.sh;PATH=${FSLDIR}:${PATH};export FSLDIR PATH;/usr/lib/fsl/5.0/applytopup --imain=%s --inindex=2 --method=jac --datain=%s --topup=%s --out=%s/1topup_%s' % (os.path.join(path_to_epis, i),
                                                                                                                                                                                                                                                acparam_file,
                                                                                                                                                                                                                                                os.path.join(top_up_folder, 'topup_results'),
                                                                                                                                                                                                                                                corrected_epi,
                                                                                                                                                                                                                                                i))
        else:
            raise ValueError('Your time series image is neither in AP nor in PA direction')
    
    # Create a target topuped image for the motion correction
    os.system('FSLDIR=/usr/lib/fsl/5.0;. /etc/fsl/5.0/fsl.sh;PATH=${FSLDIR}:${PATH};export FSLDIR PATH;/usr/lib/fsl/5.0/applytopup --imain=%s --inindex=1 '
              '--method=jac --datain=%s --topup=%s --out=%s' % (ap_image,
                                                                acparam_file,
                                                                os.path.join(top_up_folder, 'topup_results'),
                                                                os.path.join(top_up_folder, 'moco_target')))
    return (top_up_folder, corrected_epi)