import nibabel as nib
import matplotlib.pyplot as plt
import os

def make_overlay_plot(base_image, overlay, title, filename, output_folder):
    
    # This function simply gets two MRI images as inputs and overlays them 
    #using different colors for each image. Used as a diagnostic method.
    
    diagnostic_images = os.path.join(output_folder, 'diagnostic_images')
    if not os.path.exists(diagnostic_images):
        os.system('mkdir %s' % diagnostic_images)
        
    fig, (ax1, ax2, ax3) = plt.subplots(1,3)
    fig.suptitle(title, fontsize=20)

    epi_img = nib.load(base_image)
    epi_img_data = epi_img.get_fdata()
    voxel1 = int(epi_img_data.shape[0]//2)
    voxel2 = int(epi_img_data.shape[1]//2)
    voxel3 = int(epi_img_data.shape[2]//2)
    ax1.imshow(epi_img_data[voxel1,:,:], cmap="gray")
    ax2.imshow(epi_img_data[:,voxel2,:], cmap="gray")
    ax3.imshow(epi_img_data[:,:,voxel3], cmap="gray")
    
    epi_img = nib.load(overlay)
    epi_img_data = epi_img.get_fdata()
    voxel1 = int(epi_img_data.shape[0]//2)
    voxel2 = int(epi_img_data.shape[1]//2)
    voxel3 = int(epi_img_data.shape[2]//2)
    ax1.imshow(epi_img_data[voxel1,:,:], cmap="hot", alpha=0.4)
    ax2.imshow(epi_img_data[:,voxel2,:], cmap="hot", alpha=0.4)
    ax3.imshow(epi_img_data[:,:,voxel3], cmap="hot", alpha=0.4)

    plt.savefig(os.path.join(diagnostic_images, filename))    
    
    return(diagnostic_images)