#this takes as input the output of the script "create_stimlist.py" and puts it
#in the format needed for "concatenation_of_wavs.Praat"

library(plyr)
library(dplyr)
library(tidyr)

list<-read.csv("stimlist.csv")

#Using plyr mapvalues, interpret numerals output by create_stimlist 
#as meaningful strings 


#comparisons  #FIXME-add VC  info here?

list$COMPARISON<-
  mapvalues(list$COMPARISON,
            from = c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35),
            to=c("HA_HAE","HA_HEE","HA_HOO","HA_HUH","HA_WHO","HAE_HEE","HAE_HOO","HAE_HUH","HAE_WHO","HEE_HOO",
             "HEE_HUH","HEE_WHO","HOO_HUH","HOO_WHO","HOO_WHO","F_K","F_P","F_SH","F_SS","F_TH","F_T","K_P","K_SH",
             "K_SS","K_TH","K_T","P_SH","P_SS","P_TH","P_T","SH_SS","SH_TH","SH_T","SS_TH","SS_T","TH_T"),
            warn_missing = TRUE)

list$ORDER<-
  mapvalues(list$ORDER,
            from= c(0,1,2,3),
            to = c("PQP","QPP","PQQ","QPQ"),
            warn_missing = TRUE)

list$SPEAKER<-
  mapvalues(list$SPEAKER,
            from=c(0,1),
            to=c('ewan_','amelia_'),
            warn_missing = TRUE)

list$CONTEXT<-
  mapvalues(list$CONTEXT,
            from=c(0,1),
            to=c('EE','AH'),
            warn_missing = TRUE)


#split the comparison column into two columns, name them P and Q
list<-as.data.frame(list)
list<- list %>% separate(COMPARISON, c("P", "Q"),sep="_")


#add a Vowel or consonant column

vowels <-c("HA","HAE","HEE","HOO","HUH","WHO")
consonants<-c("P","T","K","F","TH","SH","SS")

list<-list %>% mutate(
      V_C = case_when(
            P %in% vowels~"vowel",
            P %in% consonants ~"consonant"))

#Add the correct context, depending on whether a consonant or vowel
#add in a random repetition number to chose one of the repetitions of the word (random value 1-4)
 
 list<-list %>% mutate(
    word_P = case_when(
      V_C == "vowel"& CONTEXT == "AH"~ paste(P,"DAH", sample(1:4,1), sep=""),
      V_C == "vowel" & CONTEXT == "EE"~ paste(P,"DI",  sample(1:4,1),sep=""),
      V_C == "consonant" & CONTEXT == "AH"~ paste("AH",P,sample(1:4,1),"AH", sep=""),
      V_C == "consonant" & CONTEXT == "EE"~ paste("EE",P,sample(1:4,1),"EE", sep="")))

 list<-list %>% mutate(
    word_Q = case_when(
      V_C == "vowel"& CONTEXT == "AH"~ paste(Q,"DAH",sample(1:4,1), sep=""),
      V_C == "vowel" & CONTEXT == "EE"~ paste(Q,"DI",sample(1:4,1), sep=""),
      V_C == "consonant" & CONTEXT == "AH"~ paste("AH",Q,"AH",sample(1:4,1), sep=""),
      V_C == "consonant" & CONTEXT == "EE"~ paste("EE",Q,"EE",sample(1:4,1), sep=""))
    )
 
 
#Add speaker  to P and Q based on value in input 
 list<-list %>% mutate(
   FileP = paste(SPEAKER,word_P,sep=""),
   FileQ = paste(SPEAKER,word_Q,sep=""))
 
 
# create file and silence columns depending on the order column Ps and Qs
 list<-list %>% mutate(
   File1 = case_when(
     ORDER == "PQP"~FileP,
     ORDER == "PQQ"~ FileP,
     ORDER == "QPQ"~ FileQ,
     ORDER == "QPP"~ FileQ),
   File2 = case_when(
     ORDER == "PQP"~FileQ,
     ORDER == "PQQ"~FileQ,
     ORDER == "QPQ"~FileQ,
     ORDER == "QPP"~FileP),
   File3 = case_when(
     ORDER == "QPQ"~FileQ,
     ORDER == "PQQ"~FileQ,
     ORDER == "PQP"~FileQ,
     ORDER == "QPP"~FileP)
   )
 
 list<-list %>% mutate(
 CORR_ANS = case_when(
   File1==File3~"A",
   File2 == File3 ~"B"))

#add in columns with the name of the silences. 
list$Silence1<-rep("500ms_silence.wav",length(list$File1))
list$Silence2<-rep("500ms_silence.wav",length(list$File1))

#create Column that has the filename for the concatenated file
list$filename<-paste("stimulus",1:length(list$File1),sep="")

Stimuli_list<-list %>%
  select(File1, Silence1,File2,Silence2,File3,CORR_ANS,filename)

#print df  to text file (NB NOT A CSV, Praat prefers TXT here.)  
write.table(Stimuli_list,file="Stimuli_list.txt", sep="\t")




