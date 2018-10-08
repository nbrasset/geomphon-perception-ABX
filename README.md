# Geomphon perception experiments

This repository contains a set of experiments, under `experiments`, each with their own independent code requirements. Code shared between the experiments is found under `shared`

## July 2018 pilot

Found under `experiments/pilot_july_2018`.

The goal of this pilot was to collect some ABX data and develop basic tools for preprocessing data, as well as start testing the models we plan to use to analyse the data. The folder contains everything (scripts, stimuli, raw anonymized data) from this July 2018 pilot. To do the Python preprocessing on the resulting data, change to that directory and do

```
make preprocess
```

All the experimental files (scripts and stimuli) are in the repertoire (in Git LFS on Github's servers), and the experiment runs on a public Zenodo-versioned fork of LMEDS with a DOI. To get this pilot ready for re-deployment (download the right version of LMEDS, put all the files in the right place in a single directory), do

```
make deploy
```

This will create a folder called `deploy` that can be copied to the server containing the pilot, ready for use.

```
export TIMIT_FOLDER=[[TIMIT CORPUS FOLDER CONTAINING 'TRAIN/' AND 'TEST/']]
export TIMIT_AUDIO_EXTENSION=[[EXTENSION FOR WAV FILES CONVERTED FROM NIST SPHERE FORMAT (e.g., .riff)]]
make stimuli/item_meta_information_with_distances.csv
```

This will calculate various different kinds of acoustic distances. The original TIMIT wav files are needed (the stimuli in this experiment were constructed from TIMIT) for a not-very-important reason: we calculate the FFT and then normalize the resulting features based on the whole set of TIMIT files from which the stimuli were drawn - not just the isolated stimuli - which should make them more accurate. It also shouldn't make too much difference. In order to do otherwise, you would need to make a few changes, including converting the stimuli into wav format from ogg/mp3.

### Requirements for the July 2018 pilot

**Python**

```
- standard_format: pip install git+git://github.com/geomphon/standard-format.git@v0.1#egg=standard_format
- Custom fork of python_speech_features: pip install git+git://github.com/geomphon/python_speech_features_geomphon.git@v1.0GEOMPH#egg=python_speech_features
- pandas==0.23.0
- fastdtw==0.3.2
- numpy
- scipy
```

**R**

```
- magrittr
- readr
- tidyr
- dplyr
```

### Requirements for the August 2018 pilot


**Python**

```
- h5py
- numpy
- pandas
- cython (dependency for ABXpy that's not correctly dealt with)
- ABXpy v0.4: pip install git+git://github.com/bootphon/ABXpy.git@v0.4.1#egg=ABXpy
- textgrid: pip install git+git://github.com/kylebgorman/textgrid.git

```
