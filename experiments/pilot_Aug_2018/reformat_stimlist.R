#this takes as input the output of the script "create_stimlist.py" and puts it
#in the format needed for "concatenation_of_wavs.Praat"

library(plyr)
library(dplyr)
library(tidyr)
set.seed(567)

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
#add in a random repetition number to chose one of the repetitions of the word (random value 1-4)
 
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
 

#map value of word_P and word_Q to an acutal file name 
#first create vector of all file names intervals 
files_list<-dir(path ="stimuli/concatenation/intervals")

#add column for speaker by stripping off speaker name 

#add column for sound by stripping off number and .csv


#group by speaker 
#then group by 
#then sample one in each group and return one value of file name. 





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

 
 #Add speaker  to files-- one speaker for files 1 and 2, the other for file 3 
stimlist<-stimlist %>% mutate(
   File1 = paste(SPEAKER,File1,sep=""),
   File2 = paste(SPEAKER,File2,sep=""))

stimlist<-stimlist %>% mutate(
   File3 = case_when(
     SPEAKER=="amelia_"~paste("ewan_",File3,sep=""),
     SPEAKER=="ewan_"~paste("amelia_",File3,sep="")))

 
#add in columns with the name of the silences. 
stimlist$Silence1<-rep("500ms_silence.wav",length(stimlist$File1))
stimlist$Silence2<-rep("500ms_silence.wav",length(stimlist$File1))

#create Column that has the filename for the concatenated file
stimlist$filename<-paste("stimulus",1:length(stimlist$File1),sep="")

final_stimlist<-stimlist %>%
  select(File1,Silence1,File2,Silence2,File3,CORR_ANS,filename)

#print df  to text file (NB NOT A CSV, Praat prefers TXT here.)  
write.table(final_stimlist, file="Stimuli_list.txt", sep="\t",quote = FALSE, row.names = FALSE)



