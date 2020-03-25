import os

def flip_epi(epi_folder, output_folder):
    
    '''
    Description:
        This function x-y flips the EPI images.
        
    Inputs:
        - epi_folder: Path to a folder containing epi images
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output   
    '''

    # Flip 4D hemispheres 
    flipped_epi = os.path.join(output_folder, 'flipped')
    if not os.path.exists(flipped_epi):
        os.system('mkdir %s' % flipped_epi)
    for i in os.listdir(epi_folder):
        corrected_imaj = os.path.join(epi_folder, i)
        flipped_imaj = os.path.join(flipped_epi, i)
        flip_call = 'fslswapdim %s x -y z %s' % (corrected_imaj, flipped_imaj)
        os.system(flip_call)
        
    return (flipped_epi)