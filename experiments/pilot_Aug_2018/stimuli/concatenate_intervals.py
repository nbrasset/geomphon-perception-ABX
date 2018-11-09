###########################################
###CONCATENATE INTERVAL .wavs into full wav#
###########################################
#9 November by Amelia 
#takes a directory of intervals that have been normalized 
import pydub
import pandas as pd
import os 

#requires ffmpeg with libvorbis in order to make oggs
#brew install ffmpeg --with-libvorbis


# ARGUMENTS
folderpath = "/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/stimuli/stimuli_intervals/"  #sys.argv[1] #path to directory of intervals 
stimfile = '/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/stimulus_list.csv' #sys.argv[2] # stimlist, output of 
silencefile1 = '/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/stimuli/raw/500ms_silence.wav' #sys.argv [3] #first silence between files A and B
silencefile2 = '/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/stimuli/raw/500ms_silence.wav' #sys.argv [4] #second silence, between fiels B and X (in this experiment, the same)
outfolder = '/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/stimuli/' #sys.argv [5] # folder for output files 

os.makedirs(outfolder+'wavs')
os.makedirs(outfolder+'mp3s')
os.makedirs(outfolder+'oggs')

wav_folder = outfolder + "/wavs/"
mp3_folder = outfolder + "/mp3s/"
ogg_folder = outfolder + "/oggs/"

stimlist = pd.read_csv(stimfile)


from pydub import AudioSegment

silence1 = AudioSegment.from_wav(silencefile1)
silence2 = AudioSegment.from_wav(silencefile2)


for i in range (0,len(stimlist)):

    sound1 = AudioSegment.from_wav(folderpath + stimlist.iloc[i,0] +".wav")
    sound2 = AudioSegment.from_wav(folderpath + stimlist.iloc[i,1] +".wav")
    sound3 = AudioSegment.from_wav(folderpath + stimlist.iloc[i,2] +".wav")

    combined_sounds = sound1 + silence1 +sound2 + silence2  + sound3

    combined_sounds.export(wav_folder+stimlist.iloc[i,4]+".wav", format = "wav")
    combined_sounds.export(mp3_folder+stimlist.iloc[i,4]+".mp3", format = "mp3")
    combined_sounds.export(ogg_folder+stimlist.iloc[i,4]+".ogg", format = "ogg")


