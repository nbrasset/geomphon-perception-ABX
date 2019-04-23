#using sampled .csv datafile and model parameters taken from master_df
#make standats, save them, and then run the models 

create_standat<-"create_standat_function_pos_neg.R"
source(create_standat)


data_folder<-"hindi_kab_for_comparison"

master_df<-readr::read_csv("master_df.csv")


master_df$standat_hk <- vector(mode="list", length=nrow(master_df))
master_df$hindi_kab <- NA


#write a fucntion to create this function, 
#write a function that takes three inputs and then it will stick them in as the three 
#arguments, then you can use purrr. 

# #master_df$standat_hk<-purrr::pmap( ,create_standat(data_file= paste(data_folder,
#                                                                        master_df$csv_filename[i],
#                                                                        sep ="/"),
#                                                        pos_vars= master_df$pos_vars[i],
#                                                        neg_vars= master_df$neg_vars[i]))




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
options(cores=4) #set this appropriate to your system
registerDoParallel()

fit_save_stan_mod <- "fit_save_stan_mod_function.R"
source(fit_save_stan_mod)


#listofbatches <- for (i in 1:nrow(master_df)) {
  
  
#}

  #define batches 
#  for (batch in listofbatches){
    
    
    #foreach (i = min(batch):max(batch))
    
    foreach (i = 1:3) %dopar% {
      filelist = list.files("hindi_kab_rds")
      filename = paste(master_df$model_data_name[i],
                      ".rds",
                      sep="")
      out_file = paste("hindi_kab_rds",
                                  "/",
                                  master_df$model_data_name[i],
                                  ".rds",
                                  sep="")
      
        if (!filename %in% filelist){
          fit_save_stan_mod(stan_model_filename = master_df$stanfile[i],
                            standat             = master_df$standat_hk[[i]],
                            chains              = 1,
                            iter                = 100,
                            seed                = 12347,
                            output_filename     = out_file)
        } else {
         print(paste(out_file,"already exists, skipping model",sep=" "))
        }
     }
 # }