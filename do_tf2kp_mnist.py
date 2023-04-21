# Copyright 2019 Uber Technologies, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

import os
import time
import sys
import argparse
import socket
from   snakebite.client import Client
from   urllib.parse import urlparse
import tensorflow as tf
from   tensorflow.keras.callbacks import Callback
import horovod.tensorflow.keras as hvd
import pickle as pk
from   data_generator import DataGenerator


# do_cache: Copy from hdfs to local
def do_cache(cache_path):
    # cache_path:
    cache_parts = cache_path.split(':')
    if len(cache_parts) < 2:
        return 'nocache', ''

    # param to choose if we want local copy or not
    if len(cache_parts) == 2:
       cache_mode = 'hdfs2local'
       hdfs_dir   = cache_parts[0]
       cache_dir  = cache_parts[1]
    else:
       cache_mode = cache_parts[0]
       hdfs_dir   = cache_parts[1]
       cache_dir  = cache_parts[2]

    # add the container name at the end cache_dir
    container_name = os.uname()[1]
    cache_dir = cache_dir + "/" + container_name

    status = os.system("mkdir -p " + cache_dir)
    can_continue_with_cache = os.WIFEXITED(status) and (os.WEXITSTATUS(status) == 0)
    if not can_continue_with_cache:
        return 'nocache', ''

    # list of files to copy in local
    hdfs_list = cache_dir + "/list.txt"
    with open(hdfs_list, "w") as f:
        f.write('labels.p\n')
        for item in partition['train']:
            fname = '/'.join(item.split('/')[1:]) + '.tar.gz\n'
            f.write(fname[1:])
        f.close()

    # copy from hdfs to local
    os_cmd = "hdfs/hdfs-cp.sh" + " " + cache_mode + " "  + hdfs_dir + " " + hdfs_list + " " + cache_dir
    status = os.system(os_cmd)
    can_continue_with_cache = os.WIFEXITED(status) and (os.WEXITSTATUS(status) == 0)
    if not can_continue_with_cache:
        return 'nocache', ''

    # return cache_mode, cache_dir
    return cache_mode, cache_dir


# do_read_lables: Read file data
def do_read_labels(file_uri):
    o = urlparse(file_uri)
    t = '/tmp/image.dat.' + str(os.getpid())

    try:
      if o.scheme != 'hdfs':
         with open(o.path, 'rb') as fd:
              labels_train, labels_test = pk.load(fd)
      else:
         if os.path.exists(t):
            os.remove(t)
         client = Client(o.hostname, o.port)
         for f in client.copyToLocal([o.path], t):
              if f['result'] == True:
                 with open(t, 'rb') as fd:
                      labels_train, labels_test = pk.load(fd)
                 os.remove(t)
              else:
                 print('File ' + f['path'] + ' NOT copied because "' + str(f['error']) + '", sorry !')
                 return None, None
    except:
      print('Exception ' + str(sys.exc_info()[0]) + ' on file ' + file_uri)
      return None, None

    return labels_train, labels_test


class TimingCallback(Callback):
  def __init__(self):
    self.logs=[]
  def on_epoch_begin(self, epoch, logs={}):
    self.starttime=time.time()
  def on_epoch_end(self, epoch, logs={}):
    self.logs.append(time.time()-self.starttime)


#
# main
#

# manually specify the GPUs to use
os.environ["CUDA_DEVICE_ORDER"]="PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"]="0,1"

# arguments
parser = argparse.ArgumentParser(description='Build dataset.')
parser.add_argument('--height',  type=int, default=32,              nargs=1, required=False, help='an integer for the height')
parser.add_argument('--width',   type=int, default=32,              nargs=1, required=False, help='an integer for the width')
parser.add_argument('--convs',   type=int, default='1',             nargs=1, required=False, help='number of conv layers')
parser.add_argument('--iters',   type=int, default='1000',          nargs=1, required=False, help='number of iterations per epoch')
parser.add_argument('--path',    type=str, default='dataset32x32',  nargs=1, required=False, help='dataset path')
parser.add_argument('--cache',   type=str, default='nocache',       nargs=1, required=False, help='dataset cache path')
args = parser.parse_args()

# configuration
height           = int(args.height[0])
width            = int(args.width[0])
convs            = int(args.convs[0])
iters            = int(args.iters[0])
images_path      = args.path[0]
cache_path       = args.cache[0]
cache_mode       = args.cache[0]
channels         = 1
batch_size       = 32
shuffle          = True

# train and validation params
TRAIN_PARAMS = {
                 'height':     height,
                 'width':      width,
                 'channels':   channels,
                 'batch_size': 32,
                 'cache_mode': cache_mode,
                 'images_uri': images_path,
                 'shuffle':    shuffle
               }

# resources
hostname  = socket.gethostname()
local_ip  = socket.gethostbyname(hostname)
file_name = images_path + '/labels.p'

labels_train, labels_test = do_read_labels(file_name)
if labels_train == None:
    print("ERROR: file " + file_name + " couldn't be opened on " + local_ip)
    sys.exit("Exit.")

nevents=len(list(labels_train.keys()))
partition = {'train' : list(labels_train.keys()), 'validation' : list(labels_test.keys())}

# do_cache: copy from hdfs to local or not...
cache_mode, cache_dir = do_cache(cache_path)
TRAIN_PARAMS['cache_mode'] = cache_mode
if cache_mode != 'nocache':
    TRAIN_PARAMS['images_uri'] = cache_dir

'''
************** GENERATORS **************
'''

training_generator   = DataGenerator(**TRAIN_PARAMS).generate(labels_train, partition['train'],      True)
validation_generator = DataGenerator(**TRAIN_PARAMS).generate(labels_test,  partition['validation'], True)

# Horovod: initialize Horovod.
hvd.init()

print('[hvd] local_ip:%s, local_rank:%d' % (local_ip, hvd.local_rank()))

# Horovod: pin GPU to be used to process local rank (one GPU per process)
gpus = tf.config.experimental.list_physical_devices('GPU')
for gpu in gpus:
    tf.config.experimental.set_memory_growth(gpu, True)
if gpus:
    tf.config.experimental.set_visible_devices(gpus[hvd.local_rank()], 'GPU')

# Build model...
input_shape = [height,width,channels]
img_input = tf.keras.layers.Input(shape=input_shape, name='input')
x = tf.keras.layers.Conv2D(32, [3, 3], activation='relu')(img_input)
for i in range(convs):
    x = tf.keras.layers.Conv2D(64, [3, 3], activation='relu', padding='same')(x)
    if convs==1:
        x = tf.keras.layers.MaxPooling2D(pool_size=(2, 2))(x)
    x = tf.keras.layers.Dropout(0.25)(x)
x = tf.keras.layers.Flatten()(x)
x = tf.keras.layers.Dense(128, activation='relu')(x)
x = tf.keras.layers.Dropout(0.5)(x)
x = tf.keras.layers.Dense(10, activation='softmax')(x)
mnist_model = tf.keras.models.Model(inputs=img_input, outputs=x, name='my_model')
mnist_model.summary()

# Horovod: adjust learning rate based on number of GPUs.
opt = tf.optimizers.Adam(0.001 * hvd.size())

# Horovod: add Horovod DistributedOptimizer.
opt = hvd.DistributedOptimizer(opt)

# Horovod: Specify `experimental_run_tf_function=False` to ensure TensorFlow
# uses hvd.DistributedOptimizer() to compute gradients.
mnist_model.compile(loss=tf.losses.SparseCategoricalCrossentropy(),
                    optimizer=opt,
                    metrics=['accuracy'],
                    experimental_run_tf_function=False)

callbacks = [
    # Horovod: broadcast initial variable states from rank 0 to all other processes.
    # This is necessary to ensure consistent initialization of all workers when
    # training is started with random weights or restored from a checkpoint.
    hvd.callbacks.BroadcastGlobalVariablesCallback(0),

    # Horovod: average metrics among workers at the end of every epoch.
    #
    # Note: This callback must be in the list before the ReduceLROnPlateau,
    # TensorBoard or other metrics-based callbacks.
    hvd.callbacks.MetricAverageCallback(),

    # Horovod: using `lr = 1.0 * hvd.size()` from the very beginning leads to worse final
    # accuracy. Scale the learning rate `lr = 1.0` ---> `lr = 1.0 * hvd.size()` during
    # the first three epochs. See https://arxiv.org/abs/1706.02677 for details.
    hvd.callbacks.LearningRateWarmupCallback(warmup_epochs=3, verbose=1),
]

# Horovod: save checkpoints only on worker 0 to prevent other workers from corrupting them.
if hvd.rank() == 0:
    callbacks.append(tf.keras.callbacks.ModelCheckpoint('./checkpoint-{epoch}.h5'))
    cb = TimingCallback()
    callbacks.append(cb)

# Horovod: write logs on worker 0.
verbose = 1 if hvd.rank() == 0 else 0

# Train the model.
# Horovod: adjust number of steps based on number of GPUs.
#mnist_model.fit(dataset, steps_per_epoch=10 // hvd.size(), callbacks=callbacks, epochs=24, verbose=verbose)
steps_per_epoch=nevents//batch_size

steps_per_epoch_param = 1
if iters > hvd.size():
    steps_per_epoch_param = iters // hvd.size()

mnist_model.fit(x=training_generator, steps_per_epoch=steps_per_epoch_param, callbacks=callbacks, epochs=1, verbose=verbose)

# update output.txt
if hvd.rank() == 0:
    with open('output.txt', 'a') as fd:
        fd.write(str(height)+'x'+str(width)+' '+str(convs)+' '+str(hvd.size()) + ' '+str(32150.*cb.logs[0]/iters)+' s\n')

