#!/usr/bin/env Rscript

# takes as input a .csv with column user_corr coded as integer 0/1 and 
# column var 2. 
# creates three new data sets of the same form, with responses based on 
# coefficient values of var 2 of 0,1, and -1. 


rm(list=ls())
library(plyr)
library(dplyr)
library(tidyr)
library(magrittr)

ARGS <- commandArgs(TRUE)

m1_dat<-"m1_dat.csv"# ARGS[1] "m1_dat.csv"
samp_bin<-"sample_binary_function.R"#ARGS[2] "sample_binary_function.R"

source(samp_bin)

m1_dat$var1<-m1_dat$var1-mean(m1_dat$var1)
m1_dat$var2<-m1_dat$var2-mean(m1_dat$var2)
m1_dat$var3<-m1_dat$var3-mean(m1_dat$var3)


zero_resp<-sample_binary(d = m1_dat,response_var = "user_corr",
                         predictor_var = "var2", coef_value = 0)
write.csv(zero_resp,file="sampled_datasets/zero_resp.csv")

pos_resp<-sample_binary(d = m1_dat,response_var = "user_corr",
                        predictor_var = "var2", coef_value = 1)
write.csv(pos_resp,file="sampled_datasets/pos_resp.csv")

neg_resp<-sample_binary(d = m1_dat,response_var = "user_corr",
                        predictor_var = "var2", coef_value = -1)
write.csv(neg_resp,file="sampled_datasets/neg_resp.csv")
