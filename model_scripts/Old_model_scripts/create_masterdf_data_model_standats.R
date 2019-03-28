#!/usr/bin/env Rscript

# takes as input a .csv with column user_corr coded as integer 0/1 and 
# column var 2. 
# creates three new data sets of the same form, with responses based on 
# coefficient values of var 2 of 0,1, and -1. 

#create a dataset 

`%>%`<-magrittr::`%>%`

m1_dat<-read.csv("m1_dat.csv")

#create master df
create_masterdf<-"create_masterdf_function.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                             coef_vals=c(-1,0,1),
                             num_data_sets = 2)


######################
#sample data and save#
######################
sample_binary_three<-"sample_binary_three_vars_function.R"
source(sample_binary_three)
uniq_filenames<-unique(master_df$csv_filename)
for (i in 1:length(uniq_filenames)){
sample_binary_three(d = m1_dat,
                response_var = "user_corr",
                predictor_vars = c("var1","var2","var3"),
                coef_values = c(master_df$coef_econ[i],
                                master_df$coef_glob[i],
                                master_df$coef_loc[i])
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


