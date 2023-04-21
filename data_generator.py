"""
This is the generator module.
"""

__version__ = '1.5'
__author__  = 'Saul Alonso-Monsalve'
__email__   = "saul.alonso.monsalve@cern.ch"


import os
import sys
import zlib
import numpy as np
from   string import digits
from   snakebite.client import Client
from   urllib.parse import urlparse


class DataGenerator(object):

    'Generates data for Keras'

    '''
    Initialization function of the class
    '''
    def __init__(self, height=28, width=28, channels=1, batch_size=32, cache_mode='', images_uri='/', shuffle=True):
        'Initialization'
        self.debug       = False
        self.height      = height
        self.width       = width
        self.channels    = channels
        self.batch_size  = batch_size
        self.shuffle     = shuffle
        self.cache_mode  = cache_mode
        self.images_uri  = images_uri
        o = urlparse(self.images_uri)
        if o.scheme == 'hdfs':
            self.images_path = o.path
            self.client      = Client(o.hostname, o.port)  # images_uri: 'hdfs://10.0.40.19:9600/daloflow/dataset32x32/'
        else:
            self.images_path = images_uri
            self.client      = None

    '''
    Set debug mode True/False
    '''
    def set_debug(self, debug_mode):
        'Do not show or show messages'
        self.debug = debug_mode
        if self.debug == True:
           print(' * Debug mode:  ' + self.debug)
           print(' * Height:      ' + self.height)
           print(' * Width:       ' + self.width)
           print(' * Channels:    ' + self.channels)
           print(' * Batch_size:  ' + self.batch_size)
           print(' * Shuffle:     ' + self.shuffle)
           print(' * Cache mode:  ' + self.cache_mode)
           print(' * Image uri:   ' + self.images_uri)

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
    Get data: local
    '''
    def __get_data_local(self, image_file_name):
        'Get data from local file system path'
        pixels = None

        try:
           with open(image_file_name, 'rb') as image_file:
                pixels = np.fromstring(zlib.decompress(image_file.read()), dtype=np.uint8, sep='').reshape(self.height, self.width, self.channels)
        except:
           if self.debug == True:
              print('Exception ' + str(sys.exc_info()[0]) + ' on file ' + image_file_name)

        return pixels

    '''
    Get data: remote
    '''
    def __get_data_remote(self, image_file_name):
        'Get data from HDFS'
        pixels = None
        if self.client == None:
           return pixels

        try:
           t = '/tmp/image.dat.' + str(os.getpid())
           if os.path.exists(t):
              os.remove(t)
           for f in self.client.copyToLocal([image_file_name], t):
                if f['result'] == True:
                   with open(t, 'rb') as image_file:
                        pixels = np.fromstring(zlib.decompress(image_file.read()), dtype=np.uint8, sep='').reshape(self.height, self.width, self.channels)
                   os.remove(t)
                else:
                   print('File ' + f['path'] + ' NOT copied because "' + str(f['error']) + '", sorry !')
        except:
           if self.debug == True:
              print('Exception ' + str(sys.exc_info()[0]) + ' on file ' + image_file_name)

        return pixels

    '''
    Get data: local or remote
    '''
    def __get_data(self, image_file_name):
        'Get data: local or remote'
        pixels = None
        #print(' * image file name: ' + image_file_name)

        if   self.cache_mode == 'hdfs2local' or self.cache_mode == 'hdfs2local-full':
             pixels = self.__get_data_local(image_file_name)
        elif self.cache_mode == 'nocache':
             pixels = self.__get_data_remote(image_file_name)
        elif self.cache_mode == 'hdfs2local-partial':
             pixels = self.__get_data_local(image_file_name)
             if pixels == None:
                pixels = self.__get_data_remote(image_file_name)
        else:
             print('ERROR: unknown "' + self.cache_mode + '" cache mode')

        return pixels


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
            image_file_name = self.images_path + '/'.join(ID.split('/')[1:]) + '.tar.gz'

            # Read image
            pixels = self.__get_data(image_file_name)

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

