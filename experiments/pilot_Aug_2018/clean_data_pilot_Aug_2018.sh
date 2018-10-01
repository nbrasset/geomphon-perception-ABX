#!/bin/bash


#run anonymization script 
## FIRST ARGUMENT: the folder containing the raw LMEDS data, ending in ".csv"
## SECOND ARGUMENT: the folder to output to; this folder will be created if it doesn't
##### already exist, but it will *not* be cleaned out if it already exists,
##### so be careful
## THIRD ARGUMENT: The anonymization CSV

python anonymize_lmeds_data_filenames.py \
"/Users/post-doc/Desktop/output"\
 "/Users/post-doc/Desktop/anon_output" \
 "/Users/post-doc/Desktop/anon_key.csv"

#Run clean_output_pilot_Aug_2018.py  in python 3 
#this script takes as input a directory of raw LMEDS data files  \
#*WITH nested subdirectories* for English and French data. 

#takes the following arguments: 
###folderpath = sys.argv[1]
###results_filename = sys.argv[2]
###presurvey_filename = sys.argv[3]
###postsurvey_filename = sys.argv[4]
###postsurvey2_filename = sys.argv[5]

python clean_output_pilot_Aug_2018.py "/Users/Desktop/post-doc/data_and_analysis/anon_output"
"/Users/post-doc/data_and_analysis/results.csv" "/Users/post-doc/data_and_analysis/presurvey.csv"
"/Users/post-doc/data_and_analysis/postsurvey.csv" "/Users/post-doc/data_and_analysis/posturvey2.csv"