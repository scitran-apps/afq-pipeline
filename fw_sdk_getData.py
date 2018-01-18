#! /usr/bin/env python

import os
import json
import re
from pprint import pprint as pp
import flywheel

from fw_sdk_functions import get_diffusion_acquisitions, get_anatomical_acquisitions


################################################################################
# Read in config file

CONFIG_FILE = os.path.join(FLYWHEEL_BASE, 'config.json')

if not os.path.exists(CONFIG_FILE):
    raise Exception('Config file (%s) does not exist' % CONFIG_FILE)

with open(CONFIG_FILE, 'r') as cf:
    config_content = json.loads(cf)

# Get apikey and session ID number from config file
api_key = str(config_content['inputs']['api_key']['key'])

# Get the analysis
analysis = fw.get_analysis(analysis_id)

if analysis['parent']['type'] != 'session':
    raise ValueError('Parent must be session container.')

# Get the session ID from the analysis and get the acquisitions
session_id = analysis['parent']['id']


################################################################################
# API KEY

print("Creating SDK client...")
fw = flywheel.Flywheel(api_key)
print('Done')


################################################################################
# CREATE DIRECTORIES

FLYWHEEL_BASE = os.environ['FLYWHEEL']
INPUT_DIR = os.path.join(FLYWHEEL_BASE, 'input')

ANAT_DIR = os.path.join(INPUT_DIR, 'anatomical')
NIFTI_1_DIR = os.path.join(INPUT_DIR, 'NIFTI_1')
NIFTI_2_DIR = os.path.join(INPUT_DIR, 'NIFTI_2')

BVEC_1_DIR = os.path.join(INPUT_DIR, 'BVEC_1')
BVEC_2_DIR = os.path.join(INPUT_DIR, 'BVEC_2')

BVAL_1_DIR = os.path.join(INPUT_DIR, 'BVAL_1')
BVAL_2_DIR = os.path.join(INPUT_DIR, 'BVAL_2')

if not os.path.exists(INPUT_DIR):
    os.mkdir(INPUT_DIR)
if not os.path.exists(ANAT_DIR):
    os.mkdir(ANAT_DIR)
if not os.path.exists(NIFTI_1_DIR):
    os.mkdir(NIFTI_1_DIR)
if not os.path.exists(NIFTI_2_DIR):
    os.mkdir(NIFTI_2_DIR)
if not os.path.exists(BVEC_1_DIR):
    os.mkdir(BVEC_1_DIR)
if not os.path.exists(BVEC_2_DIR):
    os.mkdir(BVEC_2_DIR)
if not os.path.exists(BVAL_1_DIR):
    os.mkdir(BVAL_1_DIR)
if not os.path.exists(BVAL_2_DIR):
    os.mkdir(BVAL_2_DIR)


################################################################################
## GET ACQUISITIONS

# Get the acquisitions
acquisitions = fw.get_session_acquisitions(session_id)

diffusion_acquisition_label = config_content['config']['diffusion_acquisition_label']
anatomical_acquisition_label = config_content['config']['anatomical_acquisition_label']

# Get only the acquistions that match the label
diffusion_acquisitions = get_diffusion_acquisitions(acquisitions, diffusion_acquisition_label)

# Check diffusion acquisitions
if len(diffusion_acquisitions) > 2 or len(diffusion_acquisitions) < 1:
    raise ValueError('Required number of diffusion acquisitions could not be found!')
else:
    for d in diffusion_acquisitions:
        print('Found ' + d.get('label'))

# Check anatomical acquisitions
if config_content['config']['align_to_anatomical'] == True:
    anatomical_acquisitions = get_anatomical_acquisitions(acquisitions, anatomical_acquisition_label)

    # Sanity check for number of acquisitions
    if len(anatomical_acquisitions) != 1:
        raise ValueError('Required number of anatomical acquisitions could not be found!')
    else:
        print('Found ' + anatomical_acquisitions[0].get('label'))
else:
    print('Align to anatomical set to false. Not searching for anatomical acquisitions.')


################################################################################
## DOWNLOAD FILES

if diffusion_acquisitions[0]:
    for f in diffusion_acquisitions[0]['files']:
        if f['type'] == 'nifti':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(diffusion_acquisitions[0]['_id'],
                                              f['name'],
                                              os.path.join(NIFTI_1_DIR, f['name']))
        if f['type'] == 'bvec':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(diffusion_acquisitions[0]['_id'],
                                              f['name'],
                                              os.path.join(BVEC_1_DIR, f['name']))
        if f['type'] == 'bval':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(diffusion_acquisitions[0]['_id'],
                                              f['name'],
                                              os.path.join(BVAL_1_DIR, f['name']))

if diffusion_acquisitions[1]:
    for f in diffusion_acquisitions[1]['files']:
        if f['type'] == 'nifti':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(diffusion_acquisitions[1]['_id'],
                                              f['name'],
                                              os.path.join(NIFTI_2_DIR, f['name']))
        if f['type'] == 'bvec':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(diffusion_acquisitions[1]['_id'],
                                              f['name'],
                                              os.path.join(BVEC_2_DIR, f['name']))
        if f['type'] == 'bval':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(diffusion_acquisitions[1]['_id'],
                                              f['name'],
                                              os.path.join(BVAL_2_DIR, f['name']))

# Download Anatomical Files
if config_content['config']['align_to_anatomical'] == True:
    for f in anatomical_acquisitions[0]['files']:
        if f['type'] == 'nifti':
            pp('Downloading ' + f['name'] + ' ...')
            fw.download_file_from_acquisition(anatomical_acquisitions[0]['_id'],
                                              f['name'],
                                              os.path.join(ANAT_DIR, f['name']))


###############################################################################
# TODO: Check downloads
