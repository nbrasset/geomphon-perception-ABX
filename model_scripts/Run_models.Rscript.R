#!/usr/bin/env Rscript
library(rstan)
library(doParallel)
library(doMC)

ARGS <- commandArgs(TRUE)
#masterdf<-read.csv("masterdf.csv") #ARGS[1]
num_cores<-15 #ARGS[2]
registerDoMC()
options(cores=num_cores)



fit_stan_mod <- function(i){
  model<-stan(file = paste("stan_models",masterdf[["stan_model_name"]][[i]],sep = "/"),
              data = masterdf[["data"]][[i]],
              chains = masterdf[["chains"]][[i]],
              iter = masterdf[["iter"]][[i]],
              seed = masterdf[["seed"]][[i]]
  )
  
  saveRDS(model,file =masterdf[["fit_file_name"]][[i]])
}


num_fits<-lenstandats*lenstanmods

parallel_fit <- foreach(i = 1:num_fits) %dopar% fit_stan_mod(i)
