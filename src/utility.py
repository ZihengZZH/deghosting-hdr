import skimage
import cv2
import json
import os
import skimage.io as io
import matplotlib.pyplot as plt


def load_images(type, vis=False):
    # para vis: whether or not to visualize images in the stack
    config = json.load(open('./config/config.json', 'r'))
    rangenames = config['stack']['names']
    image_dir = config['stack'][type]
    stack_images = []
    for idx in rangenames:
        # loop all sets of images
        for i in range(1,2):
            names = ['setup%d_%s_%d.jpg' % (i, type, x) for x in range(1,6)]
            names[2] = 'setup%d_%s_3gt3.jpg' % (i, type)
            print(names)
            for name in names:
                stack_images.append(io.imread(os.path.join(image_dir[str(i)], name)))
    
    return stack_images

    if vis:
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


def resize_images(scale, verbose=False):
    # para scale: resize ratio [int]
    # para verbose: whether or not to print more info while running
    img_dir = './src/hu2013/Data/Lady'
    output_dir = './src/hu2013/Data'
    names = ['Img1.jpg', 'Img2.jpg', 'Img3.jpg']
    for name in names:
        img = cv2.imread(os.path.join(img_dir, name))
        height, width, _ = img.shape
        img_resize = cv2.resize(img, (int(width/scale), int(height/scale)))
        
        if verbose:
            print("before resize\nheight: %d, width: %d" % (height, width))
            print("after resize\nheight: %d, width: %d" % (img_resize.shape[0], img_resize.shape[1]))
        
        cv2.imwrite(os.path.join(output_dir, name), img_resize)
