import os

def second_level_run(first_level_results, atlas_path, condition, condition_fsf, output_folder):

    print('PERFORMING HIGHER LEVEL ANALYSIS')
    
    secondlvl_output = os.path.join(output_folder, 'second_level_results')
    if not os.path.exists(secondlvl_output):
        os.system('mkdir %s' % secondlvl_output)
  
    if condition == 'x_plus_y':
        left_pul_right = os.path.join(secondlvl_output, 'left_plus_right_eye')
        if not os.path.exists(left_pul_right):
            os.system('mkdir %s' % left_pul_right)
        full_fmri_data_directory = ''
        full_higher_lvl_ev = ''
        full_group_member = ''
        indx = 0
        sorted_list = os.listdir(first_level_results)
        sorted_list.sort()
        for i in sorted_list:
            indx += 1 
            single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s" \n\n' % (str(indx),str(indx),os.path.join(first_level_results, i))
            single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) 1 \n\n'%(str(indx),str(indx))  # Different for right stuff
            single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
            full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
            full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
            full_group_member = full_group_member + single_line_for_group_member 
        
            main_replacements = {'GROUP_OUTPUT':left_pul_right, 'TOTAL_VOLUME':len(os.listdir(first_level_results)),
                                 'TOTAL_FIRST_LEVEL':len(os.listdir(first_level_results)), 'STANDARD_IMAGE':atlas_path,
                                 'FMRI_DATA_DIRECTORY':full_fmri_data_directory,
                                 'HIGH_LEVEL_EV':full_higher_lvl_ev,
                                 'GROUP_MEMBER':full_group_member} 
            with open('%s/main_template.fsf'%condition_fsf, 'r') as maininfile:
                with open('%s/group.fsf'%condition_fsf,'w') as mainoutfile:
                    for line in maininfile:
                        for src, target in main_replacements.items():                        
                            line = line.replace(src, str(target))
                        mainoutfile.write(line)
        
        os.system('feat %s' % os.path.join(condition_fsf,'group.fsf'))
    
    elif condition == 'x_minus_y':
        left_min_right = os.path.join(secondlvl_output, 'left_minus_right_eye')
        if not os.path.exists(left_min_right):
            os.system('mkdir %s' % left_min_right)
        full_fmri_data_directory = ''
        full_higher_lvl_ev = ''
        full_group_member = ''
        indx = 0
        sorted_list = os.listdir(first_level_results)
        sorted_list.sort()
        for i in sorted_list:
            if 'left' in i:
                indx += 1 
                single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s" \n\n' % (str(indx),str(indx),os.path.join(first_level_results, i))
                single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) 1 \n\n'%(str(indx),str(indx))  # Different for right stuff
                single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
                full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
                full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
                full_group_member = full_group_member + single_line_for_group_member 
            if 'right' in i:
                indx += 1 
                single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s" \n\n' % (str(indx),str(indx),os.path.join(first_level_results, i))
                single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) -1 \n\n'%(str(indx),str(indx))  # Different for right stuff
                single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
                full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
                full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
                full_group_member = full_group_member + single_line_for_group_member                       
            main_replacements = {'GROUP_OUTPUT':left_min_right, 'TOTAL_VOLUME':len(os.listdir(first_level_results)),
                                 'TOTAL_FIRST_LEVEL':len(os.listdir(first_level_results)), 'STANDARD_IMAGE':atlas_path,
                                 'FMRI_DATA_DIRECTORY':full_fmri_data_directory,
                                 'HIGH_LEVEL_EV':full_higher_lvl_ev,
                                 'GROUP_MEMBER':full_group_member} 
            with open('%s/main_template.fsf'%condition_fsf, 'r') as maininfile:
                with open('%s/group.fsf'%condition_fsf,'w') as mainoutfile:
                    for line in maininfile:
                        for src, target in main_replacements.items():                        
                            line = line.replace(src, str(target))
                        mainoutfile.write(line)
                        
        os.system('feat %s' % os.path.join(condition_fsf,'group.fsf'))

    right_min_left = os.path.join(secondlvl_output, 'right_minus_left_eye')
    if not os.path.exists(right_min_left):
        os.system('mkdir %s' % right_min_left)
    full_fmri_data_directory = ''
    full_higher_lvl_ev = ''
    full_group_member = ''
    indx = 0
    sorted_list = os.listdir(first_level_results)
    sorted_list.sort()
    for i in sorted_list:
        if 'left' in i:
            indx += 1 
            single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s" \n\n' % (str(indx),str(indx),os.path.join(first_level_results, i))
            single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) -1 \n\n'%(str(indx),str(indx))  # Different for right stuff
            single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
            full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
            full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
            full_group_member = full_group_member + single_line_for_group_member 
        if 'right' in i:
            indx += 1 
            single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s" \n\n' % (str(indx),str(indx),os.path.join(first_level_results, i))
            single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) 1 \n\n'%(str(indx),str(indx))  # Different for right stuff
            single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
            full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
            full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
            full_group_member = full_group_member + single_line_for_group_member                       
        main_replacements = {'GROUP_OUTPUT':right_min_left, 'TOTAL_VOLUME':len(os.listdir(first_level_results)),
                             'TOTAL_FIRST_LEVEL':len(os.listdir(first_level_results)), 'STANDARD_IMAGE':atlas_path,
                             'FMRI_DATA_DIRECTORY':full_fmri_data_directory,
                             'HIGH_LEVEL_EV':full_higher_lvl_ev,
                             'GROUP_MEMBER':full_group_member} 
        with open('%s/main_template.fsf'%condition_fsf, 'r') as maininfile:
            with open('%s/group.fsf'%condition_fsf,'w') as mainoutfile:
                for line in maininfile:
                    for src, target in main_replacements.items():                        
                        line = line.replace(src, str(target))
                    mainoutfile.write(line)
                    
    os.system('feat %s' % os.path.join(condition_fsf,'group.fsf'))