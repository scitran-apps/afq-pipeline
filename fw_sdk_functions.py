import os
import sys
from pprint import pprint as pp

#### Define functions

def get_diffusion_acquisitions(acquisitions, diffusion_acquisition_label):
    """
    TODO: Use parameters during autodetect to find the best scans to use.
    """

    if diffusion_acquisition_label == 'autodetect':
        print('Attempting to autodetect diffusion acquisitions')

        # Find diffusion acquisitions by finding acquisitions with a diffusion type and a bvec file
        diffusion_acquisitions = [ x for x in acquisitions
                                  if [y for y in x['files']
                                      if y.has_key('measurements') and 'diffusion' in y['measurements']]
                                  and [z for z in x['files']
                                       if z['type'] == 'bvec' or z['type'] == 'bval'] ]

        #  Determine acquisitions to use based on label fuzzy matching
        if len(diffusion_acquisitions) == 0:
            return diffusion_acquisitions

        if len(diffusion_acquisitions) > 2:
            print('Found %s diffusion acquisitions - trying to determine if we have a usable set based on label.'
                  % (len(diffusion_acquisitions)))
            labels = [x['label'] for x in diffusion_acquisitions]

            d_labels = labels
            for l in labels:
                this_label = d_labels.pop(d_labels.index(l))
                for dl in d_labels:
                    ratio = fuzz.ratio(this_label, dl)
                    print(str(ratio))
                    if ratio > 90:
                        label_1, label_2 = this_label, dl
            print('Matched %s and %s!' % (label_1, label_2))

            if label_1 and label_2:
                diffusion_acquisition = [ x for x in acquisitions if x['label'] == label_1 or x['label'] == label_2 ]

    else:
        diffusion_acquisitions = [x for x in acquisitions if x['label'].find(diffusion_acquisition_label) != -1]

    return diffusion_acquisitions


def get_anatomical_acquisitions(acquisitions, anatomical_acquisition_label):
    """
    TODO: Use parameters during autodetect to find the best scan to use.
    """

    if anatomical_acquisition_label == 'autodetect':
        print('Attempting to autodetect anatomical acquisitions')

        # Find diffusion acquisitions by finding acquisitions with a diffusion type and a bvec file
        anatomical_acquisitions = [ x for x in acquisitions
                                  if [y for y in x['files']
                                      if y.has_key('measurements') and 'anatomy_t1' in y['measurements']]
                                  and [z for z in x['files']
                                       if z['type'] == 'nifti' ] ]
    else:
        anatomical_acquisitions = [x for x in acquisitions if x['label'].find(anatomical_acquisition_label) != -1]

    return anatomical_acquisitions
