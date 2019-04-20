import skimage
import cv2
import json
import os
import skimage.io as io
import matplotlib.pyplot as plt

def load_images():
    config = json.load(open('./config/config.json', 'r'))
    rangenames = config['stack']['names']
    image_dir = config['stack']['complex']
    stack_images = []
    for idx in rangenames:
        # loop all sets of images
        for i in range(1,2):
            names = ['setup%d_%s_%d.jpg' % (i, 'complex', x) for x in range(1,6)]
            names[2] = 'setup%d_%s_3gt3.jpg' % (i, 'complex')
            print(names)
            for name in names:
                stack_images.append(io.imread(os.path.join(image_dir[str(i)], name)))
    
    plt.figure(figsize=(20, 5))
    plt.subplot(151)
    plt.title('1st image')
    plt.axis('off')
    plt.imshow(stack_images[0])

    plt.subplot(152)
    plt.title('2nd image')
    plt.axis('off')
    plt.imshow(stack_images[1])

    plt.subplot(153)
    plt.title('3rd image (ref)')
    plt.axis('off')
    plt.imshow(stack_images[2])

    plt.subplot(154)
    plt.title('4th image')
    plt.axis('off')
    plt.imshow(stack_images[3])

    plt.subplot(155)
    plt.title('5th image')
    plt.axis('off')
    plt.imshow(stack_images[4])
    
    plt.show()