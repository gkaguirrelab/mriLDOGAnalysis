from prepare_mprage import prepare_mprage
from warp_to_invivo import warp_to_invivo
from make_overlay_plot import make_overlay_plot


def main_function(path_to_mprage, template_path, centre_of_gravity_x, centre_of_gravity_y, centre_of_gravity_z, extraction_threshold, number_of_threads, output_folder):
    
    # Assemble centre of gravity        
    centre_of_gravity = [centre_of_gravity_x, centre_of_gravity_y, centre_of_gravity_z]
   
    # Bias corrects mprage images, registers, averages (normalized), skull strips and flips
    preprocessed_mprage_folder, averaged_mprage, extracted_brain, flipped_extracted_brain = prepare_mprage(path_to_mprage, centre_of_gravity, extraction_threshold, output_folder)
    
    # Saves a brain extraction diagnostic image
    make_overlay_plot(averaged_mprage, extracted_brain, 'Brain Extraction Results', 'brain_extraction_qa.png', output_folder)
    
    # Warps the averaged mprage to the template 
    warp_results_folder, warped_mprage, standard_generic = warp_to_invivo(extracted_brain, template_path, output_folder, number_of_threads, 'dog_diff')
    
    # Saves some more diagnostic images for standard and flipped registrations
    make_overlay_plot(template_path, warped_mprage, 'Warp results', 'mprage2template_qa.png', output_folder)
