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

#convert all new triplet files to .mp3 and .ogg and then save them to the LMEDs audio & video folder

#	for f in *.wav; do ffmpeg -i "$f" -c:a libmp3lame -q:a 2 "${f/%wav/mp3}" -c:a libvorbis -q:a 4 "${f/%wav/ogg}"; done
	#for i in `ls *.aiff`
	#do echo -e "$i"
	# sox $i $i.wav echo -e "$i.wav"; done;

	#for i in *.wav
	#do
	#    sox "$i" "stimuli/$(basename -s .mp3 "$i").mp3"
	#done







