#!/bin/bash


#run interval saving script, save intervals to stimuli/interval;s
/Applications/Praat.app/Contents/MacOS/Praat --run "save_intervals_to_wavs.Praat"

#scale intensity of all files just created, save in stimuli/norm_intervals
/Applications/Praat.app/Contents/MacOS/Praat --run "scale_intensity.Praat"

#generate triplets.csv-contained in stimulus_construction


#run create_stimlist.py to create an optomized stimlist
python create_stimlist.py

#change stimlist to correct format, save to concatenation folder.
Rscript reformat_stimlist.R 
 
 
#use reformatted stimlist to run concatenation file on normalized stimuli 
/Applications/Praat.app/Contents/MacOS/Praat --run "concatenation_of_tripets.Praat"


#convert all new triplet files to .mp3 and .ogg using sox 
cd stimuli
for i in *.wav ; do sox "$i" "$(basename -s .wav "$i").mp3"; done
for i in *.wav ; do sox "$i" "$(basename -s .wav "$i").ogg"; done

#



<<<<<<< HEAD
=======

>>>>>>> 34123c89b3a299163911dcbb37d168188b2c1935
