#!/usr/bin/env Rscript
#last edit Mar 29 2019 by Amelia


`%>%`<-magrittr::`%>%`



##################
#create master df#
##################
create_masterdf<-"create_masterdf_function.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                            coef_vals=c(-1,0,1),
                            num_data_sets = 2)

####################
#create csv dataset#
####################

design_df <- readr::read_csv("exp_design_Hindi_with_acoustic_distance.csv")
colnames(design_df)[colnames(design_df)=="Acoustic distance"] <- "acoustic_distance"
num_subjs = 30 
num_reps_trials = 3 #number of times the whole design is repeated
num_trials = nrow(design_df) * num_reps_trials 

subj_list <- list()
for (i in 1:num_subjs) {
    subj_list[i] = paste("subject",i,sep = "_")
}

trial_list <- list()
for (i in 1:num_trials) {
  trial_list[i] = paste("trial",i,sep = "_")
}

subs_trials <- expand.grid(subj_list, trial_list)
rep_design<- design_df[rep(seq_len(nrow(design_df)), num_reps_trials*num_subjs), ]

response_var <-c(sample(c(0,1), nrow(rep_design), replace = TRUE))

full_design <- cbind(subs_trials,rep_design,response_var)

#Nb these responses are dummy responses for the moment. 
#will be filled in in the sampling step  #FIXME streamline



######################
#sample data and save#
######################
sample_binary_four<-"sample_binary_four_function.R"
source(sample_binary_four)

coef_dist <- 2 #effect of acoustic distance. 


uniq_filenames <- list(unique(master_df$csv_filename))


for (i in 1:length(uniq_filenames)){
  sample_binary_four(d = full_design,
                response_var = "response_var",
                predictor_vars = c("Econ","Glob","Loc","acoustic_distance"),
                coef_values = c(master_df$coef_econ[i],
                                master_df$coef_glob[i],
                                master_df$coef_loc[i],
                                1
                                )
                ) %>%
    write.csv(file=paste("sampled_datasets/",
                         uniq_filenames[i],
                         sep=""))
}
     



