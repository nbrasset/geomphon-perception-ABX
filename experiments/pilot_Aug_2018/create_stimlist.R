#Stimuli filtering script 
#Aug 29 2018 by Amelia 
# this script takes as input a .csv will all possible triplet combinations. 
# the .csv is an output of ascript by Ewan named ______
#the triplets are constrained as being the same 
#It then filters them to create a balanced subset, and generates a stimlist for LMEDs 
# as well as a stimlist for the concatenation script. 

library(dplyr)
trips<-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/triplets.csv")

#select only files that compare consonants to consonants 
#and vowels to vowels 
comps<-filter(trips, (CV_TGT=="C"&CV_OTH=="C"&CV_X=="C")|(CV_TGT=="V"&CV_OTH=="V"&CV_X=="V"))



#only files where Target and other are not the same phoneme (already controlled for) 

summary(comps)
#add index number 
