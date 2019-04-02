#!/usr/bin/env Rscript
#last edit Apr 01 2019 by Amelia


`%>%`<-magrittr::`%>%`



##################
#create master df#
##################
create_masterdf<-"create_masterdf_function.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                            coef_vals=c(-1,0,1),
                            num_data_sets = 2)
#FIXME address number of data sets 


####################
#create csv dataset#
####################

design_df <- readr::read_csv("exp_design_Hindi_with_acoustic_distance.csv")
colnames(design_df)[colnames(design_df)=="Acoustic distance"] <- "acoustic_distance"
num_subjs = 30 
num_reps_trials = 3 #number of times the whole design is repeated
num_trials = nrow(design_df) * num_reps_trials 

# FIXME add noise to the repetitions of the acoustic distance 
#FIXME make these not lists 

subjs<- c()
for (i in 1:num_subjs) {
    subjs[i] = paste("subject",i,sep = "_")
}

trials <- c()
for (i in 1:num_trials) {
  trials[i] = paste("trial",i,sep = "_")
}


subs_trials <- expand.grid(subjs, trials)
rep_design<- design_df[rep(seq_len(nrow(design_df)), num_reps_trials*num_subjs), ]

response_var <-c(sample(c(0,1), nrow(rep_design), replace = TRUE))

full_design <- as.data.frame(cbind(subs_trials,rep_design,response_var))





#Nb these responses are dummy responses for the moment,but must exist 
#for the sampling function   #FIXME streamline


######################
#sample data and save#
######################
sample_binary_four<-"sample_binary_four_function.R"
source(sample_binary_four)

coef_dist <- -.2784  #effect of acoustic distance. 
#taken from 

uniq_filenames <- unique(master_df$csv_filename)

for (i in 1:length(uniq_filenames)){
  data_i <- sample_binary_four(d = full_design,
                response_var = "response_var",
                predictor_vars = c("Econ","Glob","Loc","acoustic_distance"),
                coef_values = c(master_df$coef_econ[i],
                                master_df$coef_glob[i],
                                master_df$coef_loc[i],
                                coef_dist
                                ))
    write.csv(data_i, file=paste0("sampled_datasets","/",uniq_filenames[i]))
}




data_i<-readr::read_csv("sampled_datasets/econ_0_loc_0_glob_0.csv")
data_k<-readr::read_csv("sampled_datasets/econ_1_loc_0_glob_1.csv")
data_j<-readr::read_csv("sampled_datasets/econ_1_loc_1_glob_1.csv")

summ_acc_i <- dplyr::group_by(data_i, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_i, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text() #+ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)

summ_acc_k <- dplyr::group_by(data_k, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_k, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text()#+ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)

summ_acc_j <- dplyr::group_by(data_j, Phone_NOTENG, Phone_ENG, Econ, Loc, Glob, acoustic_distance) %>% dplyr::summarize(acc=mean(response_var)) %>% dplyr::ungroup()
ggplot2::ggplot(summ_acc_j, ggplot2::aes(x=acoustic_distance, y=acc, label=paste(Phone_NOTENG, Phone_ENG, sep=":"))) + ggplot2::geom_text()#+ggplot2::xlim(-2,1)+ggplot2::ylim(0,.9)
