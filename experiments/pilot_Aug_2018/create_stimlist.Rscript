#this takes as input the output of the script "create_stimlist.py"  and the textfile
#meta info from save_intervals_to_wavs.Praat and puts it
#in the format needed for "concatenation_of_wavs.Praat"

library(plyr)
library(dplyr)
library(tidyr)
set.seed(567)

#arguments 
#working directory 
#stimlist to reformat
#meta_info_ from save_intervals to wavs
#output 


setwd("/Users/post-doc/GitHub/Documents/geomphon-perception-ABX/experiments/pilot_Aug_2018")  #FIXme  add command line argument 

stimlist<-read.csv("stimlist.csv")
#Using plyr mapvalues, interpret numerals output by create_stimlist 
#as meaningful strings 

stimlist$COMPARISON<-
  mapvalues(stimlist$COMPARISON,
            from = c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35),
            to=c("HA_HAE","HA_HEE","HA_HOO","HA_HUH","HA_WHO","HAE_HEE","HAE_HOO","HAE_HUH","HAE_WHO","HEE_HOO",
             "HEE_HUH","HEE_WHO","HOO_HUH","HOO_WHO","HOO_WHO","F_K","F_P","F_SH","F_SS","F_TH","F_T","K_P","K_SH",
             "K_SS","K_TH","K_T","P_SH","P_SS","P_TH","P_T","SH_SS","SH_TH","SH_T","SS_TH","SS_T","TH_T"),
            warn_missing = TRUE)

stimlist$ORDER<-
  mapvalues(stimlist$ORDER,
            from= c(0,1,2,3),
            to = c("PQP","QPP","PQQ","QPQ"),
            warn_missing = TRUE)

stimlist$SPEAKER<-
  mapvalues(stimlist$SPEAKER,
            from=c(0,1),
            to=c('ewan_','amelia_'),
            warn_missing = TRUE)

stimlist$CONTEXT<-
  mapvalues(stimlist$CONTEXT,
            from=c(0,1),
            to=c('EE','AH'),
            warn_missing = TRUE)



#split the comparison column into two columns, name them P and Q
stimlist<-as.data.frame(stimlist)
stimlist<- stimlist %>% separate(COMPARISON, c("P", "Q"),sep="_")


#add a Vowel or consonant column

vowels <-c("HA","HAE","HEE","HOO","HUH","WHO")
consonants<-c("P","T","K","F","TH","SH","SS")

stimlist<-stimlist %>% mutate(
      V_C = case_when(
            P %in% vowels~"vowel",
            P %in% consonants ~"consonant"))

#Add the correct context, depending on whether a consonant or vowel

stimlist<-stimlist %>% mutate(
    word_P = case_when(
      V_C == "vowel"& CONTEXT == "AH"~ paste(P,"DAH", sep=""),
      V_C == "vowel" & CONTEXT == "EE"~ paste(P,"DI", sep=""),
      V_C == "consonant" & CONTEXT == "AH"~ paste("A",P,"AH",sep=""),
      V_C == "consonant" & CONTEXT == "EE"~ paste("EE",P,"EE",sep="")))

stimlist<-stimlist %>% mutate(
    word_Q = case_when(
      V_C == "vowel"& CONTEXT == "AH"~ paste(Q,"DAH", sep=""),
      V_C == "vowel" & CONTEXT == "EE"~ paste(Q,"DI",sep=""),
      V_C == "consonant" & CONTEXT == "AH"~ paste("A",Q,"AH",sep=""),
      V_C == "consonant" & CONTEXT == "EE"~ paste("EE",Q,"EE",sep=""))
    )


######################################################
#create a list of filenames that randomly selects one interval filename of each type
#from the full list_of_all_intervals
######################################################


#first read in list of all intervals from interval saving script
list_of_all_interval_filenames<-read.delim("stimuli/concatenation/intervals/meta_info_filelist.txt", row.names=NULL)

#now add a variable for speaker by stripping off all characters before "_" in orig_file
#(because orig_file is the FILENAME, which either Ewan or amelia_consonants)
list_of_all_interval_filenames$speaker<-sub("_.*","", list_of_all_interval_filenames$orig_file)

#now group by speaker, then by interval name, then sample one of those intervals.
final_files <- group_by(list_of_all_interval_filenames, speaker, int_name)%>% sample_n(1)
final_files$key<-paste(final_files$speaker,"_",final_files$int_name,sep="")
#final_files now lists the specific instance of the interval used in col int_filename.



########
#Create a key of which files to use where based on the stimlist created
#by the optimizatiuon script
#####

# create file and silence columns depending on the order column Ps and Qs
stimlist<-stimlist %>% mutate(
   File1 = case_when(
     ORDER == "PQP"~word_P,
     ORDER == "PQQ"~ word_P,
     ORDER == "QPQ"~ word_Q,
     ORDER == "QPP"~ word_Q),
   File2 = case_when(
     ORDER == "PQP"~word_Q,
     ORDER == "PQQ"~word_Q,
     ORDER == "QPQ"~word_P,
     ORDER == "QPP"~word_P),
   File3 = case_when(
     ORDER == "QPQ"~word_Q,
     ORDER == "PQQ"~word_Q,
     ORDER == "PQP"~word_P,
     ORDER == "QPP"~word_P)
   )

#add correct answer-- nb do this before adding speaker because speaker will be different across these.  
stimlist<-stimlist %>% mutate(
  CORR_ANS = case_when(
    stimlist$File1==stimlist$File3~"A",
    stimlist$File2 ==stimlist$File3 ~"B"))



#############################
#create file keys that will be used to look up the real file name 
##############

stimlist<-stimlist %>% mutate(
  File1 = case_when(
    SPEAKER=="amelia_"~paste("amelia_",File1,sep=""),
    SPEAKER=="ewan_"~paste("ewan_",File1,sep="")))

stimlist<-stimlist %>% mutate(
  File2 = case_when(
    SPEAKER=="amelia_"~paste("amelia_",File2,sep=""),
    SPEAKER=="ewan_"~paste("ewan_",File2,sep="")))

#put the OPPOSITE speaker for file 3
stimlist<-stimlist %>% mutate(
   File3 = case_when(
     SPEAKER=="amelia_"~paste("ewan_",File3,sep=""),
     SPEAKER=="ewan_"~paste("amelia_",File3,sep="")))

stimlist<-tibble::rowid_to_column(stimlist, "ID")
stimlist$trial_num<-paste("trial_num",stimlist$ID, sep="")





###################
#MAP SITMLIST TO REAL FILENAMES
#- changing format from wide to long, left join with list of
#real filenames, and then going back to wide.


#transform data to long version with one file per line
long<-gather(stimlist, key=file_pos, value=key, File1:File3)

#use merge to add filename for each file 
with_file_names<-left_join(x=long, y=final_files)

#create a unique ID so we can use spread 
#with_file_names<-tibble::rowid_to_column(with_file_names, "ID")

#select only the columns we care about to make data manipulation work
simple_long<-with_file_names %>%
  select(file_pos,int_filename, trial_num, CORR_ANS)

#transform data back to wide version with three files per line 
wide<-spread(simple_long, key=file_pos, value=int_filename)


#add in columns with the name of the silences. 
wide$Silence1<-rep("500ms_silence",length(wide$File1))
wide$Silence2<-rep("500ms_silence",length(wide$File1))

#create Column that has the filename for the concatenated file
wide$filename<-paste("stimulus",1:length(wide$File1),sep="")

final_stimlist<-wide%>%
  select(File1,Silence1,File2,Silence2,File3,CORR_ANS,filename)

#print df  to text file (NB NOT A CSV, Praat prefers TXT here.)  
write.table(final_stimlist, file="Stimuli_list.txt", sep="\t",quote = FALSE, row.names = FALSE)














