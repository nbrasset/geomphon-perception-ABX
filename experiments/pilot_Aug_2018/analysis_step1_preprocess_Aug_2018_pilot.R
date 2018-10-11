#data cleaning and analysis of geomphon pilot 
#last edit 11 October 2018 by amelia 

rm(list=ls())

##############
#READ in data#
##############


#read in data files, which are the output of clean_output_pilot_Aug_2018.py
subject_info <-read.csv("/Users/post-doc/Desktop/presurvey.csv")
results_only <-read.csv("/Users/post-doc/Desktop/results.csv")
postsurvey<-read.csv("/Users/post-doc/Desktop/postsurvey.csv")
postsurvey2<-read.csv("/Users/post-doc/Desktop/postsurvey2.csv")



# item_info <-read.csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/meta_information.csv")
# item_info2<-read.csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/meta_information_distances_norm.csv")
# item_info3<-read.csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/meta_information_distances_both_norm.csv")

#add the word "triplet_" before the name of the audio file in the item info, 
#so that it can be used as an id for the left join and so that it is interpreted as a character
item_info$tripletid <- sub("^", "triplet_", item_info$tripletid)

# start with only subjects who are present in the postsurvey file (meaning presumably they finished the task).
#first make both factors, then left join
finishers<-dplyr::left_join(postsurvey,subject_info,by ='subject')



####################################
#EXCLUSION and FILTERING OF SUBJECTS
####################################

## Language filtering - all this will change
## Remove subjects whose response to 'languages between 0 and 3' is not either 'English' or '1'
## (which we take to mean they misinterpreted the question as 'how many')
subject_info_filt1 <- dplyr::filter(finishers,
                                    toupper(lang_0_3) %in% c("ENGLISH", "1.0", "1"))

## Phonetic training filtering - exclude anyone with any classes phonet/phonol/linguistics
subject_info_filt2 <- dplyr::filter(subject_info_filt1,
                                    phonet_class_Y == 0,
                                    phonog_class_Y == 0,
                                    ling_course_Y == 0)

## Exclude - speech/hearing/vision problems
subject_info_filt3 <- dplyr::filter(subject_info_filt2,
                                    hear_vis_Y == 0,
                                    speech_prob_Y == 0)

##FIXME throw an error if there are duplicates in the pre and post survey 

## Filtering finished
subject_info_filt <- subject_info_filt3



###################
#MERGE DATA FRAMES#
###################

#merge subject info and results
full_results <- dplyr::left_join(subject_info_filt, results_only, by = 'subject')

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
trials_only$user_corr<-substr(trials_only$presentation_order,1,1) == trials_only$user_resp
trials_only$user_corr<-as.integer(trials_only$user_corr)

write.csv(trials_only,"/Users/post-doc/Desktop/geomphon_pilot_analysis/geomphon_pilot_results_for_analysis.csv")

