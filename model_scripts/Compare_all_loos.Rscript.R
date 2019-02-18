#!/usr/bin/env Rscript

# takes as input the master df created in Create_masterdf_for_stanfits.RScript
# NB refers to a directory of modelfits to create loo values!
# outputs a tibble with elpd_diff and se values for loo comparisons of all 
# combinations of models #FIXME(should be just same dataset)


library(plyr)
library(dplyr)
library(tidyr)
library(magrittr)
library(readr)
library(loo)

#ARGS <- commandArgs(TRUE)

options(mc.cores=4) # FIXME

masterdf_file<-"masterdf.RData" #ARGS[1]
outfile<-"loo_comparisons.csv" #ARGS[2]

load(masterdf_file)


fit_name_loo <- c()
loo_o <- list()
log_lik_o <- list()

# FIXME - bad way to do this: will break when you hit comparisons
for (i in 1:nrow(masterdf)){
  fit_fn <- masterdf[["fit_file_name"]][[i]]
  if (file.exists(fit_fn)) {
    fit <- readRDS(fit_fn)
    fit_name_loo[[i]] <- fit_fn
    loo_o[[i]] <- loo(fit)
    log_lik_o[[i]]<-extract_log_lik(fit,
                                    parameter_name = "log_lik",
                                    merge_chains = TRUE)
    rm(fit)
    gc()
  }
}

loo_df <- tibble::tibble(
  loo=loo_o,
  log_lik=log_lik_o,
  data_name=sapply(strsplit(fit_name_loo, "/"), function(x) x[2]), # FIXME
  model_name=sapply(strsplit(fit_name_loo, "/"), function(x) x[3])
)


loo_comparisons <- dplyr::inner_join(loo_df, loo_df, by="data_name",
                                     suffix=c("_A", "_B")) %>%
  dplyr::mutate(loo_comparison=purrr::map2(loo_A, loo_B, ~ compare(.x, .y)),
                elpd_diff=purrr::map_dbl(loo_comparison, ~ .x[1]),
                elpd_diff_se=purrr::map_dbl(loo_comparison, ~ .x[2])) %>%
  dplyr::select(-loo_comparison)

