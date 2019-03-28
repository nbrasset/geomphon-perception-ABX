#!/usr/bin/env Rscript
library(rstan)
library(foreach)
library(doParallel)
library(doMC)

ARGS <- commandArgs(TRUE)
masterdf_fn <- ARGS[1]
num_cores <- as.integer(ARGS[2])
registerDoMC(cores=num_cores)
options(mc.cores = 4)
rstan_options("auto_write" = TRUE)

load(masterdf_fn)

#stan_models <- unique(masterdf$stan_model_name)
#
#compile_stan_model <- function(s) {
#  DUMMY <- rstan::stan_model(paste0("stan_models/", s), model_name=s)
#}
#
#foreach(s=stan_models) %do% compile_stan_model(s)

fit_stan_mod <- function(i){
  model<-stan(file = paste("stan_models",
                           masterdf[["stan_model_name"]][[i]],sep = "/"),
              data = masterdf[["data"]][[i]],
              chains = masterdf[["chains"]][[i]],
              iter = masterdf[["iter"]][[i]],
              seed = masterdf[["seed"]][[i]]
  )
  
  saveRDS(model,file =masterdf[["fit_file_name"]][[i]]) # FIXME: path does not exist
}

# FIXME: don't run models we've already fit

num_fits <- nrow(masterdf)

DUMMY <- foreach(i = 1:num_fits) %dopar% fit_stan_mod(i)
