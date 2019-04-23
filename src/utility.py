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


def data_analysis():
    sen2012 = dict()
    sen2012['set1'] = [66.22, 75.44, 87.46, 98.35, 67.29, 70.71, 74.22, 95.18, 89.56]
    sen2012['set2'] = [74.89, 89.85, 87.46, 91.41, 70.28, 80.31, 93.14, 92.67, 94.55]
    sen2012['set3'] = [65.63, 68.88, 68.56, 66.13, 68.82, 74.25, 76.69, 71.38, 72.72]
    sen2012['set4'] = [62.91, 62.58, 65.17, 69.71, 66.34, 68.77, 64.93, 61.50, 65.58]

    hu2013 = dict()
    hu2013['set1'] = [64.51, 65.13, 64.63, 65.28, 62.64, 65.10, 65.36, 66.02, 64.65]
    hu2013['set2'] = [62.31, 60.61, 64.00, 63.77, 60.22, 63.74, 62.28, 64.07, 64.54]
    hu2013['set3'] = [55.92, 58.08, 58.66, 58.33, 58.24, 58.84, 57.93, 58.78, 58.43]
    hu2013['set4'] = [58.89, 57.66, 59.33, 59.42, 58.81, 58.83, 59.03, 55.30, 53.41]

    set_sen2012, set_hu2013 = [], []
    for s in ['set1', 'set2', 'set3', 'set4']:
        set_sen2012.append((sum(sen2012[s]))/len(sen2012[s]))
        set_hu2013.append((sum(hu2013[s]))/len(hu2013[s]))

    type_sen2012, type_hu2013 = [], []
    for i in range(9):
        sen2012_temp, hu2013_temp = 0.0, 0.0
        for s in ['set1', 'set2', 'set3', 'set4']:
            sen2012_temp += sen2012[s][i]/4
            hu2013_temp += hu2013[s][i]/4
        type_sen2012.append(sen2012_temp)
        type_hu2013.append(hu2013_temp)

    # print(set_sen2012, set_hu2013, type_sen2012, type_hu2013)
    
    import numpy as np

    fig, ax = plt.subplots()

    index = np.arange(9)
    bar_width = 0.35
    rect1 = ax.bar(index, type_sen2012, width=bar_width, label='Sen2012')
    rect2 = ax.bar(index + bar_width, type_hu2013, width=bar_width, label='Hu2013')

    ax.set_xlabel('motion type')
    ax.set_ylabel('Q Score')
    ax.set_xticks(index + bar_width / 2)
    ax.set_xticklabels(('complex', 'handheld', 'lolm', 'losm', 'multiview', 'nrm', 'occlusion', 'solm', 'sosm'), rotation=40)
    ax.legend()

    for xx, yy in zip(index, type_sen2012):
        plt.text(xx, yy+0.1, str(yy)[:5], ha='center')
    
    for xx, yy in zip(index + bar_width, type_hu2013):
        plt.text(xx, yy+0.1, str(yy)[:5], ha='center')

    fig.tight_layout()
    plt.show()