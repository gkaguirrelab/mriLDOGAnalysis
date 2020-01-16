import os
import nibabel as nb
import matplotlib.pyplot as plt
import numpy as np
import imageio

def plot_maps(template_path, map_path, threshold, output):

    template_load = nb.load(template_path)
    map_load = nb.load(map_path)
    template_data = template_load.get_data()
    map_data = map_load.get_data()
    map_data = np.ma.masked_where(map_data < threshold, map_data)
    
    saggital_temp = os.path.join(output, 'saggital_temp') 
    if not os.path.exists(saggital_temp):
        os.system('mkdir %s' % saggital_temp)
    for i in range(map_data.shape[0]):
        plt.imshow(template_data[i,:,:], cmap='gray')
        plt.imshow(map_data[i,:,:], cmap='hot')
        plt.colorbar()
        plt.clim(threshold, np.nanmax(map_data) + 0.1);
        plt.savefig('%s/saggital_plot%s.png' % (saggital_temp,i))
        plt.close()
    
    axial_temp = os.path.join(output, 'axial_temp')
    if not os.path.exists(axial_temp):
        os.system('mkdir %s' % axial_temp)
    for i in range(map_data.shape[1]):
        plt.imshow(template_data[:,i,:], cmap='gray')
        plt.imshow(map_data[:,i,:], cmap='hot')
        plt.colorbar()
        plt.clim(threshold, np.nanmax(map_data) + 0.1);
        plt.savefig('%s/axial_plot%s.png' % (axial_temp,i))
        plt.close()    
        
    coronal_temp = os.path.join(output, 'coronal_temp')
    if not os.path.exists(coronal_temp):
        os.system('mkdir %s' % coronal_temp)    
    for i in range(map_data.shape[2]):
        plt.imshow(template_data[:,:,i], cmap='gray')
        plt.imshow(map_data[:,:,i], cmap='hot')
        plt.colorbar()
        plt.clim(threshold, np.nanmax(map_data) + 0.1);
        plt.savefig('%s/coronal_plot%s.png' % (coronal_temp,i))
        plt.close()       
    
    images = []
    image_names = []
    for filename in os.listdir(saggital_temp):
        image_names.append(filename)
    image_names.sort()
    for image in image_names:
        images.append(imageio.imread(os.path.join(saggital_temp, image)))
    imageio.mimsave('/%s/%s.gif' % (output, 'saggital_plots'), images, duration=0.4)    
        
    images = []
    image_names = []
    for filename in os.listdir(axial_temp):
        image_names.append(filename)
    image_names.sort()
    for image in image_names:
        images.append(imageio.imread(os.path.join(axial_temp, image)))
    imageio.mimsave('/%s/%s.gif' % (output, 'axial_plots'), images, duration=0.4)  

    images = []
    image_names = []
    for filename in os.listdir(coronal_temp):
        image_names.append(filename)
    image_names.sort()
    for image in image_names:
        images.append(imageio.imread(os.path.join(coronal_temp, image)))
    imageio.mimsave('/%s/%s.gif' % (output, 'coronal_plots'), images, duration=0.4)    
    
template_path = '/home/ozzy/Documents/MATLAB/projects/mriLDOGAnalysis/Atlas/invivo/2x2x2resampled_invivoTemplate.nii.gz'
map_path = '/home/ozzy/Desktop/tes/N292_R2_map.nii.gz' 
threshold = 0.1
output = '/home/ozzy/Desktop/tes/'

plot_maps(template_path, map_path, threshold, output)