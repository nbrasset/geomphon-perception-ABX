#data cleaning and analysis of geomphon pilot 
#last edit 11 October 2018 by amelia 

rm(list=ls())
library(stringr)
library(dplyr)


##############
#READ in data#
##############

#FIXME turn these into arguments to run from command line

#read in data files, which are the output of clean_output_pilot_Aug_2018.py
subject_info <-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/presurvey.csv")
results_only <-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/results.csv")
postsurvey<-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/postsurvey.csv")
postsurvey2<-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/postsurvey2.csv")

####
#add correct/wrong column in results
results_only$user_resp<-ifelse(results_only$first_sound == "1", "A", "B")
results_only$corr_ans<-str_sub(results_only$tripletid,start=-1)
results_only$user_corr<- ifelse(results_only$corr_ans == results_only$user_resp,1,0)
#########


#ITEM INFO 
#item info commented out.  acoustic distance will go here

item_info <-read.csv("/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/distances/distances__normed_filterbank__dtw_pathlength.csv")
# item_info2<-read.csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/meta_information_distances_norm.csv")
# item_info3<-read.csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/meta_information_distances_both_norm.csv")

####################################
#EXCLUSION and FILTERING OF SUBJECTS
####################################

# start with only subjects who are present in the postsurvey file (meaning presumably they finished the task).
#first make both factors, then left join
finishers<-dplyr::left_join(postsurvey,subject_info,by ='subject_id')


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

#unfiltered<- dplyr::left_join(finishers, results_only, by = 'subject')


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

#filter out the failed attention checks


#FIXME  these are additional lines added to test the different types of acoustic distance
#add new distances 
item_info$distance_TGT_norm<-item_info2$distance_TGT_norm
item_info$distance_OTH_norm<-item_info2$distance_OTH_norm
item_info$distance_TGT_both_norm<-item_info3$distance_TGT_both_norm
item_info$distance_OTH_both_norm<-item_info3$distance_OTH_both_norm



#merge item info and results 
full_results<- dplyr::left_join(full_results,item_info)

#####BUILD UNFILTERED DATA FOR USE IN MODELING-IGNORE
unfilt_full<- dplyr::left_join(unfiltered,item_info)
unfilt_full$user_resp<-factor(ifelse(unfilt_full$first_sound == "1", "A", "B"))
unfilt_full$user_corr<-substr(unfilt_full$presentation_order,1,1) == unfilt_full$user_resp
unfilt_full$user_corr<-as.integer(unfilt_full$user_corr)
write.csv(unfilt_full,"/Users/post-doc/Desktop/geomphon_pilot_analysis/unfilt_full.csv")


#remove practice trials and attention trials
trials_only<-dplyr::filter(full_results, !grepl('practice_|attention', tripletid))

#add a new user response column that maps on to answer key 
trials_only$user_resp<-factor(ifelse(trials_only$first_sound == "1", "A", "B"))

#add a new column subtracting the two distances
trials_only$delta_dist_sub<-trials_only$distance_TGT-trials_only$distance_OTH

#add a new column dividing the two distances 
trials_only$delta_dist_div<-trials_only$distance_TGT/trials_only$distance_OTH

# add a column that takes the log 
trials_only$log_delta_dist_div<-log(trials_only$delta_dist_div)

#add column that says whether the participant response matches the correct answer

trials_only$USER_CORR<- case_when(
                            trials_only$user_resp==trials_only$CORR_ANS~1,
                            trials_only$user_resp!=trials_only$CORR_ANS~0)


trials_only$user_corr<-substr(trials_only$presentation_order,1,1) == trials_only$user_resp
trials_only$user_corr<-as.integer(trials_only$user_corr)

write.csv(trials_only,"/Users/post-doc/Desktop/geomphon_pilot_analysis/geomphon_pilot_results_for_analysis.csv")

