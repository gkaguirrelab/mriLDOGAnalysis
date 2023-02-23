import os
import sys
import nilearn
from nilearn import plotting
import matplotlib.pyplot as plt

def plot_surface(subject_id, invivoTemp, path_to_R2_map, ldog_surface_and_calculations_folder, threshold, output, flattenMap='False'):
    
    # This function makes surface plots from R2 stat maps.
    
    # Inputs
    # subject_id: Subject id that is appended in front of ldog images.
    # path_to_R2_map: Path to R2 volumetric stat map
    # ldog_surface_and_calculations_folder: Folder that contains the surface folder
    # and all invivo-exvivo calculations (specific to the ldog project)
    # threshold: Threshold for the surface maps
    # output: Folder to save the images. Images are prenamed, so only point to the
    # folder you want to save images to.
    # flattenMap: Plot images on flatten surfaces for ldog images. Need to be
    # able to run freeview, and have access to ldog repo.
    
    threshold = float(threshold)
    print('Mapping to surface')
    # Set paths
    interpolated_map = os.path.join(ldog_surface_and_calculations_folder, '%s_surface_interpolated.nii.gz' % subject_id)
    orig_image = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'mri', 'T1.nii')
    lh_inf = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'surf', 'lh.inflated')
    rh_inf = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'surf', 'rh.inflated')
    sulc_map_lh = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'surf', 'lh.sulc')
    sulc_map_rh = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'surf', 'rh.sulc')
    lh_cut = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'surf', 'lh.flattened_cut')
    rh_cut = os.path.join(ldog_surface_and_calculations_folder, 'Woofsurfer', 'surf', 'rh.flattened_cut')
    
    #Set path to calculations 
    warp = os.path.join(ldog_surface_and_calculations_folder,'exvivo_warp_files', 'toEx1Warp.nii.gz')
    secondary_linear = os.path.join(ldog_surface_and_calculations_folder,'exvivo_warp_files', 'secondLinearAnts.mat')
    initial_linear = os.path.join(ldog_surface_and_calculations_folder,'exvivo_warp_files', 'initialLinearAnts.mat')
    register_dat = os.path.join(ldog_surface_and_calculations_folder, 'exvivo_warp_files', 'register.dat')
    
    if 'V1' in subject_id:
        # Apply the invivo to exvivo warp to the map (ldog specific step)
        os.system('antsApplyTransforms -d 3 -i %s -r %s -o %s -t %s -t %s -t %s' % (path_to_R2_map,
                                                                                    orig_image,
                                                                                    interpolated_map,
                                                                                    warp,
                                                                                    secondary_linear,
                                                                                    initial_linear))    
       
        # Interpolate and make the left and right hemispheres and save it to a temporary folder
        surfaces_folder = '/tmp/surfaces_folder'
        os.system('mkdir %s' % surfaces_folder)
        os.system('mri_vol2surf --mov %s --ref %s --reg %s --srcsubject Woofsurfer --hemi %s --o %s' % (interpolated_map, interpolated_map, register_dat, 'lh', os.path.join(surfaces_folder, 'left_hemi.mgz')))
        os.system('mri_vol2surf --mov %s --ref %s --reg %s --srcsubject Woofsurfer --hemi %s --o %s' % (interpolated_map, interpolated_map, register_dat, 'rh', os.path.join(surfaces_folder, 'right_hemi.mgz')))
      
        # Make the surface plots
        lh_map_path = os.path.join(surfaces_folder, 'left_hemi.mgz')
        loaded_lh_map = nilearn.surface.load_surf_data(lh_map_path)
        rh_map_path = os.path.join(surfaces_folder, 'right_hemi.mgz')
        loaded_rh_map = nilearn.surface.load_surf_data(rh_map_path)
        left_save_name = os.path.join(output,'%s_left_medial.png' % subject_id)
        right_save_name = os.path.join(output,'%s_right_lateral.png' % subject_id)
        
        if flattenMap == 'True':
            os.system('freeview --surface %s:patch=%s:curvature_method=binary:overlay=%s:overlay_threshold=%s,1 --cam Elevation 100 --screenshot %s' % (lh_inf,lh_cut,lh_map_path,threshold,left_save_name))
            os.system('freeview --surface %s:patch=%s:curvature_method=binary:overlay=%s:overlay_threshold=%s,1 --cam Elevation 100 --screenshot %s' % (rh_inf,rh_cut,rh_map_path,threshold,right_save_name))            
        else:
            loaded_inflated_left = nilearn.surface.load_surf_mesh(lh_inf)
            loaded_inflated_right = nilearn.surface.load_surf_mesh(rh_inf)  
            fig1 = plt.figure(figsize=[11,6])
            fig2 = plt.figure(figsize=[11,6])
            fig3 = plt.figure(figsize=[11,6])
            fig4 = plt.figure(figsize=[11,6])
            plotting.plot_surf_stat_map(loaded_inflated_left, loaded_lh_map, bg_map=sulc_map_lh,
                                        threshold=threshold, view='medial', figure=fig1, output_file=left_save_name, vmax=1) 
            plotting.plot_surf_stat_map(loaded_inflated_right, loaded_rh_map, bg_map=sulc_map_rh,
                                        threshold=threshold, view='lateral', figure=fig4, output_file=right_save_name, vmax=1)     
    elif 'LGN' in subject_id:
        plotting.plot_stat_map(path_to_R2_map, invivoTemp, threshold=threshold, title=subject_id, cut_coords=(7.8, -3.5, -13.5), output_file=os.path.join(output,'%s_LGN.png' % subject_id), vmax=1)
    
plot_surface(*sys.argv[1:])   
