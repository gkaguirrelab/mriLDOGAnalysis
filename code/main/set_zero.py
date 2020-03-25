import nibabel as nib
import numpy as np

def set_zero(working_image, template_image):
    
    '''
    Description:
        Sets the values outside the brain to zero using another image as the 
        base image. Can be used to skull strip coregistered images. Warning !!
        Overwrites the original image
        
    Inputs:
        - working_image: Image to load for setting values to zero
        - template_image: Template image to use for finding the zero values. 
    '''
    
    data = nib.load(working_image)
    data_val = data.get_data()
    atlas = nib.load(template_image)
    atlas_data_val = atlas.get_data()
    zero_indexes = np.argwhere(atlas_data_val == 0)
    
    for index in zero_indexes:
        x = index[0]
        y = index[1]
        z = index[2]
        data_val[x, y, z] = 0
    
    nib.save(data, working_image)