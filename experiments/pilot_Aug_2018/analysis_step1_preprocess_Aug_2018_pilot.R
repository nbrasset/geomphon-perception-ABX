#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


#data cleaning and analysis of geomphon pilot 
#last edit 23 October 2018 by amelia 


rm(list=ls())
library(stringr)
library(dplyr)

#Arguments 
###### 1 presurvey 
###### 2 results
###### 3 postsurvey
###### 4 posrtsurvey2
###### 5 all acoustic distances- item info

###### 6 output: csv of merged but unfiltered data for modeling
###### 7 output: csv of filtered data for analysis






##############
#READ in data#
##############

#read in data files, which are the output of clean_output_pilot_Aug_2018.py
#ARGUMENT 1:  presurvey file
subject_info <-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/presurvey.csv")

#ARGUMENT 2:  results file
results_only <-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/results.csv")

#ARGUMENT 3:  postsurvey file
postsurvey<-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/postsurvey.csv")

#ARGUMENT 4:  postsurvey2 file 
postsurvey2<-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/postsurvey2.csv")

#ARGUMENT 5: ITEM INFO 
item_info <-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/distances/distances__normed_filterbank__dtw_pathlength.csv")


####################################
#EXCLUSION and FILTERING OF SUBJECTS
####################################

# start with only subjects who are present in the postsurvey file (meaning presumably they finished the task).
#first make both factors, then left join
finishers<-dplyr::left_join(postsurvey,subject_info,by ='subject_id')

#remove anyone who said native in either column 

#remove anyone who said they were advancee, presque native, in competence 

#remove anyone who said they were intermediate (2) AND had assez, beaucoup, or native experience 



#right now, takes only those who say they are not native speakers of another language
subject_info_filt1 <- dplyr::filter(finishers,
                                    other_lang_native == 0)



## Phonetic training filtering - exclude anyone with any classes phonet/phonol/linguistics
subject_info_filt2 <- dplyr::filter(subject_info_filt1,
                                    phonet_course_yes == 0,
                                    phonog_course_yes == 0,
                                    ling_course_yes == 0)

## Exclude - speech/hearing/vision problems
subject_info_filt3 <- dplyr::filter(subject_info_filt2,
                                    hear_vis_problems_yes == 0,
                                    troubles_de_lang_yes == 0)

## Filtering finished
subject_info_filt <- subject_info_filt3



######################################
#ADD ACOUSTIC DISTANCES AND ITEM INFO#
######################################

#merge subject info and results
full_results <- dplyr::left_join(subject_info_filt, results_only, by = 'subject_id')

unfiltered<- dplyr::left_join(finishers, results_only, by = 'subject_id')

###########
##check for failed attention checks

#find attention trials, make them into a df called attention checks
attention_checks<- dplyr::filter(full_results, grepl('atten', tripletid))

#make sure variables are in correct format.
attention_checks<- dplyr:: mutate(attention_checks, paid_attention = 
                                    ifelse(tripletid=="attention_check_English_F_normalized"|tripletid=="attention_check_francais_F_normalise" & first_sound==1,'pass_f',
                                           ifelse(tripletid=="attention_check_english_J_normalise"|tripletid=="attention_check_francais_J_normalise" & second_sound==1,'pass_j',
                                                  'fail')))

#merge the attention checks with the whole data 
full_results<- dplyr::left_join(full_results,attention_checks)


#filter out subjects who failed the  attention checks  #FIXME 


#merge item info and results 
full_results<- dplyr::left_join(full_results,item_info)



# #####################################################
# #####BUILD UNFILTERED DATA FOR USE IN MODELING-IGNORE
#  unfilt_full<- dplyr::left_join(unfiltered,item_info)
#  unfilt_full$user_resp<-factor(ifelse(unfilt_full$first_sound == "1", "A", "B"))
#  unfilt_full$user_corr<-substr(unfilt_full$presentation_order,1,1) == unfilt_full$user_resp
#  unfilt_full$user_corr<-as.integer(unfilt_full$user_corr)
#  #Argument 6
#  write.csv(unfilt_full,"/Users/post-doc/Desktop/geomphon_pilot_analysis/unfilt_full.csv")
# #########################################################
 
 
 

######################
#PREPARE OUTPUT FILE##
######################

#add correct/wrong column in results
results_only$user_resp<-ifelse(results_only$first_sound == "1", "A", "B")
results_only$corr_ans<-str_sub(results_only$tripletid,start=-1)
#make sure user corr is an integer, important for later statistical models.
results_only$user_corr<-as.integer(results_only$corr_ans == results_only$user_resp)

#items 49,50,100,104 were used as practice so they have twice as many trials. 
#remove all trials of these items 
trials_only<-dplyr::filter(full_results, !grepl('stimulus49_A', tripletid))
trials_only<-dplyr::filter(full_results, !grepl('stimulus_50_B', tripletid))
trials_only<-dplyr::filter(full_results, !grepl('stimulus100_A', tripletid))
trials_only<-dplyr::filter(full_results, !grepl('stimulus104_A', tripletid))

#remove attention trials
trials_only<-dplyr::filter(full_results, !grepl('attention', tripletid))




#add a new column subtracting the two distances
trials_only$delta_dist_sub<-trials_only$distance_TGT-trials_only$distance_OTH

#add a new column dividing the two distances 
trials_only$delta_dist_div<-trials_only$distance_TGT/trials_only$distance_OTH

# add a column that takes the log 
trials_only$log_delta_dist_div<-log(trials_only$delta_dist_div)




#ARGUMENT 7
write.csv(trials_only,"/Users/post-doc/Desktop/geomphon_pilot_results_for_analysis.csv")

