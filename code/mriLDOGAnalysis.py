#!/usr/bin/python

import os 

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

def AnalyzeCanine(path_to_mprage, path_to_epi, path_to_inVivo_atlas, path_to_design_folder, output_folder, path_to_ants_scripts):
 
    ############################ PREPROCESSING ################################
    
    # Create a results/processing output folder if doesn't already exist (add)
    if not os.path.exists(output_folder):
        os.system("mkdir %s"%output_folder)
    
    # Register two MPRAGEs
    mprage_images = os.listdir(path_to_mprage)
    average_path = output_folder + "/mp_average" 
    if not os.path.exists(average_path):
        os.system("mkdir %s"%average_path)
    flirt_call = "flirt -in %s/%s -ref %s/%s -out %s/registered -omat %s/registered -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -interp trilinear"%(path_to_mprage,mprage_images[0],path_to_mprage, mprage_images[1],average_path,average_path)          
    os.system(flirt_call)

    #Average the registered MPRAGE with the target of that registration
    first_image = path_to_mprage + "/" + mprage_images[1]
    second_image = average_path + "/" + os.listdir(average_path)[0]
    average_call = "AverageImages 3 %s/averaged_mprages.nii.gz 1 %s %s"%(average_path,first_image,second_image)
    os.system(average_call)
  
    # Warp to Canine Template (use 4 threads)
    warp_results_folder = output_folder + "/reg_avgmprage2atlas"
    if not os.path.exists(warp_results_folder):
        os.system("mkdir %s/reg_avgmprage2atlas"%output_folder)
    averaged_mprage = average_path + '/averaged_mprages.nii.gz'
    template_path = path_to_inVivo_atlas + '/invivoTemplate.nii.gz'
    warp_call = "%s/antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s/dog -n 4"%(path_to_ants_scripts, template_path, averaged_mprage, warp_results_folder)
    os.system(warp_call)

#    ################################# FEAT ####################################

    # Modify the fsf template for individual EPI and do the fMRI analysis
    first_lvl_res = output_folder + "/first-level-results"
    if not os.path.exists(first_lvl_res):
        os.system("mkdir %s"%first_lvl_res)
    evonepath = path_to_design_folder + '/on'
    evtwopath = path_to_design_folder + '/off'
    for i in os.listdir(path_to_epi):
        epi_output_folder = output_folder + "/first-level-results/%s"%i
        epifullpath = path_to_epi + "/" + i
        ntime = os.popen("fslnvols %s"%epifullpath).read().rstrip()
        things_to_replace = {"SUBJECT_OUTPUT":epi_output_folder, "NTPTS":ntime, 
                             "STANDARD_IMAGE":template_path, "SUBJECT_EPI":epifullpath,
                             "SUBJECTEV1":evonepath, "SUBJECTEVI2":evtwopath}
        with open("%s/design.fsf"%path_to_design_folder) as infile:
            with open("%s/design.fsf"%path_to_design_folder,'w') as outfile:
                for line in infile:
                    for src, target in things_to_replace.iteritems():
                        line = line.replace(src, target)
                    outfile.write(line)

    os.system("feat %s"%path_to_design_folder+"/design.fsf")
#    
#    ########################### TRICK FSL #####################################
#    
#    ###################### GROUP LEVEL ANALYSIS ###############################
#
#    ######################### DEFORM Z-MAPS ###################################    
    
AnalyzeCanine('/home/ozzy/Desktop/test/T1', '/home/ozzy/Desktop/test/EPI', '/home/ozzy/Desktop/test/Atlas', '/home/ozzy/Desktop/test/design', '/home/ozzy/Desktop/test/results', '/home/ozzy/bin/ants/bin') 
    
    
    