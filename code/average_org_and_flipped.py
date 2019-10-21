import os 

def average_org_and_flipped(original_epi_path, flipped_epi_path, output_folder):    
    final_epi = os.path.join(output_folder, 'final_preprocessed_fmri')
    if not os.path.exists(final_epi):
        os.system('mkdir %s' % final_epi)
    for i in os.listdir(original_epi_path):
        avgcall = 'fslmaths %s -add %s -div 2 %s -odt float' % (os.path.join(original_epi_path, i),
                                                                os.path.join(flipped_epi_path, 'flipped_' + i),
                                                                os.path.join(final_epi, 'final_' + i))
        os.system(avgcall)        
    
    return (final_epi)    
