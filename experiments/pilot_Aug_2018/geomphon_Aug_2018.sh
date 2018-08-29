#!/bin/bash

#navigate to correct folder 
cd /Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/

#now run interval saving script
/Applications/Praat.app/Contents/MacOS/Praat --open "save_intervals_to_wavs.Praat"
/Applications/Praat.app/Contents/MacOS/Praat --run "save_intervals_to_wavs.Praat"




# 
#for f in *.wav; do ffmpeg -i "$f" -c:a libmp3lame -q:a 2 "${f/%wav/mp3}" -c:a libvorbis -q:a 4 "${f/%wav/ogg}"; done

#



#for i in `ls *.aiff`
#do echo -e "$i"
# sox $i $i.wav echo -e "$i.wav"; done;
#for i in *.wav
#do
#    sox "$i" "stimuli/$(basename -s .mp3 "$i").mp3"
#done