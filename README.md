# Geomphon perception experiments

`experiments/pilot_july_2018` contains everything (scripts, stimuli, raw anonymized data) from the July 2018 pilot. To do the Python preprocessing on this data, change to that directory and do

```
make preprocess
```

To get this pilot ready for re-deployment (download the right version of LMEDS, put all the files in the right place in a single directory), do

```
make deploy
```

This will create a folder called `deploy` that can be copied to the server containing the pilot, ready for use.

