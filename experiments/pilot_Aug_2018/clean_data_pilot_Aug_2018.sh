#!/bin/bash

##########################
#first anonymize the data#
##########################

#run anonymization script 
## FIRST ARGUMENT: the folder containing the raw LMEDS data, ending in ".csv"
## SECOND ARGUMENT: the folder to output to; this folder will be created if it doesn't
##### already exist, but it will *not* be cleaned out if it already exists,
##### so be careful
## THIRD ARGUMENT: The anonymization CSV to be created. 

python anonymize_lmeds_data_filenames.py \
"/Users/post-doc/Desktop/output" \
"/Users/post-doc/Desktop/anon_output" \
"/Users/post-doc/Desktop/anon_key.csv"



##################################
#divide output into results files#
##################################

#Run clean_output_pilot_Aug_2018.py #      FIXME check E's python version compatibility for Docker
#this script takes as input a directory of anonymized LMEDS data files  \
#*WITH nested subdirectories* for English and French data. 

#takes the following arguments: 
###folderpath = sys.argv[1]
###results_filename = sys.argv[2]
###presurvey_filename = sys.argv[3]
###postsurvey_filename = sys.argv[4]
###postsurvey2_filename = sys.argv[5]

python clean_output_pilot_Aug_2018.py "/Users/post-doc/Desktop/anon_output" \
"/Users/post-doc/Desktop/results.csv" "/Users/post-doc/Desktop/presurvey.csv" \
"/Users/post-doc/Desktop/postsurvey.csv" "/Users/post-doc/Desktop/posturvey2.csv"