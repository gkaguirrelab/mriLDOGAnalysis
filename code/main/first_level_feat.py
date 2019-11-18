import os 

def first_level_feat(path_to_epi, first_level_design_folder, template_path, moco_cov, output_folder):
    
    # This function automates the FEAT first level analysis. Requires a design
    # template
    
    print('PERFORMING fMRI ANALYSIS: CHECK BROWSER REPORTS FOR DETAILS')
          
    first_lvl_res = os.path.join(output_folder, 'first_level_results')
    if not os.path.exists(first_lvl_res):
        os.system('mkdir %s' % first_lvl_res)
            
    evonepath = os.path.join(first_level_design_folder, 'off')
    
    for i in os.listdir(path_to_epi):             
        if i[-3:] == '.gz':
            epi_output_folder = os.path.join(output_folder, 'first_level_results', i[:-7])
        else:
            epi_output_folder = os.path.join(output_folder, 'first_level_results', i[:-4])
            
        epifullpath = os.path.join(path_to_epi, i)
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