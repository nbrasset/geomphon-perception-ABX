#!/usr/bin/env Rscript

#using sampled .csv datafile and model parameters taken from master_df
#make standats, save them, and then run the models 
#Rscript --vanilla create_standats_run_models.R "hindi_kab_for_comparison" "master_df.csv"
# Author: Ameila Kimball

ARGS <- commandArgs(TRUE)

DATA_FOLDER <-ARGS[1]# "hindi_kab_for_comparison"#  
MASTER <- ARGS[2] #"master_df.csv" #  



################
#CREATE STANDAT#
################
master_df<-readr::read_csv(MASTER)

create_standat<-"create_standat_function_pos_neg.R"
source(create_standat)

master_df$standat_hk <- vector(mode="list", length=nrow(master_df))
master_df$hindi_kab <- NA
#TODO:amelia  change this loop to purrr
#write a fucntion to create this function, 
#write a function that takes three inputs and then it will stick them in as the three 
#arguments 


for (i in 1:nrow(master_df)) {
  
  master_df$standat_hk[[i]] <- create_standat(data_file= paste(DATA_FOLDER,
                                                        master_df$csv_filename[i],
                                                        sep ="/"),
                                        pos_vars= master_df$pos_vars[i],
                                        neg_vars= master_df$neg_vars[i])
                                       
  master_df$hindi_kab[i] <- paste(DATA_FOLDER,
                               master_df$csv_filename[i],
                               sep ="/")
                            }




######################
#fit  and save models#
######################
library(rstan)
library(doParallel)
options(cores=10) #set this appropriate to your system/ batch size
registerDoParallel()

fit_save_stan_mod <- "fit_save_stan_mod_function.R"
source(fit_save_stan_mod)

#batchname 
batchlist<- list(c(1:5),
            c(6:10))

            # c(21:30),
            # c(31:40),
            # c(41:50),
            # c(51:60),
            # c(61:70),
            # c(71:80),
            # c(81:90),
            # c(91:100),
            # c(101:110),
            # c(111:120),
            # c(121:130),
            # c(131:140),
            # c(141:150),
            # c(151:160),
            # c(161:170),
            # c(171:180),
            # c(181:190),
            # c(191:200),
            # c(201:210),
            # c(211:220),
            # c(221:230),
            # c(231:240),
            # c(241:250),
            # c(251:260),
            # c(261:270),
            # c(271:280),
            # c(281:290),
            # c(291:300),
            # c(301:310),
            # c(311:320),
            # c(321:330),
            # c(331:340),
            # c(341:350),
            # c(351:360),
            # c(361:370),
            # c(371:380),
            # c(381:390),
            # c(391:400),
            # c(401:410),
            # c(411:420),
            # c(421:430),
            # c(431:432))


                # c(1:10),
                #   c(21:40),
                #   c(41:60),
                #   c(61:80),
                #   c(81:100),
                #   c(101:120),
                #   c(121:140),
                #   c(141:160),
                #   c(161:180),
                #   c(181:200),
                #   c(201:220),
                #   c(221:240),
                #   c(241:260),
                #   c(261:280),
                #   c(281:300),
                #   c(301:320),
                #   c(321:340),
                #   c(341:360),
                #   c(361:380),
                #   c(381:400),
                #   c(401:420),
                #   c(421:432))

filelist = list.files("hindi_kab_rds")

for (batch in batchlist){
      DUMMY <- foreach(i = min(batch):max(batch)) %dopar% {
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
                            chains              = 4,
                            iter                = 2000,
                            seed                = master_df$seed[i],
                            output_filename     = out_file)
        } else {
          print(paste(out_file,"already exists, model skipped",sep=" "))
        }
      }
}






