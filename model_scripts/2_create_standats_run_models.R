
create_standat<-"create_standat_function.R"
source(create_standat)


###########
##FIXME DEBUGGING CODE
my_standat<-create_standat(data_file="sampled_datasets/econ_0_loc_0_glob_0.csv",
               pos_vars= master_df$pos_vars[200],
               neg_vars= master_df$neg_vars[200])


mymod <-rstan::stan(file="stan_models/master_model.stan",
             data = my_standat,
             chains = 2,
             iter = 300,
             seed = 472)

#DEBUGGING^^^^^^
##################



fit_and_save_stan_mod <- function(stan_model_filename,
                         standat,
                         chains,
                         iterations,
                         seed,
                         output_filename) 
  { # UPDATE THIS
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

