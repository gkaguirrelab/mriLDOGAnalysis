import os
import pandas as pd
import numpy as np

def moco(epi_folder, top_up_folder, output_folder): 
    
    # Motion Correction
    print('STARTING MOTION CORRECTION')
    moco_cov = os.path.join(output_folder, 'moco_covariates')
    mc_to_this = os.path.join(top_up_folder, 'register_to_this.nii.gz')
    if not os.path.exists(moco_cov):
        os.system('mkdir %s' % moco_cov)
    for i in os.listdir(epi_folder):
        mcflirt_call = 'mcflirt -in %s -o %s -reffile %s -dof 12 -plots' % (os.path.join(epi_folder, i),
                                                                            os.path.join(epi_folder, i),
                                                                            mc_to_this)
        print(mcflirt_call)
        os.system(mcflirt_call)
    os.system('mv %s/*.par %s/' % (epi_folder, moco_cov))
    
    # Motion derivatives
    for i in os.listdir(moco_cov):
        original_par = os.path.join(moco_cov, i)
        print(original_par)
        pd.set_option('display.precision', 8)
        data = pd.read_csv(original_par, sep='  ', header=None, engine='python')
        data_sqrted = data ** 2
        data_diffed = data.diff(periods=1, axis=0)
        data_diffed = data_diffed.fillna(0)
        data_diffed_sqrt = data_diffed ** 2 
        data_concatted = pd.concat([data, data_sqrted, data_diffed, data_diffed_sqrt], axis=1)
        np.savetxt(original_par, data_concatted, delimiter='  ')
        
        return (moco_cov)
        