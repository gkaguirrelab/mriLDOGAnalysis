import os 

def trick_fsl(first_lvl_results_folder):
    
    '''
    Description:
        This function loops through the first level analysis results and deletes
        and replaces some files so that FSL will not do it's on registration once
        the data is fed through the second level analysis
    
    Inputs:
        - first_lvl_results_folder: Path to the first level FSL analysis folder 
    '''
    
    print('TRICKING FSL SO NO REGISTRATION TAKES PLACE')
    
    for folder in os.listdir(first_lvl_results_folder):
        os.system('rm -r %s/reg/*mat' % os.path.join(first_lvl_results_folder, folder))
        os.system('rm -r %s/reg/standard.nii.gz' % os.path.join(first_lvl_results_folder, folder))
        os.system('cp $FSLDIR/etc/flirtsch/ident.mat %s/reg/example_func2standard.mat' % os.path.join(first_lvl_results_folder, folder))
        os.system('cp %s/mean_func.nii.gz %s/reg/standard.nii.gz' % (os.path.join(first_lvl_results_folder, folder), os.path.join(first_lvl_results_folder, folder)))
        