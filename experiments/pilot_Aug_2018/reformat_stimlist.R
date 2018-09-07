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

list %>% mutate(
      V_C = case_when(
            P %in% vowels~"vowel",
            P %in% consonants ~"consonant"))



#Add the correct context, depending on whether a consonant or vowel

#Add speaker  to P and Q based on value in input 

#Create new columns "File1 "File2" "File3"

# if loop fill in the file columns depending on the order column Ps and Qs

#add in silence columns (identical for all stimuli)

#create Column that has the correct answer 

#create tripletid column (= just an index number, so this document can be
#used as a key to determine the sounds during analysis.) 

#print matrix to text file (NB NOT A CSV, Praat prefers TXT here.)  





