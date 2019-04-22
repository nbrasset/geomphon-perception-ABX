#!/usr/bin/env Rscript
#last edit Apr 18 2019 by Amelia


`%>%`<-magrittr::`%>%`


##################
#create master df#
##################


create_masterdf<-"create_masterdf_function_pos_neg.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                            coef_vals=c(-1,0,1),
                            num_data_sets = 2)
readr::write_csv(master_df, path="master_df.csv")



####################
#create csv dataset#
####################

design_df <- readr::read_csv("exp_design_HK_with_acoustic_distance.csv")
colnames(design_df)[colnames(design_df)=="Acoustic distance"] <- "acoustic_distance"
num_subjs = 30 
num_reps_trials = 2 #number of times the whole design is repeated
num_trials = nrow(design_df) * num_reps_trials 
# FIXME add noise to the repetitions of the acoustic distance 

subjs<- c()
for (i in 1:num_subjs) {
    subjs[i] = paste("subject",i,sep = "_")
}

trials <- c()
for (i in 1:num_trials) {
  trials[i] = paste("trial",i,sep = "_")
}


subs_trials <- expand.grid(subjs, trials)
names(subs_trials)<-c("subject","trial")

rep_design<- design_df[rep(seq_len(nrow(design_df)), num_reps_trials*num_subjs), ]

response_var <-c(sample(c(0,1), nrow(rep_design), replace = TRUE))

full_design <- as.data.frame(cbind(subs_trials,rep_design,response_var))



#Nb these responses are dummy responses for the moment,but must exist 
#for the sampling function  
#FIXME streamline

######################
#sample data and save#
######################
sample_binary_four<-"sample_binary_four_function.R"
source(sample_binary_four)

coef_dist <- -.1784  #effect of acoustic distance. taken from pilot data 
uniq_filenames <- unique(master_df$csv_filename)

for (i in 1:length(uniq_filenames)){
  data_i <- sample_binary_four(d = full_design,
                              response_var = "response_var",
                              predictor_vars = c("Econ",
                                                 "Glob",
                                                 "Loc",
                                                 "acoustic_distance"),
                              coef_values = c(master_df$coef_econ[i],
                                              master_df$coef_glob[i],
                                              master_df$coef_loc[i],
                                              coef_dist),
                              intercept = 1.3592
                              )
    readr::write_csv(data_i,paste0("hindi_kab_for_comparison","/",uniq_filenames[i]))
}




