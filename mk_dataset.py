"""
This is the data dump module.
"""

__version__ = '1.1'
__author__ = 'Saul Alonso-Monsalve'
__email__ = "saul.alonso.monsalve@cern.ch"

import mnist
import numpy as np
import pickle as pk
import zlib
import os
import argparse


#
# parser
#

print('')
print(' Dataset builder ' + __version__)
print('---------------------')
print('')

parser = argparse.ArgumentParser(description='Build dataset.')
parser.add_argument('--height',  type=int, default=32,      nargs=1, required=False, help='an integer for the height')
parser.add_argument('--width',   type=int, default=32,      nargs=1, required=False, help='an integer for the width')
parser.add_argument('--ntrain',  type=int, default=1000000,   nargs=1, required=False, help='an integer for the number of images for training')
parser.add_argument('--ntest',   type=int, default=1000,    nargs=1, required=False, help='an integer for the number of images for testing')
args = parser.parse_args()

#
# configuration
#

n_images_train   = args.ntrain[0]
n_images_test    = args.ntest[0]
height           = args.height[0]
width            = args.width[0]
dataset_name     = 'dataset' + str(height) + 'x' + str(width) + '/'
dir_packing_each = 10000

#
# seed generation
#

y_train = np.random.randint(2, size=n_images_train)
y_test  = np.random.randint(2, size=n_images_test)

Y_train = {}
Y_test  = {}

#counter = 0
dir_index = 0

msg_prefix = 'Building dataset: '
print(msg_prefix, end='\r')
for i in range(n_images_train):
    x = np.random.randn(height,width).astype(np.uint8)
    x = zlib.compress(x.tobytes())
    ID = 'train'+str(i)
    prefix = dataset_name + '/' + str(dir_index) + '/'
    if not os.path.exists(prefix):
        os.makedirs(prefix)
    with open(prefix+ID+'.tar.gz','wb') as fd:
        fd.write(x)
    Y_train[prefix[9:]+ID]=y_train[i]
    dir_index = i // dir_packing_each
    if i%10 == 0:
       print(msg_prefix+str(i), end='\r')
print(msg_prefix + 'Done')

# test
msg_prefix = 'Building testing: '
print(msg_prefix, end='\r')
for i in range(n_images_test):
    x = np.random.randn(height,width).astype(np.uint8)
    x = zlib.compress(x.tobytes())
    ID = 'test'+str(i)
    prefix = dataset_name + '/' + str(dir_index) + '/'
    if not os.path.exists(prefix):
        os.makedirs(prefix)
    with open(prefix+ID+'.tar.gz','wb') as fd:
        fd.write(x)
    Y_test[prefix[9:]+ID]=y_test[i]
    dir_index = (i+n_images_train) // dir_packing_each
    if i%10 == 0:
       print(msg_prefix+str(i), end='\r')
print(msg_prefix + 'Done')

#
# dump data
#

msg_prefix = 'Saving labels: '
print(msg_prefix, end='\r')
with open(dataset_name+'labels.p','wb') as fd:
    pk.dump([Y_train, Y_test], fd)

print(msg_prefix + 'Done')
print('')

