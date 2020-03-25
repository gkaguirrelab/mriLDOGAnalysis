import os
import pandas as pd
import numpy as np

def moco(epi_folder, top_up_folder, output_folder): 
    
    '''
    Description:
        This function does motion correction and calculates time derivatives of
        the output motion covariates
    Input:
        - epi_folder: Path to the folder containing the functional images
        - top_up_folder: Path to the folder containing the topup calculations
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output        
    '''
    
    # Motion Correction
    moco_cov = os.path.join(output_folder, 'moco_covariates')
    mc_to_this = os.path.join(top_up_folder, 'moco_target.nii.gz')
    if not os.path.exists(moco_cov):
        os.system('mkdir %s' % moco_cov)
    for i in os.listdir(epi_folder):
        mcflirt_call = 'FSLDIR=/usr/lib/fsl/5.0;. /etc/fsl/5.0/fsl.sh;PATH=${FSLDIR}:${PATH};export FSLDIR PATH;/usr/lib/fsl/5.0/mcflirt -in %s -o %s -reffile %s -dof 12 -plots' % (os.path.join(epi_folder, i),
                                                                                                                                                                                     os.path.join(epi_folder, i),
                                                                                                                                                                                     mc_to_this)
        os.system(mcflirt_call)

    os.system('mv %s/*.par %s/' % (epi_folder, moco_cov))
    
    # Motion derivatives
    for i in os.listdir(moco_cov):
        original_par = os.path.join(moco_cov, i)
        pd.set_option('display.precision', 8)
        data = pd.read_csv(original_par, sep='  ', header=None, engine='python')
        data_sqrted = data ** 2
        data_diffed = data.diff(periods=1, axis=0)
        data_diffed = data_diffed.fillna(0)
        data_diffed_sqrt = data_diffed ** 2 
        data_concatted = pd.concat([data, data_sqrted, data_diffed, data_diffed_sqrt], axis=1)
        np.savetxt(original_par, data_concatted, delimiter='  ')
        
    return (mc_to_this,moco_cov)