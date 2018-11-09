###########################################
###CONCATENATE INTERVAL .wavs into full wav#
###########################################
#9 November by Amelia 
#takes a directory of intervals that havve been 
import pydub
import pandas as pd


# ARGUMENTS
folderpath = sys.argv[1] #path to directory of intervals 
stimfile = sys.argv[2] # stimlist, output of 
silencefile1 = sys.argv [3] #first silence between files A and B
silencefile2 = sys.argv [4] #second silence, between fiels B and X (in this experiment, the same)
outfolder = sys.argv [5] # folder for output files 


stimlist = pd.read_csv(stimfile)



from pydub import AudioSegment

silence1 =AudioSegment.from_wav(folderpath + row[0] +".wav")
silence2 =AudioSegment.from_wav(folderpath + row[0] +".wav")



for row [i] in stimlist 

  sound1 = AudioSegment.from_wav(folderpath + row[0] +".wav")
  sound2 = AudioSegment.from_wav(folderpath + row[1] +".wav")
  sound3 = AudioSegment.from_wav(folderpath + row[2] +".wav")

	combined_sounds = sound1 + silence +sound2 + silence + sound3

	combined_sounds.export(outfolder+row[6]+"wav", format="wav")
	combined_sounds.export(outfolder+row[6]+"mp3", format="mp3")
	combined_sounds.export(outfolder+row[6]+"ogg", format="ogg")




