#!/usr/bin/python

import os 
import pandas as pd 
import numpy as np
"""
path_to_mprage	                : Path to folder containing MPRAGE images
path_to_epi   	                : path to folder containing EPI images
path_to_atlas_folder 	        : Path to folder containing canine atlas
path_to_recon_fmris		: path to folder containing single-rep EPI images
total_readout_time_AP		: Total readout time for AP images. Can be found in headers
total_readout_time_PA		: Total readout time for PA condition. Can be found in headers
path_to_design_folder           : Path to folder containing design.fsf file 
                                  which is the template specifying GLM and oher 
                                  parameters for FSL's 1st level FEAT analysis
path_to_secondlvl_design_folder : Path to folder containing group.fsf template
                                  for FSL's 2nd level FEAT analysis
path_to_ants_scripts            : antsResitrationSyN is a custom script 
                                  prepared for registration. Specify a path to 
                                  ants scripts folder so python can use it
output_folder                   : Results folder is created at this path and
                                  all outputs are placed in that folder
 WARNINGS:
 Specify Folders not individual files
 Don't put a slash at the end of your path but put one at the beginning (e.g. /home/Desktop/files)
 Example:
 def fullAnalysis(path_to_mprage, path_to_epi, path_to_atlas_folder, path_to_recon_fmris, total_readout_time_AP, total_readout_time_PA,   path_to_design_folder, path_to_secondlvl_design_folder, path_to_ants_scripts, output_folder):
"""

def fullAnalysis(path_to_mprage, path_to_epi, path_to_atlas_folder, path_to_recon_fmris, total_readout_time_AP, total_readout_time_PA, path_to_design_folder, path_to_secondlvl_design_folder, path_to_ants_scripts, output_folder):
 
    ############################ PREPROCESSING ################################
#    
    # Create a results/processing output folder if doesn't already exist (add)
    if not os.path.exists(output_folder+"/results"):
        os.system("mkdir %s/results"%output_folder)
    new_output_folder = output_folder + "/results"
            
#    # Register two MPRAGEs
#    print("REGISTERING MPRAGE IMAGES")
#    mprage_images = os.listdir(path_to_mprage)
    average_path = new_output_folder + "/mp_average" 
#    if not os.path.exists(average_path):
#        os.system("mkdir %s"%average_path)
#    flirt_call = "flirt -in %s/%s -ref %s/%s -out %s/registered -omat %s/registered -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -interp trilinear"%(path_to_mprage,mprage_images[0],path_to_mprage, mprage_images[1],average_path,average_path)          
#    os.system(flirt_call)
#    
#    # Average the registered MPRAGE with the target of that registration
#    print("AVERAGING MPRAGE IMAGES")
#    first_image = path_to_mprage + "/" + mprage_images[1]
#    second_image = average_path + "/registered.nii.gz"
#    average_call = "AverageImages 3 %s/averaged_mprages.nii.gz 1 %s %s"%(average_path,first_image,second_image)
#    os.system(average_call)
#    averaged_mprage = average_path + "/averaged_mprages.nii.gz"
#   
#    # Flip averaged mprage
    flipped_averaged_mprage = average_path + "/flipped_average.nii.gz"
#    flip_call = "fslswapdim %s x -y z %s"%(averaged_mprage,flipped_averaged_mprage)
#    #flip_call = "mri_convert --in_orientation LAS %s %s"%(averaged_mprage,flipped_averaged_mprage)   #This is freesurfer
#    os.system(flip_call)
##        
##    # Register two flipped MPRAGEs
##    print("REGISTERING FLIPPED MPRAGE IMAGES")
##    flipped_mprage_images = os.listdir(flipped_mprage_folder)
##    flirt_call = "flirt -in %s/%s -ref %s/%s -out %s/flipped_registered -omat %s/flipped_registered -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -interp trilinear"%(flipped_mprage_folder,flipped_mprage_images[0],flipped_mprage_folder, flipped_mprage_images[1],average_path,average_path)          
##    os.system(flirt_call)
#        
##    # Average the flipped registered MPRAGE with the target of that registration
##    print("AVERAGING FLIPPED MPRAGE IMAGES")
##    first_image = flipped_mprage_folder + "/" + flipped_mprage_images[1]
##    second_image = average_path + "/flipped_registered.nii.gz"
##    average_call = "AverageImages 3 %s/flipped_averaged_mprages.nii.gz 1 %s %s"%(average_path,first_image,second_image)
##    os.system(average_call)
##    flipped_averaged_mprage = average_path + "/flipped_averaged_mprages.nii.gz"
#
#     # Warp to Canine Template (use 5 threads change -n flag in warp_call if you want more threads)
#    print("WARPING THE AVERAGED MPRAGE TO INVIVO ATLAS")
    warp_results_folder = new_output_folder + "/reg_avgmprage2atlas"
#    if not os.path.exists(warp_results_folder):
#        os.system("mkdir %s/reg_avgmprage2atlas"%new_output_folder)
    template_path = path_to_atlas_folder + '/invivo/invivoTemplate.nii.gz'
#    warp_call = "%s/antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s/dog_diff -n 5"%(path_to_ants_scripts, template_path, averaged_mprage, warp_results_folder)
#    os.system(warp_call)
#    
#    print("WARPING THE FLIPPED AVERAGED MPRAGE TO INVIVO ATLAS")
#    warp_call2= "%s/antsRegistrationSyN.sh -d 3 -f %s -m %s -o %s/flipped_dog_diff -n 5"%(path_to_ants_scripts, template_path, flipped_averaged_mprage, warp_results_folder)
#    os.system(warp_call2)
#    
##    # Create the deformation field for averaged 
##    print("CREATING A DEFORMATION FIELD FOR AVERAGED WARP")
##    deff_call = "antsApplyTransforms -d 3 -o [%s/dog_diffCollapsedWarp.nii.gz,1] -t %s/dog_diff1Warp.nii.gz -t %s/dog_diff0GenericAffine.mat -r %s"%(warp_results_folder,warp_results_folder,warp_results_folder,template_path)
##    os.system(deff_call)
##    print("REPLICATING WARP FILE")
##    replication = "ImageMath 3 %s/dog_diff4DCollapsedWarp.nii.gz ReplicateDisplacement %s/dog_diffCollapsedWarp.nii.gz 112 3 0"%(warp_results_folder,warp_results_folder)
##    os.system(replication)
##    print("REPLICATING INVIVO TEMPLATE FOR REGISTRATION")
##    replication_temp = "ImageMath 3 %s/replicated_invivo.nii.gz ReplicateDisplacement %s/invivo/2x2x2resampled_invivoTemplate.nii.gz 112 3 0"%(warp_results_folder,path_to_atlas_folder)
##    os.system(replication_temp)
#
##    # Create the deformation field for flipped and averaged mprage 
##    print("CREATING A DEFORMATION FIELD FOR FLIPPED WARP")
##    deff_call = "antsApplyTransforms -d 3 -o [%s/flipped_dog_diffCollapsedWarp.nii.gz,1] -t %s/flipped_dog_diff1Warp.nii.gz -t %s/flipped_dog_diff0GenericAffine.mat -r %s"%(warp_results_folder,warp_results_folder,warp_results_folder,template_path)
##    os.system(deff_call)
##    print("REPLICATING WARP FILE")
##    replication = "ImageMath 3 %s/flipped_dog_diff4DCollapsedWarp.nii.gz ReplicateDisplacement %s/flipped_dog_diffCollapsedWarp.nii.gz 112 3 0"%(warp_results_folder,warp_results_folder)
##    os.system(replication)
#
#    # Top-up 
#    print("STARTING TOPUP")
#    direction_vector_AP = "0 -1 0 %s\n"%str(total_readout_time_AP)
#    direction_vector_PA = "0 1 0 %s"%str(total_readout_time_PA)
#    acparam_file = path_to_recon_fmris + "/acqparams.txt"
#    os.system("touch %s"%acparam_file)
#    textfile = open(acparam_file, 'w')
#    textfile.write(direction_vector_AP)
#    textfile.write(direction_vector_PA)
#    textfile.close()
#    
#    for i in os.listdir(path_to_recon_fmris):
#        if "AP" in i:
#            print("found the AP single-rep fmri")
#            ap_image = path_to_recon_fmris + "/" + i
#        if "PA" in i:
#            print("found the PA single-rep fmri")
#            pa_image = path_to_recon_fmris + "/" + i
#    print("Full path to the single-rep AP: %s"%ap_image)
#    print("Full path to the single-rep PA: %s"%pa_image)
#    print("STARTING TOPUP")
    top_up_res = new_output_folder + "/top_up"
#    if not os.path.exists(top_up_res):
#        os.system("mkdir %s"%top_up_res)
#    os.system("fslmerge -a %s/AP+PA %s %s"%(top_up_res, ap_image, pa_image))
#    os.system("topup --imain=%s/AP+PA.nii.gz --datain=%s --config=b02b0.cnf --out=%s/topup_results --iout=%s/b0_unwarped --fout=%s/fieldmap_Hz" %(top_up_res,acparam_file,top_up_res,top_up_res,top_up_res))
#    
#    AP_images_temporary = output_folder + "/APimages"
#    PA_images_temporary = output_folder + "/PAimages"
#    if not os.path.exists(AP_images_temporary):
#        os.system("mkdir %s"%AP_images_temporary)
#    if not os.path.exists(PA_images_temporary):
#        os.system("mkdir %s"%PA_images_temporary)
#
#    for i in os.listdir(path_to_epi):
#        if "AP" in i:
#            os.system("cp %s/%s %s/%s"%(path_to_epi,i,AP_images_temporary,i))
#        elif "PA" in i:
#            os.system("cp %s/%s %s/%s"%(path_to_epi,i,PA_images_temporary,i))
#        else:
#            raise ValueError("You did not rename and put AP or PA in one of your EPI images")
#    
#    os.system("applytopup --imain=%s/AP.nii.gz --inindex=1 --method=jac --datain=%s --topup=%s/topup_results --out=%s/register_to_this"%(path_to_recon_fmris,acparam_file,top_up_res,top_up_res))
#
    corrected_epi = new_output_folder + "/corrected_epi"
#    if not os.path.exists(corrected_epi):
#        os.system("mkdir %s"%corrected_epi)    
#    for i in os.listdir(AP_images_temporary):
#        os.system("applytopup --imain=%s/%s --inindex=1 --method=jac --datain=%s --topup=%s/topup_results --out=%s/corrected_%s"%(AP_images_temporary,i,acparam_file,top_up_res,corrected_epi,i))
#    for i in os.listdir(PA_images_temporary):
#        os.system("applytopup --imain=%s/%s --inindex=2 --method=jac --datain=%s --topup=%s/topup_results --out=%s/corrected_%s"%(PA_images_temporary,i,acparam_file,top_up_res,corrected_epi,i))
#  
##    # Motion outlier finding/scrubbing
##    print("CREATING MOTION OUTLIERS")
##    for i in os.listdir(corrected_epi):
##        full_individual_epi_path = corrected_epi + '/' + i
##        confound_matrix_folder = new_output_folder + '/motion_covariates/' + i[:-7] + '_motion'
##        if not os.path.exists(new_output_folder + "/motion_covariates"):
##            os.system("mkdir %s/motion_covariates"%new_output_folder)
##        if not os.path.exists(confound_matrix_folder):
##            os.system("mkdir %s"%confound_matrix_folder)
##        os.system("fsl_motion_outliers -i %s -o %s/covariate.txt -s %s/values -p %s/plot --fd --thresh=0.9 -v"%(full_individual_epi_path,confound_matrix_folder,confound_matrix_folder,confound_matrix_folder))
##    for i in os.listdir(corrected_epi):
##        check_the_confounds = "%s/motion_covariates/%s_motion/covariate.txt"%(new_output_folder,i[:-7])
##        if not os.path.exists(check_the_confounds):
##            os.system("touch %s"%check_the_confounds)
#   
#    # Motion Correction
#    print("STARTING MOTION CORRECTION")
    moco_cov = new_output_folder + "/moco_covariates"
#    mc_to_this = top_up_res + "/register_to_this.nii.gz"
#    if not os.path.exists(moco_cov):
#        os.system("mkdir %s"%moco_cov)
#    for i in os.listdir(corrected_epi):
#        mcflirt_call = "mcflirt -in %s/%s -o %s/%s -reffile %s -dof 12 -plots"%(corrected_epi,i,corrected_epi,i,mc_to_this)
#        print(mcflirt_call)
#        os.system(mcflirt_call)
#    os.system("mv %s/*.par %s/"%(corrected_epi,moco_cov))     
#    
#    # Motion derivatives
#    for i in os.listdir(moco_cov):
#        original_par = moco_cov + '/' + i
#        print(original_par)
#        pd.set_option("display.precision", 8)
#        data = pd.read_csv(original_par, sep = '  ', header = None, engine='python')
#        data_sqrted = data ** 2
#        data_diffed = data.diff(periods=1, axis=0)
#        data_diffed = data_diffed.fillna(0)
#        data_diffed_sqrt = data_diffed ** 2 
#        data_concatted = pd.concat([data, data_sqrted, data_diffed, data_diffed_sqrt], axis=1)
#        np.savetxt(original_par, data_concatted, delimiter='  ')
#    
#    # Warp EPI images to invivo template
#    print("WARPING EPI IMAGES TO INVIVO TEMPLATE")
    warped_epi = new_output_folder + "/warped_epi"
#    if not os.path.exists(warped_epi):
#        os.system("mkdir %s"%warped_epi)        
#    for i in os.listdir(corrected_epi):
#        os.system("antsApplyTransforms --float --default-value 0 --input %s/%s --input-image-type 3 --interpolation Linear --output %s/warped_%s --reference-image %s/invivo/2x2x2resampled_invivoTemplate.nii.gz --transform [ %s/dog_diff0GenericAffine.mat, 0 ] -v 1"%(corrected_epi,i,warped_epi,i,path_to_atlas_folder,warp_results_folder))
#        #os.system("antsApplyTransforms -d 4 -o %s/warped_%s -t %s/dog_diff4DCollapsedWarp.nii.gz -t %s/dog_diff1Warp.nii.gz -r %s/2mreplicated_invivo.nii.gz -i %s/%s"%(warped_epi,i,warp_results_folder,warp_results_folder,warp_results_folder,corrected_epi,i))
#    
     # Flip 4D hemispheres 
    flipped_epi = new_output_folder + "/flipped"
    if not os.path.exists(flipped_epi):
        os.system("mkdir %s"%flipped_epi)
    for i in os.listdir(corrected_epi):
        corrected_imaj = corrected_epi + '/' + i
        flipped_imaj = flipped_epi + "/flipped_" + i
        flip_call = "fslswapdim %s x -y z %s"%(corrected_imaj,flipped_imaj)
        #flip_call = "mri_convert --in_orientation RAS %s %s"%(corrected_imaj,flipped_imaj)
        os.system(flip_call)
  
    # Calculate the warp to flipped mprage with the first volume of flipped
    first_flipped_epi = flipped_epi + '/' + os.listdir(flipped_epi)[0]
    os.system("fslroi %s %s/first_volume_of_first_flipped.nii.gz 0 1"%(first_flipped_epi,top_up_res))
    first_vol_first_flip = top_up_res + "/first_volume_of_first_flipped.nii.gz"
    os.system("antsRegistrationSyN.sh -d 3 -f %s -t r -m %s -o %s/corrector -n 4"%(flipped_averaged_mprage, first_vol_first_flip, top_up_res))
    corrector = top_up_res + "/correctorWarped.nii.gz"        

    # Warp to invivo in two steps
    for+ i in os.listdir(flipped_epi):
        os.system("antsApplyTransforms --float --default-value 0 --input %s/%s --input-image-type 3 --interpolation Linear --output %s/%s --reference-image %s --transform [ %s/corrector0GenericAffine.mat, 0 ] -v 1"%(flipped_epi,i,flipped_epi,i,corrector,top_up_res))             
        #os.system("antsApplyTransforms -d 4 -o %s/%s -t %s/flipped_dog_diff4DCollapsedWarp.nii.gz -r %s/replicated_invivo.nii.gz -i %s/%s"%(flipped_epi,i,warp_results_folder,warp_results_folder,flipped_epi,i))
    for i in os.listdir(flipped_epi):
        os.system("antsApplyTransforms --float --default-value 0 --input %s/%s --input-image-type 3 --interpolation Linear --output %s/%s --reference-image %s/invivo/2x2x2resampled_invivoTemplate.nii.gz --transform [ %s/flipped_dog_diff0GenericAffine.mat, 0 ] -v 1"%(flipped_epi,i,flipped_epi,i,path_to_atlas_folder,warp_results_folder))

  
    # Average original and flipped save the results in the flipped folder
    final_epi = new_output_folder + "/final_preprocessed_fmri"
    if not os.path.exists(final_epi):
        os.system("mkdir %s"%final_epi)    
    for i in os.listdir(warped_epi):
        avgcall = "fslmaths %s/%s -add %s/flipped_%s -div 2 %s/final_%s -odt float"%(warped_epi, i, flipped_epi, i[7:], final_epi, i[7:])
        os.system(avgcall)        
             
    # Downsample to 2mm isotropic 
    print("DOWNSAMPLING %s TO 2MM ISO"%i)
    for i in os.listdir(final_epi):
        os.system("antsApplyTransforms --float --default-value 0 --input %s/%s --input-image-type 3 --interpolation Linear --output %s/%s --reference-image %s/invivo/2x2x2resampled_invivoTemplate.nii.gz --transform [ %s/invivo/invivoToinvivo2/in2in0GenericAffine.mat, 0 ] -v 1"%(final_epi,i,final_epi,i,path_to_atlas_folder,path_to_atlas_folder))
 
    ################################ FEAT ####################################

    # Modify the fsf template for individual EPI and do the fMRI analysis
    print("PERFORMING fMRI ANALYSIS: CHECK BROWSER REPORTS FOR DETAILS")
    first_lvl_res = new_output_folder + "/first_level_results"
    if not os.path.exists(first_lvl_res):
        os.system("mkdir %s"%first_lvl_res)
    evonepath = path_to_design_folder + '/off'
    for i in os.listdir(final_epi):
        if i[-3:] == ".gz":
            epi_output_folder = new_output_folder + "/first_level_results/%s"%i[:-7]
        else:
            epi_output_folder = new_output_folder + "/first_level_results/%s"%i[:-4]
        epifullpath = final_epi + "/" + i
        ntime = os.popen("fslnvols %s"%epifullpath).read().rstrip()
        motion_epi = "%s/%s.par"%(moco_cov,i[15:])
        things_to_replace = {"SUBJECT_OUTPUT":epi_output_folder, "NTPTS":ntime, 
                             "STANDARD_IMAGE":template_path, "SUBJECT_EPI":epifullpath,
                             "SUBJECTEV1":evonepath,
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
    if len(os.listdir(first_lvl_res)) != len(os.listdir(final_epi)):
        raise ValueError ("The amount of the first level results are larger than the amount of the original EPI images. Group analysis failed")
    secondlvl_output = new_output_folder + "/second_level_results"
    
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
  
#    ########################## POST-PROCESSING ###############################
#   ## Upsample your FSL results back to 0.7292mm isotropic
#   
#   
##    # Invivo transform
##    print("MAPPING THE SECOND LEVEL FMRI RESULTS TO THE INVIVO TEMPLATE")
##    os.system("mkdir %s/deformed_results"%new_output_folder)
##    os.system("antsApplyTransforms -d 3 -r %s/invivo/invivoTemplate.nii.gz -i %s.gfeat/cope2.feat/thresh_zstat1.nii.gz -t %s/dog1Warp.nii.gz -t %s/dog0GenericAffine.mat -o %s/deformed_results/off_on_invivo.nii.gz -v 1"%(path_to_atlas_folder,secondlvl_output,warp_results_folder,warp_results_folder,output_folder))
##    os.system("antsApplyTransforms -d 3 -r %s/invivo/invivoTemplate.nii.gz -i %s.gfeat/cope1.feat/thresh_zstat1.nii.gz -t %s/dog1Warp.nii.gz -t %s/dog0GenericAffine.mat -o %s/deformed_results/on_off_invivo.nii.gz -v 1"%(path_to_atlas_folder,secondlvl_output,warp_results_folder,warp_results_folder,output_folder))
##    deformed_results_folder = new_output_folder + "deformed_results"
##    
##    # Surface mapping
##    os.system("mri_vol2surf --mov %s/off_on_invivo.nii.gz --out %s/off_on_RH_surface_overlay.mgz --srcreg %s/invivo2exvivo/register.dat --hemi rh"%(deformed_results_folder,deformed_results_folder,path_to_atlas_folder))
##    os.system("mri_vol2surf --mov %s/off_on_invivo.nii.gz --out %s/off_on_LH_surface_overlay.mgz --srcreg %s/invivo2exvivo/register.dat --hemi lh"%(deformed_results_folder,deformed_results_folder,path_to_atlas_folder))
##    os.system("mri_vol2surf --mov %s/on_off_invivo.nii.gz --out %s/on_off_RH_surface_overlay.mgz --srcreg %s/invivo2exvivo/register.dat --hemi rh"%(deformed_results_folder,deformed_results_folder,path_to_atlas_folder))
##    os.system("mri_vol2surf --mov %s/on_off_invivo.nii.gz --out %s/on_off_LH_surface_overlay.mgz --srcreg %s/invivo2exvivo/register.dat --hemi lh"%(deformed_results_folder,deformed_results_folder,path_to_atlas_folder))

#fullAnalysis('/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme/T1', '/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme/EPI', '/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme/Atlas','/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme/Recon', 0.0217349, 0.0217349, '/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme/design','/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme/second_lvl_design', '/home/ozzy/bin/ants/bin', '/home/ozzy/Desktop/latestCanine/Canine3_correct_deneme') 
fullAnalysis('/home/ozzy/Desktop/canine/canine3/T1', '/home/ozzy/Desktop/canine/canine3/EPI', '/home/ozzy/Desktop/canine/canine3/Atlas','/home/ozzy/Desktop/canine/canine3/Recon', 0.0217349, 0.0217349, '/home/ozzy/Desktop/canine/canine3/design','/home/ozzy/Desktop/canine/canine3/second_lvl_design', '/home/ozzy/bin/ants/bin', '/home/ozzy/Desktop/canine/canine3') 

