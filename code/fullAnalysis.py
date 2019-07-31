#!/usr/bin/python

import os 
import sys

"""

path_to_mprage	                : Path to folder containing MPRAGE images
path_to_epi   	                : path to folder containing EPI images
path_to_atlas 	                : Path to folder containing canine atlas
path_to_design_folder           : Path to folder containing design.fsf file 
                                  which is the template specifying GLM and oher 
                                  parameters for FSL's 1st level FEAT analysis
path_to_secondlvl_design_folder : Path to folder containing group.fsf template
                                  for FSL's 2nd level FEAT analysis
output_folder                   : Results folder is created at this path and
                                  all outputs are placed in that folder
path_to_ants_scripts            : antsResitrationSyN is a custom script 
                                  prepared for registration. Specify a path to 
                                  ants scripts folder so python can use it

 WARNINGS:
 Specify Folders not individual files
 Don't put a slash at the end of your path but put one at the beginning (e.g. /home/Desktop/files)

 Example:
 preprocAndFirstLvl('/home/ozzy/Desktop/Canine/T1', '/home/ozzy/Desktop/Canine/EPI', '/home/ozzy/Desktop/Canine/Atlas', '/home/ozzy/Desktop/Canine/design','/home/ozzy/Desktop/Canine/group_design', '/home/ozzy/Desktop/Canine/results', '/home/ozzy/bin/ants/bin') 

"""

def fullAnalysis(path_to_mprage, path_to_epi, path_to_atlas_folder, path_to_recon_fmris, total_readout_time_AP, total_readout_time_PA, path_to_design_folder, path_to_secondlvl_design_folder, path_to_ants_scripts, output_folder):
 
    ############################ PREPROCESSING ################################
    
    # Create a results/processing output folder if doesn't already exist (add)
    if not os.path.exists(output_folder+"/results"):
        os.system("mkdir %s/results"%output_folder)
    output_folder = output_folder + "/results"
    
    # Register two MPRAGEs
    print("REGISTERING MPRAGE IMAGES")
    mprage_images = os.listdir(path_to_mprage)
    average_path = output_folder + "/mp_average" 
    if not os.path.exists(average_path):
        os.system("mkdir %s"%average_path)
    flirt_call = "flirt -in %s/%s -ref %s/%s -out %s/registered -omat %s/registered -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -interp trilinear"%(path_to_mprage,mprage_images[0],path_to_mprage, mprage_images[1],average_path,average_path)          
    os.system(flirt_call)

    #Average the registered MPRAGE with the target of that registration
    print("AVERAGING MPRAGE IMAGES")
    first_image = path_to_mprage + "/" + mprage_images[1]
    second_image = average_path + "/" + os.listdir(average_path)[0]
    average_call = "AverageImages 3 %s/averaged_mprages.nii.gz 1 %s %s"%(average_path,first_image,second_image)
    os.system(average_call)
  
    # Warp to Canine Template (use 4 threads)
    print("WARPING THE AVERAGED MPRAGE TO INVIVO ATLAS")
    warp_results_folder = output_folder + "/reg_avgmprage2atlas"
    if not os.path.exists(warp_results_folder):
        os.system("mkdir %s/reg_avgmprage2atlas"%output_folder)
    averaged_mprage = average_path + '/averaged_mprages.nii.gz'
    template_path = path_to_atlas_folder + '/invivo/invivoTemplate.nii.gz'
    warp_call = "%s/antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s/dog -n 4"%(path_to_ants_scripts, template_path, averaged_mprage, warp_results_folder)
    os.system(warp_call)
    
    # Top-up 
    direction_vector_AP = "0 -1 0 %s\n"%str(total_readout_time_AP)
    direction_vector_PA = "0 1 0 %s"%str(total_readout_time_PA)
    acparam_file = path_to_recon_fmris + "/acqparams.txt"
    os.system("touch %s"%acparam_file)
    textfile = open(acparam_file, 'w')
    textfile.write(direction_vector_AP)
    textfile.write(direction_vector_PA)
    textfile.close()
    
    for i in os.listdir(path_to_recon_fmris):
        if "AP" in i:
            print("found an AP single-rep fmri")
            ap_image = path_to_recon_fmris + "/" + i
        if "PA" in i:
            print("found a PA single-rep fmri")
            pa_image = path_to_recon_fmris + "/" + i
    print("Full path to the single-rep AP: %s"%ap_image)
    print("Full path to the single-rep PA: %s"%pa_image)
    top_up_res = output_folder + "/results/top_up"
    if not os.path.exists(top_up_res):
        os.system("mkdir %s"%top_up_res)
    os.system("fslmerge -a %s/AP+PA %s %s"%(top_up_res, ap_image, pa_image))
    os.system("topup --imain=%s/AP+PA.nii.gz --datain=%s --config=b02b0.cnf --out=%s/topup_results --iout=%s/b0_unwarped --fout=%s/fieldmap_Hz" %(top_up_res,acparam_file,top_up_res,top_up_res,top_up_res))
    
    AP_images_temporary = output_path + "/APimages"
    PA_images_temporary = output_path + "/PAimages"
    if not os.path.exists(AP_images_temporary):
        system("mkdir %"%AP_images_temporary)
    if not os.path.exists(PA_images_temporary):
        system("mkdir %"%PA_images_temporary)

    for i in os.listdir(path_to_epi):
	    if "AP" in i:  
            os.system("mv %s/%s %s/%s"%(path_to_epi,i, AP_images_temporary,i))
        elif "PA" in i:
            os.system("mv %s/%s %s/%s"%(path_to_epi,i, PA_images_temporary,i))
        else:
            raise ValueError('You did not rename and put AP or PA in one of your EPI images')	
	
    corrected_epi_data = output_path + "/corrected"
    if not os.path.exists(corrected_epi_data):  
        system("mkdir %"%corrected_epi_data)
        
    for i in os.listdir(AP_images_temporary):
        system("applytopup --imain=%s --inindex=1 --method=jac --datatin=%s --topup=%s/topup_results --out=%s/corrected_%s"%(AP_images_temporary,acparam_file,top_up_res,corrected_epi_data,i)
    for i in os.listdir(PA_images_temporary):
        system("applytopup --imain=%s --inindex=2 --method=jac --datatin=%s --topup=%s/topup_results --out=%s/corrected_%s"%(PA_images_temporary,acparam_file,top_up_res,corrected_epi_data,i)
    
    path_to_epi = corrected_epi_data
    
    # Motion outlier finding/scrubbing
    print("CREATING MOTION OUTLIERS")
    for i in os.listdir(path_to_epi):
        full_individual_epi_path = path_to_epi + '/' + i
        confound_matrix_folder = output_folder + '/motion_covariates/' + i[:-7] + '_motion'
        if not os.path.exists(output_folder + "/motion_covariates"):
            os.system("mkdir %s/motion_covariates"%output_folder)
        if not os.path.exists(confound_matrix_folder):
            os.system("mkdir %s"%confound_matrix_folder)
        os.system("fsl_motion_outliers -i %s -o %s/covariate.txt -s %s/values -p %s/plot --fd --thresh=0.9 -v"%(full_individual_epi_path,confound_matrix_folder,confound_matrix_folder,confound_matrix_folder))
    
    ################################ FEAT ####################################
    for i in os.listdir(path_to_epi):
        check_the_confounds = "%s/motion_covariates/%s_motion/covariate.txt"%(output_folder,i[:-7])
        if not os.path.exists(check_the_confounds):
            os.system("touch %s"%check_the_confounds)
   
    # Modify the fsf template for individual EPI and do the fMRI analysis
    print("PERFORMING fMRI ANALYSIS: CHECK BROWSER REPORTS FOR DETAILS")
    first_lvl_res = output_folder + "/first_level_results"
    if not os.path.exists(first_lvl_res):
        os.system("mkdir %s"%first_lvl_res)
    evonepath = path_to_design_folder + '/on'
    evtwopath = path_to_design_folder + '/off'
    for i in os.listdir(path_to_epi):
        if i[-3:] == ".gz":
            epi_output_folder = output_folder + "/first_level_results/%s"%i[:-7]
        else:
            epi_output_folder = output_folder + "/first_level_results/%s"%i[:-4]
        epifullpath = path_to_epi + "/" + i
        ntime = os.popen("fslnvols %s"%epifullpath).read().rstrip()
        motion_epi = "%s/results/motion_covariates/%s_motion/covariate.txt"%(output_folder,i[:-7])
        things_to_replace = {"SUBJECT_OUTPUT":epi_output_folder, "NTPTS":ntime, 
                             "STANDARD_IMAGE":template_path, "SUBJECT_EPI":epifullpath,
                             "SUBJECTEV1":evonepath, "SUBJECTEVI2":evtwopath,
                             "CONFOUND_FOR_MOTION_EPI":motion_epi}
        with open("%s/design_template.fsf"%path_to_design_folder, 'r') as infile:
            with open("%s/design.fsf"%path_to_design_folder,'w') as outfile:
                for line in infile:
                    for src, target in things_to_replace.iteritems():
                        line = line.replace(src, target)
                    outfile.write(line)
        os.system("feat %s"%path_to_design_folder+"/design.fsf")
        
    ########################## TRICK FSL #####################################
        
    # Delete all mat files in each first-level, copy some identity matrices and
    # mean functions so the registration and interpolation will not be effective. 
    # Note: This code is still a part of the laop above but placed under a 
    # different comment block since it's an important part of the analysis.
        print("TRICKING FSL SO NO REGISTRATION TAKES PLACE")
        os.system("rm -r %s.feat/reg/*mat"%epi_output_folder)
        os.system("rm -r %s.feat/reg/standard.nii.gz"%epi_output_folder)
        os.system("cp $FSLDIR/etc/flirtsch/ident.mat %s.feat/reg/example_func2standard.mat"%epi_output_folder)
        os.system("cp %s.feat/mean_func.nii.gz %s.feat/reg/standard.nii.gz"%(epi_output_folder, epi_output_folder))    
   
    ######################### SECOND LEVEL ###################################
    print("PERFORMING HIGHER LEVEL ANALYSIS")
    if len(os.listdir(first_lvl_res)) != len(os.listdir(path_to_epi)):
        sys.exit("The amount of the first level results are larger than the amount of the original EPI images. Group analysis failed")
    secondlvl_output = output_folder + "/second_level_results"
    
    lengthFirstlvl = len(os.listdir(first_lvl_res))
    rangeofval = range(lengthFirstlvl)
    lengthFirstlvlstr = str(lengthFirstlvl)
    full_fmri_data_directory = ""
    full_higher_lvl_ev = ""
    full_group_member = ""    
    for i in rangeofval:
        indx = i + 1 
        whichepi = os.listdir(first_lvl_res)
        whichepi.sort()
        single_line_for_fmri_data_directory = '# AVW data or FEAT directory (%s) \nset feat_files(%s) "%s/%s" \n\n'%(str(indx),str(indx),first_lvl_res,whichepi[i])
        single_line_for_higher_level_ev = '# Higher-level EV value for EV 1 and input %s \nset fmri(evg%s.1) 1 \n\n'%(str(indx),str(indx))
        single_line_for_group_member = '# Group membership for input %s \nset fmri(groupmem.%s) 1 \n\n' %(str(indx),str(indx))
        full_fmri_data_directory = full_fmri_data_directory + single_line_for_fmri_data_directory
        full_higher_lvl_ev = full_higher_lvl_ev + single_line_for_higher_level_ev
        full_group_member = full_group_member + single_line_for_group_member  
    main_replacements = {"GROUP_OUTPUT":secondlvl_output, "TOTAL_VOLUME":lengthFirstlvlstr,
                    "TOTAL_FIRST_LEVEL":lengthFirstlvlstr, "STANDARD_IMAGE":template_path,
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
    grp_replacements = {"NUM_OF_EPI":lengthFirstlvlstr,
                        "COL_OF_ONE_FOR_EACH_EPI":col_of_ones}
    with open("%s/grp_template.grp"%path_to_secondlvl_design_folder, 'r') as grpinfile:
        with open("%s/group.grp"%path_to_secondlvl_design_folder,'w') as grpoutfile:
            for line in grpinfile:
                for src, target in grp_replacements.iteritems():
                    line = line.replace(src, target)
                grpoutfile.write(line)    
                
    col_of_sci_ones = "1.000000e+00\n" * lengthFirstlvl
    mat_replacements = {"NUM_OF_EPI_TWO":lengthFirstlvlstr,
                        "COL_OF_SCI_ONES":col_of_sci_ones}
    with open("%s/mat_template.mat"%path_to_secondlvl_design_folder, 'r') as matinfile:
        with open("%s/group.mat"%path_to_secondlvl_design_folder,'w') as matoutfile:
            for line in matinfile:
                for src, target in mat_replacements.iteritems():
                    line = line.replace(src, target)
                matoutfile.write(line)       

    os.system("feat %s"%path_to_secondlvl_design_folder+"/group.fsf")
  
    ########################## POST-PROCESSING ###############################
   
    # Invivo transform
    print("MAPPING THE SECOND LEVEL FMRI RESULTS TO THE INVIVO TEMPLATE")
    os.system("mkdir %s/deformed_results"%output_folder)
    os.system("antsApplyTransforms -d 3 -r %s/invivo/invivoTemplate.nii.gz -i %s.gfeat/cope2.feat/thresh_zstat1.nii.gz -t %s/dog1Warp.nii.gz -t %s/dog0GenericAffine.mat -o %s/deformed_results/off_on.nii.gz -v 1"%(path_to_atlas_folder,secondlvl_output,warp_results_folder,warp_results_folder,output_folder))
    os.system("antsApplyTransforms -d 3 -r %s/invivo/invivoTemplate.nii.gz -i %s.gfeat/cope1.feat/thresh_zstat1.nii.gz -t %s/dog1Warp.nii.gz -t %s/dog0GenericAffine.mat -o %s/deformed_results/on_off.nii.gz -v 1"%(path_to_atlas_folder,secondlvl_output,warp_results_folder,warp_results_folder,output_folder))
    
fullAnalysis('/home/ozzy/Desktop/Canine/without_topup/T1', '/home/ozzy/Desktop/Canine/without_topup/EPI', '/home/ozzy/Desktop/Canine/without_topup/Atlas','/home/ozzy/Desktop/Canine/without_topup/Recon', 0.0217349, 0.0217349, '/home/ozzy/Desktop/Canine/without_topup/design','/home/ozzy/Desktop/Canine/without_topup/second_lvl_design', '/home/ozzy/bin/ants/bin', '/home/ozzy/Desktop/Canine/without_topup') 

