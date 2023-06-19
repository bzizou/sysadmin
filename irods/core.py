#
# iRods python rules plugin inspired from multiple sources:
#
# https://indico.in2p3.fr/event/23075/contributions/90180/attachments/61890/84544/08_Moteur_Regles.pdf
# https://slides.com/jasoncoposky/cines-2020-rule-engine-plugins
# https://github.com/irods/irods_training/blob/main/beginner/irods_beginner_training_2019.pdf
# https://github.com/irods/irods_rule_engine_plugin_python

import pycurl
import json
import re
import exifread
import session_vars
import os
import subprocess
from genquery import *
from io import BytesIO


# Function to extract exif of an image and update metadata of the file
def exif_python_rule(rule_args, callback, rei):
  file_path = str(rule_args[0])
  obj_path = str(rule_args[1])
  exiflist = []
  with open(file_path, 'rb') as f:
    tags = exifread.process_file(f, details=False)
    for (k, v) in tags.iteritems():
      if k not in ('JPEGThumbnail', 'TIFFThumbnail', 'Filename', 'EXIF MakerNote'):
        exifpair = '{0}={1}'.format(k, v)
        exiflist.append(exifpair)
  exifstring = '%'.join(exiflist)
  #callback.writeLine('serverLog', 'Exifstring={}'.format(exifstring))
  callback.add_metadata_to_objpath(exifstring, obj_path, '-d')
  callback.writeLine('serverLog', 'PYTHON EXIF RULE complete')

# Rule executed after a Put
def acPostProcForPut(rule_args, callback, rei):
  sv = session_vars.get_map(rei)
  phypath = sv['data_object']['file_path']
  objpath = sv['data_object']['object_path']
  resource = sv['data_object']['resource_name'] # More keys can be found into plugins/api/src/get_file_descriptor_info.cpp

  # EXIF processing rule
  # If the file ends with .jpg, the EXIF data is extracted
  # and imported into the metadata of the file
  if phypath[-4:] == '.jpg' or phypath[-4:] == '.JPG':
    callback.writeLine('serverLog', 'Exec EXIF Python Rule')
    remote_rule = "exif_python_rule('%s', '%s')" % \
                  (phypath, objpath)
    location = get_resource_location(callback,resource)
    # Exclude backup resources here (no processing on data for thoses resources)
    exclude = False
    for res in EXCLUDED_RESOURCES:
      if location == res:
        exclude = True
    if exclude : 
      callback.writeLine('serverLog', 'No EXIF processing for {}'.format(location))
    # Send the processing on the server hosting the data
    else:
      callback.writeLine('serverLog', 'Processing EXIF rule on {}'.format(location))
      callback.remoteExec(location, '', remote_rule, '')

  callback.writeLine('serverLog', 'PYTHON - acPostProcForPut() complete')
