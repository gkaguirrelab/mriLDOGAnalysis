import nibabel as nib
import matplotlib.pyplot as plt
import os

def make_plot(base_image, overlay, title, filename, centre_of_gravity, output_folder, apect_ratio_vector=[1,1,1,1,1,1]):
    
    '''
    Description:
        Plots diagnostic images.
        
    Inputs:
        - base_image: The .nii or .nii.gz brain image to plot.
        - overlay: Image to overlay 
        - title: Title of the plot
        - filename: save name of the image with the extantion (eg. image.png)
        - centre_of_gravity: Is a list of coordinates of the middle (gravity)
        of the brain image. Example: [95,68,102]
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output
        - aspect_ratio_vector: List. Aspect ratio for saggital, axial, coronal
        images for both the base and overlay. 6 values in total. Default is all
        ones so the original aspect ratio will not be changed.      
    '''

    x = centre_of_gravity[0]
    y = centre_of_gravity[1]
    z = centre_of_gravity[2]
    
    diagnostic_images = os.path.join(output_folder, 'diagnostic_images')
    if not os.path.exists(diagnostic_images):
        os.system('mkdir %s' % diagnostic_images)
        
    fig, (ax1, ax2, ax3) = plt.subplots(1,3)
    fig.suptitle(title, fontsize=20)

    epi_img = nib.load(base_image)
    epi_img_data = epi_img.get_fdata()
    ax1.imshow(epi_img_data[x,:,:], cmap="gray", aspect = apect_ratio_vector[0])
    ax2.imshow(epi_img_data[:,y,:], cmap="gray", aspect = apect_ratio_vector[1])
    ax3.imshow(epi_img_data[:,:,z], cmap="gray", aspect = apect_ratio_vector[2])
    ax1.axis('off')
    ax2.axis('off')
    ax3.axis('off')  
    
    if overlay != 'NA':
        epi_img = nib.load(overlay)
        epi_img_data = epi_img.get_fdata()
        ax1.imshow(epi_img_data[x,:,:], cmap="hot", alpha=0.4, aspect = apect_ratio_vector[3])
        ax2.imshow(epi_img_data[:,y,:], cmap="hot", alpha=0.4, aspect = apect_ratio_vector[4])
        ax3.imshow(epi_img_data[:,:,z], cmap="hot", alpha=0.4, aspect = apect_ratio_vector[5])
        ax1.axis('off')
        ax2.axis('off')
        ax3.axis('off')

    plt.savefig(os.path.join(diagnostic_images, filename)) 
