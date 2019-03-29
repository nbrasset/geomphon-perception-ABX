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
     


#################
#create standats#
#################

dataset_folder<-("sampled_datasets") # "sampled_datasets"
vec_of_ds_filenames <- list.files(path=dataset_folder,recursive=T)
full_files <- paste(dataset_folder,vec_of_ds_filenames,sep="/")
dataset_list <- lapply(full_files, read.csv) 

list_of_Standats = list()

for (i in 1:length(dataset_list)){
 
  ds<-dataset_list[[i]]
  name<-vec_of_ds_filenames[i]
  
  #FIXME check null case
  pos_formula<-as.formula(paste("~",master_df[["pos_vars"]][[1]],"-1"))
  
  x_cns_pos <- unname(model.matrix(pos_formula,ds)) # constrained positive
  attr(x_cns_pos, "assign") <- NULL
  
  neg_formula<-as.formula(paste("~",master_df[["neg_vars"]][[1]],"-1"))
  x_cns_neg<- unname(model.matrix(neg_formula,ds)) # constrained negative 
  attr(x_cns_neg, "assign") <- NULL
  
  x_oth <- unname(model.matrix(~1,ds)) # unconstrained
  attr(x_oth, "assign") <- NULL
  x_u <- unname(model.matrix(~1,ds)) # unmodelled (subject-level)
  attr(x_u, "assign") <- NULL
  x_w <- unname(model.matrix(~1,ds)) # unmodelled (item-level)
  attr(x_w, "assign") <- NULL  
  
  listname = paste("StanDat_",ds,sep="") #name of the new Standata list 
  
  dv_col <- ds$user_corr
  subj_col <- ds$subject_id
  item_col <- ds$trip_id_2
  
  newlist <- list(accuracy = as.integer(dv_col),
                  
                  subj=as.numeric(factor(subj_col)),
                  item=as.numeric(factor(item_col)),
                  
                  N_obs = nrow(ds),
                  
                  N_cf_cns_pos = ncol(x_cns_pos),
                  N_cf_cns_neg = ncol(x_cns_neg),
                  N_cf_oth = ncol(x_oth),
                  N_cf_u = ncol(x_u),
                  N_cf_w = ncol(x_w),
                  
                  x_cns_pos = x_cns_pos,
                  x_cns_neg = x_cns_neg,
                  x_oth = x_oth,
                  x_u = x_u,
                  x_w = x_w,
                  
                  N_subj=length(unique(subj_col)),
                  N_item=length(unique(item_col)) )
  
  list_of_Standats[[i]] <- newlist
}



fit_stan_mod <- function(i){
  
model<-rstan::stan(file = "stan_models/master_model.stan",
            data = list_of_Standats[[i]],
            chains = 1,
            iter = 300,
            seed = 75019
)
saveRDS(model,file =paste("modelfits/",
                          master_df[["standat_filename"]][[1]],sep=""))
}


library(doParallel)
options(cores=4) #set this appropriate to your system
registerDoParallel()

#num_fits <- nrow(master_df)

DUMMY <- foreach(i = 1:2) %dopar% fit_stan_mod(i)


# FIXME: don't run models we've already fit
#FIXME use timux
#Add 


