import os 

def trick_fsl(first_lvl_results_folder):
    
    # Delete all mat files in each first-level, copy some identity matrices and
    # mean functions so the registration and interpolation will not be effective. 
    # Note: This code is still a part of the laop above but placed under a 
    # different comment block since it's an important part of the analysis.
    print('TRICKING FSL SO NO REGISTRATION TAKES PLACE')
    
    for folder in os.listdir(first_lvl_results_folder):
        os.system('rm -r %s/reg/*mat' % os.path.join(first_lvl_results_folder, folder))
        os.system('rm -r %s/reg/standard.nii.gz' % os.path.join(first_lvl_results_folder, folder))
        os.system('cp $FSLDIR/etc/flirtsch/ident.mat %s/reg/example_func2standard.mat' % os.path.join(first_lvl_results_folder, folder))
        os.system('cp %s/mean_func.nii.gz %s/reg/standard.nii.gz' % (os.path.join(first_lvl_results_folder, folder), os.path.join(first_lvl_results_folder, folder)))
        