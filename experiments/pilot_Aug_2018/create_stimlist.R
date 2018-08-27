#Stimuli filtering script 
#Aug 29 2018 by Amelia 
# this script takes as input a .csv will all possible triplet combinations. 
# the .csv is an output of ascript by Ewan named ______
#the triplets are constrained as vowels compared only to vowels, consonants only to consonants
#It then filters them to create a balanced subset, and generates a stimlist for LMEDs 
# as well as a stimlist for the concatenation script. 

#there are 72 different 
library(dplyr)
trips<-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/triplets.csv")

#do this with dplyr, n00b
trips$trip_phons <- paste(trips$phone_TGT,trips$phone_OTH,trips$phone_X)
trips$trip_phons<-as.factor(trips$trip_phons)



#group by trip_phons
#then group by context (/i/ vs /a/)
#then group by TGT_speaker (E vs. A)







