#!/bin/bash


# #run interval saving script, save intervals to stimuli/interval;s
# #/Applications/Praat.app/Contents/MacOS/Praat --run "save_intervals_to_wavs.Praat"
# ###
# python stimuli/save_intervals_to_wavs.py word stimuli/stimuli_intervals \
# 	stimuli/meta_info_filelist.csv \
# 	stimuli/amelia_consonants_ONLY_TARGET_CHECKED.TextGrid,stimuli/amelia_consonants.wav \
# 	stimuli/amelia_vowels_ONLY_TARGET_CHECKED.TextGrid,stimuli/amelia_vowels.wav \
# 	stimuli/ewan_ONLY_TARGET_CHECKED.TextGrid,stimuli/ewan.wav

 #http://www.fon.hum.uva.nl/praat/manual/Scripting_6_9__Calling_from_the_command_line.html
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
