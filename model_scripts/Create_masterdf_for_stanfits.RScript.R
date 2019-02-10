#!/usr/bin/env Rscript

# input: a directory with stan models, and a directory with data sets. 
# converts the datasets to Standat format. 
# creates a master df where each line has all the inputs for running one 
# fit with one stan model and one dataset 
# df is as long as models*datasets. 

library(plyr)
library(dplyr)
library(tidyr)
library(magrittr)

ARGS <- commandArgs(TRUE)


dataset_folder<-("sampled_datasets") #ARGS[1] "sampled_datasets"
model_folder<-("stan_models") #ARGS[2] "stan_models"
outfile<-("masterdf.csv")#ARGS[3] "masterdf.csv"


vec_of_ds_filenames <- list.files(path=dataset_folder,recursive=T)
full_files <- paste(dataset_folder,vec_of_ds_filenames,sep="/")
dataset_list <- lapply(full_files, read.csv) 


list_of_Standats = list()

for (i in 1:length(dataset_list)){
  
  ds<-dataset_list[[i]]
  name<-vec_of_ds_filenames[i]
  
  x <- unname(model.matrix(~1+var2, data=ds)) # matrix for fixed effects
  attr(x, "assign") <- NULL
  x_u <- unname(model.matrix(~1,ds)) # matrix random eff subjects. now intercepts only
  attr(x_u, "assign") <- NULL
  x_w <- unname(model.matrix(~1,ds)) # matrix random eff items. now intercepts only
  attr(x_w, "assign") <- NULL  
  
  listname = paste("StanDat_",ds,sep="")#name of the new Standata list 
  
  
  dv_col= ds$user_corr# column name for dependent variable in dataset 
  subj_col= ds$subject_id# column name for subject variable in dataset 
  item_col = ds$trip_id_2# column name for item variable in dataset 
  
  newlist <- list(accuracy = as.integer(dv_col),     # dependent variable
                  
                  subj=as.numeric(factor(subj_col)), # subject id
                  item=as.numeric(factor(item_col)), # item id
                  
                  N_obs = nrow(ds),             # number of observations
                  
                  N_coef = ncol(x),                  # number of fixed effects
                  N_coef_u = ncol(x_u),              # number of random effects for subjects
                  N_coef_w = ncol(x_w),              # number of random effects for items
                  
                  x = x,                             # fixed effects matrix
                  x_u = x_u,                         # random effects matrix - subjects
                  x_w = x_w,                         # random effects matrix - items
                  
                  N_subj=length(unique(subj_col)),   # number of subjects
                  N_item=length(unique(item_col)) )  # number of items
  
  list_of_Standats[[i]]<-newlist
  
}



vec_names_stan_models<-list.files(path=model_folder)
lenstanmods<-length(vec_names_stan_models)
lenstandats<-length(list_of_Standats)


stan_model_name<- rep(vec_names_stan_models,each=lenstandats)
data_name<-rep_len(vec_of_ds_filenames,length.out=lenstandats*lenstanmods)
fit_file_name<-paste("modelfits/",
                     str_replace(data_name,"\\..*",""),
                     "/",
                     str_replace(stan_model_name,"\\..*",""),
                     ".rds",
                     sep="")
data<- rep_len(list_of_Standats,length.out=lenstandats*lenstanmods)
iter<- as.numeric(unlist(rep("200",times=lenstandats*lenstanmods))) #FIXME(shortened)
chains<-as.numeric( unlist(rep("2",times=lenstandats*lenstanmods))) #FIXME(shortened)
seed<- as.numeric(unlist(rep("123456",times=lenstandats*lenstanmods)))

masterdf<-as.data.frame(cbind(stan_model_name,data_name,fit_file_name,data,iter,chains,seed))

write.csv(masterdf, file=outfile)