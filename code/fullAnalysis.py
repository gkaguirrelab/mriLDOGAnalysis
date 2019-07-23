#!/usr/bin/python

import os 
import sys

## path_to_mprage	     : Path to folder containing MPRAGE images
## path_to_epi   	     : path to folder containing EPI images
## path_to_atlas 	     : Path to folder containing canine atlas
## path_to_design_folder : Path to folder containing design.fsf file which is 
##                         the template specifying GLM and oher parameters for
##                         FSL's FEAT analysis
## path_to_ants_scripts  : antsResitrationSyN is a custom script prepared for 
##                         registration. Specify a path to ants scripts folder 
##                         so python can use it

# WARNINGS:
# Specify Folders not individual files
# Don't put a slash at the end of your path but put one at the beginning (e.g. /home/Desktop/files)

# Example:
# preprocAndFirstLvl('/home/ozzy/Desktop/Canine/T1', '/home/ozzy/Desktop/Canine/EPI', '/home/ozzy/Desktop/Canine/Atlas', '/home/ozzy/Desktop/Canine/design', '/home/ozzy/Desktop/Canine/results', '/home/ozzy/bin/ants/bin') 


def onlyPreprocAndFirstLvl(path_to_mprage, path_to_epi, path_to_inVivo_atlas, path_to_design_folder, path_to_secondlvl_design_folder, output_folder, path_to_ants_scripts):
 
#    ############################ PREPROCESSING ################################
#    
#    # Create a results/processing output folder if doesn't already exist (add)
#    if not os.path.exists(output_folder):
#        os.system("mkdir %s"%output_folder)
#    
#    # Register two MPRAGEs
#    mprage_images = os.listdir(path_to_mprage)
#    average_path = output_folder + "/mp_average" 
#    if not os.path.exists(average_path):
#        os.system("mkdir %s"%average_path)
#    flirt_call = "flirt -in %s/%s -ref %s/%s -out %s/registered -omat %s/registered -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -interp trilinear"%(path_to_mprage,mprage_images[0],path_to_mprage, mprage_images[1],average_path,average_path)          
#    os.system(flirt_call)
#
#    #Average the registered MPRAGE with the target of that registration
#    first_image = path_to_mprage + "/" + mprage_images[1]
#    second_image = average_path + "/" + os.listdir(average_path)[0]
#    average_call = "AverageImages 3 %s/averaged_mprages.nii.gz 1 %s %s"%(average_path,first_image,second_image)
#    os.system(average_call)
#  
#    # Warp to Canine Template (use 4 threads)
#    warp_results_folder = output_folder + "/reg_avgmprage2atlas"
#    if not os.path.exists(warp_results_folder):
#        os.system("mkdir %s/reg_avgmprage2atlas"%output_folder)
#    averaged_mprage = average_path + '/averaged_mprages.nii.gz'
    template_path = path_to_inVivo_atlas + '/invivoTemplate.nii.gz'
#    warp_call = "%s/antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s/dog -n 4"%(path_to_ants_scripts, template_path, averaged_mprage, warp_results_folder)
#    os.system(warp_call)
#
#    ################################# FEAT ####################################
#    
#    # Modify the fsf template for individual EPI and do the fMRI analysis
    first_lvl_res = output_folder + "/first_level_results"
#    if not os.path.exists(first_lvl_res):
#        os.system("mkdir %s"%first_lvl_res)
#    evonepath = path_to_design_folder + '/on'
#    evtwopath = path_to_design_folder + '/off'
#    for i in os.listdir(path_to_epi):
#        if i[-3:] == ".gz":
#            epi_output_folder = output_folder + "/first_level_results/%s"%i[:-7]
#        else:
#            epi_output_folder = output_folder + "/first_level_results/%s"%i[:-4]
#        epifullpath = path_to_epi + "/" + i
#        ntime = os.popen("fslnvols %s"%epifullpath).read().rstrip()
#        things_to_replace = {"SUBJECT_OUTPUT":epi_output_folder, "NTPTS":ntime, 
#                             "STANDARD_IMAGE":template_path, "SUBJECT_EPI":epifullpath,
#                             "SUBJECTEV1":evonepath, "SUBJECTEVI2":evtwopath}
#        with open("%s/design_template.fsf"%path_to_design_folder, 'r') as infile:
#            with open("%s/design.fsf"%path_to_design_folder,'w') as outfile:
#                for line in infile:
#                    for src, target in things_to_replace.iteritems():
#                        line = line.replace(src, target)
#                    outfile.write(line)
#        os.system("feat %s"%path_to_design_folder+"/design.fsf")
#        
#    ########################### TRICK FSL #####################################
#        
#    # Delete all mat files in each first-level, copy some identity matrices and
#    # mean functions so the registration and interpolation will not be effective. 
#    # Note: This code is still a part of the laop above but placed under a 
#    # different comment block since it's an important part of the analysis.
#        
#        os.system("rm -r %s.feat/reg/*mat"%epi_output_folder)
#        os.system("rm -r %s.feat/reg/standard.nii.gz"%epi_output_folder)
#        os.system("cp $FSLDIR/etc/flirtsch/ident.mat %s.feat/reg/example_func2standard.mat"%epi_output_folder)
#        os.system("cp %s.feat/mean_func.nii.gz %s.feat/reg/standard.nii.gz"%(epi_output_folder, epi_output_folder))    
#    
    ########################## SECOND LEVEL ###################################
    if len(os.listdir(first_lvl_res)) != len(os.listdir(path_to_epi)):
        sys.exit("The amount of the first level results are larger than the amount of the original EPI images. Group analysis failed")
    
    secondlvl_output = output_folder + "/second_level_results"
    if not os.path.exists(secondlvl_output):
        os.system("mkdir %s"%secondlvl_output)
    
    lengthFirstlvl = len(os.listdir(first_lvl_res))
    rangeofval = range(lengthFirstlvl)
    full_fmri_data_directory = ""
    full_higher_lvl_ev = ""
    full_group_member = ""    
    for i in rangeofval:
        indx = i + 1 
        whichepi = os.listdir(path_to_epi)
        whichepi.sort()
        single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s" \n\n'%(str(indx),str(indx),whichepi[i])
        single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) 1 \n\n'%(str(indx),str(indx))
        single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
        full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
        full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
        full_group_member = full_group_member + single_line_for_group_member
        
    main_replacements = {"GROUP_OUTPUT":secondlvl_output, "TOTAL_VOLUME":lengthFirstlvl,
                    "TOTAL_FIRST_LEVEL":lengthFirstlvl, "STANDARD_IMAGE":template_path,
                    "FMRI_DATA_DIRECTORY":full_fmri_data_directory,
                    "HIGH_LEVEL_EV":full_higher_lvl_ev,
                    "GROUP_MEMBER":full_group_member} 
    with open("%s/main_template.fsf"%path_to_secondlvl_design_folder, 'r') as maininfile:
        with open("%s/group.fsf"%path_to_secondlvl_design_folder,'w') as mainoutfile:
            for line in maininfile:
                for src, target in main_replacements.iteritems():
                    line = line.replace(src, target)
                mainoutfile.write(line)
    
    col_of_ones = "1\n" * lengthFirstlvl
    grp_replacements = {"NUM_OF_EPI":lengthFirstlvl,
                        "COL_OF_ONE_FOR_EACH_EPI":col_of_ones}
    with open("%s/gpr_template.grp"%path_to_secondlvl_design_folder, 'r') as grpinfile:
        with open("%s/group.grp"%path_to_secondlvl_design_folder,'w') as grpoutfile:
            for line in grpinfile:
                for src, target in grp_replacements.iteritems():
                    line = line.replace(src, target)
                grpoutfile.write(line)    
                
    col_of_sci_ones = "1.000000e+00\n" * lengthFirstlvl
    mat_replacements = {"NUM_OF_EPI_TWO":lengthFirstlvl,
                        "COL_OF_SCI_ONES":col_of_sci_ones}
    with open("%s/mat_template.grp"%path_to_secondlvl_design_folder, 'r') as matinfile:
        with open("%s/group.mat"%path_to_secondlvl_design_folder,'w') as matoutfile:
            for line in matinfile:
                for src, target in mat_replacements.iteritems():
                    line = line.replace(src, target)
                matoutfile.write(line)       

onlyPreprocAndFirstLvl('/home/ozzy/Desktop/Canine/T1', '/home/ozzy/Desktop/Canine/EPI', '/home/ozzy/Desktop/Canine/Atlas', '/home/ozzy/Desktop/Canine/design','/home/ozzy/Desktop/Canine/second_lvl_design', '/home/ozzy/Desktop/Canine/results', '/home/ozzy/bin/ants/bin') 
   
    
