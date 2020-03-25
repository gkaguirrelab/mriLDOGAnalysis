import os 

def first_level_feat(path_to_epis, first_level_design_folder, template_path, moco_cov, output_folder):
    
    '''
    Description:
        Does the first-level FEAT analysis. Only works for LDOG project
    
    Inputs:
        - path_to_epis: Path to the folder containing epi images
        - first_level_design_folder: A folder containing the .fsf template. 
        The template has to be called design_template.fsf
        - template_path: Path to the template image
        - moco_cov: Path to a folder containing the motion correction files
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output   
    '''

    print('PERFORMING fMRI ANALYSIS: CHECK BROWSER REPORTS FOR DETAILS')
          
    first_lvl_res = os.path.join(output_folder, 'first_level_results')
    if not os.path.exists(first_lvl_res):
        os.system('mkdir %s' % first_lvl_res)
            
    evonepath = os.path.join(first_level_design_folder, 'off')
    
    for i in os.listdir(path_to_epis):             
        if i[-3:] == '.gz':
            epi_output_folder = os.path.join(output_folder, 'first_level_results', i[:-7])
        else:
            epi_output_folder = os.path.join(output_folder, 'first_level_results', i[:-4])
            
        epifullpath = os.path.join(path_to_epis, i)
        print(epifullpath)
        ntime = os.popen('fslnvols %s' % epifullpath).read().rstrip()
        motion_epi = '%s.par' % os.path.join(moco_cov, i[13:])
        things_to_replace = {'SUBJECT_OUTPUT': epi_output_folder, 'NTPTS': ntime,                             
                             'STANDARD_IMAGE': template_path, 'SUBJECT_EPI': epifullpath,
                             'SUBJECTEV1': evonepath,
                             'CONFOUND_FOR_MOTION_EPI': motion_epi}
        
        with open('%s' % os.path.join(first_level_design_folder, 'design_template.fsf'), 'r') as infile:
            with open('%s' % os.path.join(first_level_design_folder, 'design.fsf'), 'w') as outfile:
                for line in infile:
                    for src, target in things_to_replace.items():
                        line = line.replace(src, target)
                    outfile.write(line)
        os.system('feat %s' % os.path.join(first_level_design_folder, 'design.fsf'))
        
    return (first_lvl_res)