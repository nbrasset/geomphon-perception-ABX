#using sampled .csv datafile and model parameters taken from master_df
#make standats, save them, and then run the models 

create_standat<-"create_standat_function_pos_neg.R"
source(create_standat)


data_folder<-"hindi_kab_for_comparison"

#Now in masterdf--should it be?? FIXME
#write a small function that maps pos vars and neg vars to the correct model 
#file to fill in

#do this with purr/ mutate  purrr::map 




for (i in 1:nrow(master_df)){
  master_df$standat_hk[[i]] <- create_standat(data_file= paste(data_folder,
                                                        master_df$csv_filename[i],
                                                        sep ="/"),
                                       pos_vars= master_df$pos_vars[i],
                                       neg_vars= master_df$neg_vars[i])
  master_df$hindi_kab[i] <- paste(data_folder,
                               master_df$csv_filename[i],
                               sep ="/")
                            }



######################
#fit  and save models#
######################


library(rstan)

fit_save_stan_mod <- "fit_save_stan_mod_function.R"
source(fit_save_stan_mod)

                    
for(i in 1:3) {
  fit_save_stan_mod(stan_model_filename = master_df$stanfile[i],
                    standat = master_df$standat_hk[i],
                    chains = 2,
                    iter = 400,
                    seed = 12347,
                    output_filename = paste("hindi_kab_rds",
                                            "/",
                                            master_df$model_data_name[i],
                                            ".rds",
                                            sep=""))
}




my_mod<-fit_save_stan_mod(stan_model_filename = "stan_models/master_model.stan",
                  standat = hk_standat_list[[18]],
                  chains = 2,
                  iter = 300,
                  seed = 12347,
                  output_filename = paste("my_name_is_output.rds"))




#############
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

