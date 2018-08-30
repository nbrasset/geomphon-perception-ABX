#!/bin/bash


#run interval saving script, save intervals to stimuli/interval;s
/Applications/Praat.app/Contents/MacOS/Praat --run "save_intervals_to_wavs.Praat"

#scale intensity of all files just created, save in stimuli/norm_intervals
/Applications/Praat.app/Contents/MacOS/Praat --run "scale_intensity.Praat"

#run filtering script to get right stim list 
#this script saves stimlist to concatenation folder. 
#script also saves new sequence file based on this stimlst to LMEDs folders for English and french



#use stimlist to run concatenation file on normalized stimuli 
/Applications/Praat.app/Contents/MacOS/Praat --run "concatenation_of_tripets.Praat"

#convert all new triplet files to .mp3 and .ogg using sox 
cd stimuli
for i in *.wav ; do sox "$i" "$(basename -s .wav "$i").mp3"; done
for i in *.wav ; do sox "$i" "$(basename -s .wav "$i").ogg"; done

#move all the newly created .ogg and .mp3 files to where they need to be in the two separate LMEDs folders 
cd ..

cp stimuli/*.ogg LMEDS_master/tests/geomphon_ABX_English_Aug_2018/audio_and_video
cp stimuli/*.mp3 LMEDS_master/tests/geomphon_ABX_English_Aug_2018/audio_and_video

cp stimuli/*.ogg LMEDS_master/tests/geomphon_ABX_French_Aug_2018/audio_and_video
cp stimuli/*.mp3 LMEDS_master/tests/geomphon_ABX_French_Aug_2018/audio_and_video



