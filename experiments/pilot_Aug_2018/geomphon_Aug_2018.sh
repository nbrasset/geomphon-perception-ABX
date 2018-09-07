#!/bin/bash


#run interval saving script, save intervals to stimuli/interval;s
/Applications/Praat.app/Contents/MacOS/Praat --run "save_intervals_to_wavs.Praat"

#scale intensity of all files just created, save in stimuli/norm_intervals
/Applications/Praat.app/Contents/MacOS/Praat --run "scale_intensity.Praat"

#run create_stimlist.py to create a stimlist 
#this script saves stimlist in correct format  to concatenation folder. 
#script also saves new sequence file based on this stimlst to LMEDs folders for English and french

#use stimlist to run concatenation file on normalized stimuli 
/Applications/Praat.app/Contents/MacOS/Praat --run "concatenation_of_tripets.Praat"

#convert all new triplet files to .mp3 and .ogg using sox 
cd stimuli
for i in *.wav ; do sox "$i" "$(basename -s .wav "$i").mp3"; done
for i in *.wav ; do sox "$i" "$(basename -s .wav "$i").ogg"; done

#



<<<<<<< HEAD
=======

>>>>>>> 34123c89b3a299163911dcbb37d168188b2c1935
