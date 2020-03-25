import os 
import imageio

def make_gif(image_folder, gif_name, output_folder):
    '''
    Desription:
        Makes a dynamic gif from a set of images. At least two or more images
        are required.
    
    Inputs:
        - image_folder: Path to a folder containing the set of images
        - gif_name: Name of the save file without the extention (eg. mygifs)
        - output_folder: Path to save the output. The script creates more folders
        in this path and organizes the output
    '''
    
    # Make a gif out of multiple images
    images = []
    for filename in os.listdir(image_folder):
        images.append(imageio.imread(os.path.join(image_folder, filename)))
        imageio.mimsave('/%s/%s.gif' % (output_folder, gif_name), images, duration=0.7)