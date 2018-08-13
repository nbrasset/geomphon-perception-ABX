# Geomphon perception experiments

This repository contains a set of experiments, under `experiments`, each with their own independent code requirements. Code shared between the experiments is found under `shared`

## July 2018 pilot

Found under `experiments/pilot_july_2018`.

The goal of this pilot was to collect some ABX data and develop basic tools for preprocessing data, as well as start testing the models we plan to use to analyse the data. The folder contains everything (scripts, stimuli, raw anonymized data) from this July 2018 pilot. To do the Python preprocessing on this data, change to that directory and do

```
make preprocess
```

To get this pilot ready for re-deployment (download the right version of LMEDS, put all the files in the right place in a single directory), do

```
make deploy
```

This will create a folder called `deploy` that can be copied to the server containing the pilot, ready for use.

<<<<<<< HEAD
### Python requirements for the July 2018 pilot
=======
### Python requirements
>>>>>>> eb844e0349849d9cf3ff973bfb6e78b56ba882e8

```
- pandas
- numpy
```

