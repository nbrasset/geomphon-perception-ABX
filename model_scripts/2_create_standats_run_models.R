#using sampled .csv datafile and model parameters taken from master_df
#make standats, save them, and then run the models 

create_standat<-"create_standat_function_pos_neg.R"
source(create_standat)


data_folder<-"hindi_kab_for_comparison"
master_df<-readr::read_csv("master_df.csv")


master_df$standat_hk <- vector(mode="list", length=nrow(master_df))
master_df$hindi_kab <- NA


# master_df$standat_hk<-purrr::map(,create_standat(data_file= paste(data_folder,
#                                                                        master_df$csv_filename[i],
#                                                                        sep ="/"),
#                                                       pos_vars= master_df$pos_vars[i],
#                                                       neg_vars= master_df$neg_vars[i]))
# 



for (i in 1:nrow(master_df)) {
  
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
library(doParallel)
options(cores=10) #set this appropriate to your system
registerDoParallel()

fit_save_stan_mod <- "fit_save_stan_mod_function.R"
source(fit_save_stan_mod)


DUMMY <- foreach(i = 1:2) %dopar% 
  fit_save_stan_mod(stan_model_filename = master_df$stanfile[i],
                        standat             = master_df$standat_hk[[i]],
                        chains              = 2,
                        iter                = 400,
                        seed                = 12347,
                        output_filename     = paste("hindi_kab_rds",
                                                    "/",
                                                    master_df$model_data_name[i],
                                                    ".rds",
                                                    sep=""))
  
listofbatches <- 
#define batches 
for (batch in listofbatches){
  
    for (i in min(batch):max(batch)) {
      
      filelist = list.files("hindi_kab_rds")
      out_name = paste("hindi_kab_rds",
                                  "/",
                                  master_df$model_data_name[i],
                                  ".rds",
                                  sep="")
      
      if (!contains(filelist,out_name)){
        fit_save_stan_mod(stan_model_filename = master_df$stanfile[i],
                          standat             = master_df$standat_hk[[i]],
                          chains              = 2,
                          iter                = 400,
                          seed                = 12347,
                          output_filename     = out_name)
      } else {
        i = i+1 
      }
    }
}