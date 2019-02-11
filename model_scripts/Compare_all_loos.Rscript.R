#!/usr/bin/env Rscript

# takes as input the master df created in Create_masterdf_for_stanfits.RScript
# NB refers to a directory of modelfits to create loo values!
# outputs a tibble with elpd_diff and se values for loo comparisons of all 
# combinations of models #FIXME(should be just same dataset)


rm(list=ls())
library(plyr)
library(dplyr)
library(tidyr)
library(magrittr)
library(readr)

ARGS <- commandArgs(TRUE)

masterdf_file<-"model_scripts/masterdf.RData" #ARGS[1]
outfile<-"loo_comparisons.csv" #ARGS[2]

masterdf<-load(masterdf_file)

fit_name_loo_o<- list()
loo_o <- list()
log_lik_o <- list()


for (i in 1:nrow(masterdf)){
  fit<-readRDS(masterdf[["fit_file_name"]][[i]])
  fit_name_loo_o[[i]]<-masterdf[["fit_file_name"]][[i]]
  loo_o[[i]]<-loo(fit)
  log_lik_o[[i]]<-extract_log_lik(
    fit, parameter_name = "log_lik", merge_chains = TRUE)
}


loo_df <- tibble::tibble(
  fit_name_loo=fit_name_loo_o,
  loo=loo_o,
  log_lik=log_lik_o
)


loo_list<-loo_df[["loo"]]
loo_pairs<-combn(1:length(loo_list),2)

models_compared_o<-c()
loo_comp_o <- list()

for (i in 1:ncol(loo_pairs)){
  loo_num_1<-loo_pairs[1,i]
  loo_num_2<-loo_pairs[2,i]
  name1<-loo_df$fit_name_loo[loo_num_1]
  name2<-loo_df$fit_name_loo[loo_num_2]
  models_compared_o[[i]]<-paste(name1,name2,sep="__")
  loo_comp_o[[i]]<-compare(loo_list[[loo_num_1]], loo_list[[loo_num_2]])
}


loo_comp_df <- tibble::tibble(
  models_compared=models_compared_o,
  loo_comp=loo_comp_o
)

write_csv(loo_comp_df,path=outfile)
