import os

def flip_epi(epi_folder, output_folder):

     # Flip 4D hemispheres 
    flipped_epi = os.path.join(output_folder, 'flipped')
    if not os.path.exists(flipped_epi):
        os.system('mkdir %s' % flipped_epi)
    for i in os.listdir(epi_folder):
        corrected_imaj = os.path.join(epi_folder, i)
        flipped_imaj = os.path.join(flipped_epi, 'flipped_' + i)
        flip_call = 'fslswapdim %s x -y z %s' % (corrected_imaj, flipped_imaj)
        #flip_call = 'mri_convert --in_orientation RAS %s %s' % (corrected_imaj,flipped_imaj)
        os.system(flip_call)
        
    return flipped_epi