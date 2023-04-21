"""
This is the generator module.
"""

__version__ = '1.1'
__author__ = 'Saul Alonso-Monsalve'
__email__ = "saul.alonso.monsalve@cern.ch"

import numpy as np
import zlib
from string import digits

class DataGenerator(object):

    'Generates data for Keras'

    '''
    Initialization function of the class
    '''
    def __init__(self, height=28, width=28, channels=1, batch_size=32, images_path = '/', shuffle=True):
        'Initialization'
        self.height = height
        self.width = width
        self.channels = channels
        self.batch_size = batch_size
        self.images_path = images_path
        self.shuffle = shuffle
 
    '''
    Goes through the dataset and outputs one batch at a time.
    ''' 
    def generate(self, labels, list_IDs, yield_labels=True):
        'Generates batches of samples'

        # Infinite loop
        while 1:
            # Generate random order of exploration of dataset (to make each epoch different)
            indexes = self.__get_exploration_order(list_IDs)

            # Generate batches
            imax = int(len(indexes)/self.batch_size) # number of batches

            for i in range(imax):
                 # Find list of IDs for one batch
                 list_IDs_temp = [list_IDs[k] for k in indexes[i*self.batch_size:(i+1)*self.batch_size]]

                 # Train, validation
                 X, y = self.__data_generation(labels, list_IDs_temp, yield_labels)

                 yield X, y

    '''
    Generates a random order of exploration for a given set of list_IDs. 
    If activated, this feature will shuffle the order in which the examples 
    are fed to the classifier so that batches between epochs do not look alike. 
    Doing so will eventually make our model more robust.
    '''
    def __get_exploration_order(self, list_IDs):
        'Generates order of exploration'

        # Find exploration order
        indexes = np.arange(len(list_IDs))

        if self.shuffle == True:
            np.random.shuffle(indexes)

        return indexes

    '''
    Outputs batches of data and only needs to know about the list of IDs included 
    in batches as well as their corresponding labels.
    '''
    def __data_generation(self, labels, list_IDs_temp, yield_labels):
        'Generates data of batch_size samples' # X : (n_samples, v_size, v_size, v_size, n_channels)

        # Initialization
        X = np.empty((self.batch_size, self.height, self.width, self.channels), dtype='float32')
        y = np.empty((self.batch_size), dtype = 'float32')
       
        # Generate data
        for i, ID in enumerate(list_IDs_temp):
            # Decompress image into pixel NumPy tensor
            with open(self.images_path + '/'.join(ID.split('/')[1:]) + '.tar.gz', 'rb') as image_file:
                pixels = np.fromstring(zlib.decompress(image_file.read()), dtype=np.uint8, sep='').reshape(self.height, self.width, self.channels)

            # Store volume
            #pixels = np.rollaxis(pixels, 0, 3) # from 'channels_first' to 'channels_last'
            X[i, :, :, :] = pixels

            # get y value
            y_value = labels[ID]
            y[i] = y_value

        # return X and Y (train, validation)
        return X, y

    '''
    Please note that Keras only accepts labels written in a binary form 
    (in a 6-label problem, the third label is writtten [0 0 1 0 0 0]), 
    which is why we need the sparsify function to perform this task, 
    should y be a list of numerical values.
    '''

    def sparsify1(self, y):
        'Returns labels in binary NumPy array'
        return np.array([[1 if y[i] == j else 0 for j in range(10)] for i in range(y.shape[0])])

