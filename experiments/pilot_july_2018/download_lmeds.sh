#!/bin/bash

# This experiment requires a specific version of the Geomphon fork of LMEDS
# (release v2.5v). This release has been registered with Zenodo and has
# DOI and a permanent URL.

wget -O LMEDS.zip \
 https://zenodo.org/record/1343599/files/geomphon/LMEDS_v-v2.5V.zip?download=1\
  && unzip LMEDS.zip \
  && rm LMEDS.zip
