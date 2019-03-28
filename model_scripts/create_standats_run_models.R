create_standat <- function(data_file, pos_vars, neg_vars) {
  dataset <- read.csv(data_file)
  
  #FIXME check null case
  pos_formula <- as.formula(paste("~", pos_vars, "-1"))
  x_cns_pos <- unname(model.matrix(pos_formula, dataset)) # constrained positive
  attr(x_cns_pos, "assign") <- NULL
  
  neg_formula <- as.formula(paste("~", neg_vars, "-1"))
  x_cns_neg<- unname(model.matrix(neg_formula, dataset)) # constrained negative 
  attr(x_cns_neg, "assign") <- NULL
  
  x_oth <- unname(model.matrix(~1, dataset)) # unconstrained
  attr(x_oth, "assign") <- NULL
  x_u <- unname(model.matrix(~1, dataset)) # unmodelled (subject-level)
  attr(x_u, "assign") <- NULL
  x_w <- unname(model.matrix(~1, dataset)) # unmodelled (item-level)
  attr(x_w, "assign") <- NULL  
  
  dep_var <- dataset[["user_corr"]]
  subj_var <- dataset[["subject_id"]]
  item_var <- dataset[["trip_id_2"]]
  
  return(list(accuracy=as.integer(dep_var),
              subj=as.numeric(factor(subj_var)),
              item=as.numeric(factor(item_var)),
              
              N_obs = nrow(dataset),
                  
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
                  
              N_subj=length(unique(subj_var)),
              N_item=length(unique(item_var))))
}

fit_and_save_stan_mod <- function(stan_model_filename,
                         standat,
                         chains,
                         iterations,
                         seed,
                         output_filename) { # UPDATE THIS
  model <- rstan::stan(stan_model_filename,
                     data = standat,
                     chains = chains,
                     iter = iterations,
                     seed = seed)
  saveRDS(model, file=output_filename)
}


library(doParallel)
options(cores=4) #set this appropriate to your system
registerDoParallel()

# to be udpated - command line
stan_model_filename <- "stan_models/master_model.stan"
chains <- 1
iterations <- 200
seed <- 10
data_dir <- "sampled_datasets"
model_fit_dir <- "modelfits"


#num_fits <- nrow(master_df)

DUMMY <- foreach(i = 1:2) %dopar% fit_and_save_stan_mod(
  stan_model_filename, #cmd line
  create_standat(paste0(data_dir, "/", master_df[["csv_filename"]][[i]]),
                 master_df[["pos_vars"]][[i]],
                 master_df[["neg_vars"]][[i]]),
  chains, #cmd line
  iterations, #cmd line
  seed, #cmd line
  paste0(model_fit_dir, "/",
         paste0(master_df[["standat_filename"]][[i]], ".rds")) # to be updated
)

