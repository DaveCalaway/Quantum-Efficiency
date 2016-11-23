#!/usr/bin/python
# disable led: https://goo.gl/b2yRoh
# The programs run on RBp.
# It call the folder's name and take a bayer raw.
# After terminated, it makes a zip.
# Davide Gariselli V0.1 git: https://goo.gl/pFs9TY

from __future__ import (
    unicode_literals,
    absolute_import,
    print_function,
    division,
    )

import os
import io
import shutil
import numpy as np
from numpy.lib.stride_tricks import as_strided
# Getch on python https://goo.gl/jeLuDv
from getch import getch
from time import sleep
import picamera
                # NDF0.5 : from 400(26) nm to 580nm(240)
                    # NDF0.6 ISO145 -> 72
                    #
                # cambio filtro 581 to 591
                # NDF0.5: from 595 to 770nm brucia
                # cambio filtro 775 to 800nm
# good ISO value for NDF0.5 : from 400(26) nm to 580nm(240)
# ISO: https://goo.gl/lLJj2V
#iso = 100

def take(nome_img):
    stream = io.BytesIO()
    with picamera.PiCamera() as camera:
        #camera.iso = iso
        # Capture the image, including the Bayer data
        camera.capture(stream, format='jpeg', bayer=True)

    # Extract the raw Bayer data from the end of the stream, check the
    # header and strip if off before converting the data into a numpy array

    data = stream.getvalue()[-6404096:]
    assert data[:4] == 'BRCM'
    data = data[32768:]
    data = np.fromstring(data, dtype=np.uint8)

    # The data consists of 1952 rows of 3264 bytes of data. The last 8 rows
    # of data are unused (they only exist because the actual resolution of
    # 1944 rows is rounded up to the nearest 16). Likewise, the last 24
    # bytes of each row are unused (why?). Here we reshape the data and
    # strip off the unused bytes

    data = data.reshape((1952, 3264))[:1944, :3240]

    # Horizontally, each row consists of 2592 10-bit values. Every four
    # bytes are the high 8-bits of four values, and the 5th byte contains
    # the packed low 2-bits of the preceding four values. In other words,
    # the bits of the values A, B, C, D and arranged like so:
    #
    #  byte 1   byte 2   byte 3   byte 4   byte 5
    # AAAAAAAA BBBBBBBB CCCCCCCC DDDDDDDD AABBCCDD
    #
    # Here, we convert our data into a 16-bit array, shift all values left
    # by 2-bits and unpack the low-order bits from every 5th byte in each
    # row, then remove the columns containing the packed bits

    data = data.astype(np.uint16) << 2
    for byte in range(4):
        data[:, byte::5] |= ((data[:, 4::5] >> ((4 - byte) * 2)) & 0b11)
    data = np.delete(data, np.s_[4::5], 1)

    # Now to split the data up into its red, green, and blue components. The
    # Bayer pattern of the OV5647 sensor is BGGR. In other words the first
    # row contains alternating green/blue elements, the second row contains
    # alternating red/green elements, and so on as illustrated below:
    #
    # GBGBGBGBGBGBGB
    # RGRGRGRGRGRGRG
    # GBGBGBGBGBGBGB
    # RGRGRGRGRGRGRG
    #
    # Please note that if you use vflip or hflip to change the orientation
    # of the capture, you must flip the Bayer pattern accordingly

    #rgb = np.zeros(data.shape + (3,), dtype=data.dtype)
    #rgb[1::2, 0::2, 0] = data[1::2, 0::2] # Red
    #rgb[0::2, 0::2, 1] = data[0::2, 0::2] # Green
    #rgb[1::2, 1::2, 1] = data[1::2, 1::2] # Green
    #rgb[0::2, 1::2, 2] = data[0::2, 1::2] # Blue

    data = (data >> 2).astype(np.uint8)
    Max = np.amax(data)
    if Max>254:
        #x=1
        print('Image burned! You should use a great filter.')
        print('Max: {}'.format(Max))
        take(nome_img);
    else:
        #if x==1:
        #    name_img = raw_input('Da dove riparto?: ')
        #    x=0
        print('name: {} Max: {}'.format(nome_img,Max))
        # smallest output format: https://goo.gl/N7EeEv
        nome_img=str(nome_img)
        np.save(nome_img,data)
    return
# ----------------------------------------------


# ----- Main's program -----
print ('Raspberry script')
# make a dir
dirName = raw_input('Enter name s dir: ')
os.makedirs(dirName)
print ("Directory created.")
os.chdir("/home/pi/"+dirName)
nome_img = raw_input('Starter number: ')
print ('SPACEBAR for shoot & ESC for terminate')
while True:
    key = getch()
    key = ord(key)
    if key == 27: #ESC
        break
    if key == 32: #spacebar
        # Let the camera warm up for a couple of seconds
        sleep(2)
        take(nome_img);
        nome_img=int(nome_img)
        nome_img=nome_img+5
        print ('scattato.')
print ("Acquisizione completata.")
shutil.make_archive('/home/pi/'+dirName, 'zip', '/home/pi/'+dirName)
print ("Zipped.")
