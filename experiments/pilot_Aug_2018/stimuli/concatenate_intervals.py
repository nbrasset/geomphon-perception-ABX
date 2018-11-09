###########################################
###CONCATENATE INTERVAL .wavs into full wav#
###########################################
#9 November by Amelia 
#takes a directory of intervals that havve been 
import pydub
import pandas as pd


# ARGUMENTS
folderpath =sys.argv[1] #path to directory of intervals 
stimlist= sys.argv[2] # stimlist, output of 

presurvey_filename =  sys.argv[3]
postsurvey_filename = sys.argv[4]
postsurvey2_filename = sys.argv[5]


from pydub import AudioSegment



sound1 = AudioSegment.from_wav("/path/to/file1.wav")
sound2 = AudioSegment.from_wav("/path/to/file2.wav")

combined_sounds = sound1 + sound2
combined_sounds.export("/output/path.wav", format="wav")


