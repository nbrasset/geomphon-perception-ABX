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
library(stringr)

#ARGS <- commandArgs(TRUE)


dataset_folder<-("sampled_datasets") #ARGS[1] "sampled_datasets"
model_folder<-("stan_models") #ARGS[2] "stan_models"
outfile<-("masterdf.RData")#ARGS[3] "masterdf.RData"


vec_of_ds_filenames <- list.files(path=dataset_folder,recursive=T)
full_files <- paste(dataset_folder,vec_of_ds_filenames,sep="/")
dataset_list <- lapply(full_files, read.csv) 


list_of_Standats = list()

for (i in 1:length(dataset_list)){
  
  ds<-dataset_list[[i]]
  name<-vec_of_ds_filenames[i]
  
  x_cns <- unname(model.matrix(~var2-1,ds)) # constrained
  attr(x_cns, "assign") <- NULL
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
                  
                  N_cf_cns = ncol(x_cns),
                  N_cf_oth = ncol(x_oth),
                  N_cf_u = ncol(x_u),
                  N_cf_w = ncol(x_w),
                  
                  x_cns = x_cns,
                  x_oth = x_oth,
                  x_u = x_u,
                  x_w = x_w,
                  
                  N_subj=length(unique(subj_col)),
                  N_item=length(unique(item_col)) )
  
  list_of_Standats[[i]] <- newlist
}

vec_names_stan_models<-list.files(path=model_folder, pattern="*.stan")
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
iter<- as.numeric(unlist(rep("2000",times=lenstandats*lenstanmods))) #FIXME(shortened)
chains<-as.numeric( unlist(rep("4",times=lenstandats*lenstanmods))) #FIXME(shortened)
seed<- as.numeric(unlist(rep("123456",times=lenstandats*lenstanmods)))

masterdf<-as.data.frame(cbind(stan_model_name,data_name,fit_file_name,data,iter,chains,seed))

save(masterdf, file=outfile)
