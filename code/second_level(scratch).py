import os

def second_level_run(first_level_results, template_path, left_pls_right_folder, left_min_right_folder, right_min_left_folder, output_folder):

    secondlvl_output = os.path.join(output_folder, 'second_level_results')
    if not os.path.exists(secondlvl_output):
        os.system('mkdir %s' % secondlvl_output)

    left_paths = []
    right_paths = []        
    
    for i in os.listdir(first_level_results):
        if 'left' in i:
            left_paths.append(os.path.join(first_level_results, i))
        if 'right' in i:
            right_paths.append(os.path.join(first_level_results, i))
  
    left_paths.sort()
    right_paths.sort()
    
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
    
        main_replacements = {'GROUP_OUTPUT':secondlvl_output, 'TOTAL_VOLUME':len(os.listdir(first_level_results)),
                             'TOTAL_FIRST_LEVEL':len(os.listdir(first_level_results)), 'STANDARD_IMAGE':template_path,
                             'FMRI_DATA_DIRECTORY':full_fmri_data_directory,
                             'HIGH_LEVEL_EV':full_higher_lvl_ev,
                             'GROUP_MEMBER':full_group_member} 
        with open('%s/main_template.fsf'%left_pls_right_folder, 'r') as maininfile:
            with open('%s/group.fsf'%left_pls_right_folder,'w') as mainoutfile:
                for line in maininfile:
                    for src, target in main_replacements.items():                        
                        line = line.replace(src, str(target))
                    mainoutfile.write(line)

#print('PERFORMING HIGHER LEVEL ANALYSIS')
#if len(os.listdir(first_lvl_res)) != len(os.listdir(final_epi)):
#    raise ValueError ('The amount of the first level results are larger than the amount of the original EPI images. Group analysis failed')
#secondlvl_output = os.path.join(new_output_folder, 'second_level_results')

#full_fmri_data_directory = ''
#full_higher_lvl_ev = ''
#full_group_member = ''    
#for i in rangeofval:
#    indx = i + 1 
#    whichepi = os.listdir(first_lvl_res)
#    whichepi.sort()
#    single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) '%s/%s' \n\n'%(str(indx),str(indx),first_lvl_res,whichepi[i]))
#    single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) 1 \n\n'%(str(indx),str(indx))
#    single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
#    full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
#    full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
#    full_group_member = full_group_member + single_line_for_group_member  
#main_replacements = {'GROUP_OUTPUT':secondlvl_output, 'TOTAL_VOLUME':lengthFirstlvlstr,
#                'TOTAL_FIRST_LEVEL':lengthFirstlvlstr, 'STANDARD_IMAGE':template_path,
#                'FMRI_DATA_DIRECTORY':full_fmri_data_directory,
#                'HIGH_LEVEL_EV':full_higher_lvl_ev,
#                'GROUP_MEMBER':full_group_member} 
#with open('%s/main_template.fsf'%path_to_secondlvl_design_folder, 'r') as maininfile:
#    with open('%s/group.fsf'%path_to_secondlvl_design_folder,'w') as mainoutfile:
#        for line in maininfile:
#            for src, target in main_replacements.iteritems():
#                line = line.replace(src, target)
#            mainoutfile.write(line)
#
#col_of_ones = '1\n' * lengthFirstlvl
#grp_replacements = {'NUM_OF_EPI':lengthFirstlvlstr,
#                    'COL_OF_ONE_FOR_EACH_EPI':col_of_ones}
#with open('%s/grp_template.grp'%path_to_secondlvl_design_folder, 'r') as grpinfile:
#    with open('%s/group.grp'%path_to_secondlvl_design_folder,'w') as grpoutfile:
#        for line in grpinfile:
#            for src, target in grp_replacements.iteritems():
#                line = line.replace(src, target)
#            grpoutfile.write(line)    
#            
#col_of_sci_ones = '1.000000e+00\n' * lengthFirstlvl
#mat_replacements = {'NUM_OF_EPI_TWO':lengthFirstlvlstr,
#                    'COL_OF_SCI_ONES':col_of_sci_ones}
#with open('%s/mat_template.mat'%path_to_secondlvl_design_folder, 'r') as matinfile:
#    with open('%s/group.mat'%path_to_secondlvl_design_folder,'w') as matoutfile:
#        for line in matinfile:
#            for src, target in mat_replacements.iteritems():
#                line = line.replace(src, target)
#            matoutfile.write(line)       
#
#os.system('feat %s'%path_to_secondlvl_design_folder+'/group.fsf')
  