#!/usr/bin/env Rscript

# using sampled .csv datafile and model parameters taken from master_df
# make standats, save them, and then run the models 
# Author: Ameila Kimball


ARGS <- commandArgs(TRUE)

DATA_FOLDER <-  ARGS[1]#"hindi_kab_for_comparison"# 
MASTER <- ARGS[2] # "master_df.csv" # 
RDS_FOLDER<- ARGS[3] # "hindi_kab_rds" # 


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
options(cores=8) #ceiling number of cores to use total
options(mc.cores = 4)#cores per model (= should equal numb of chains) 
registerDoParallel()

fit_save_stan_mod <- "fit_save_stan_mod_function.R"
source(fit_save_stan_mod)

#batchname 
batchlist<- list(c(1:5),
                 c(6:10),
                 c(11:15),
                 c(16:20),
                 c(21:25),
                 c(26:30),
                 c(31:35),
                 c(36:40),
                 c(41:45),
                 c(46:50),
                 c(51:55),
                 c(56:60),
                 c(61:65),
                 c(66:70),
                 c(71:75),
                 c(76:80),
                 c(81:85),
                 c(86:90),
                 c(91:95),
                 c(96:100))
# 
#                  c(101:105),
#                  c(106:110),
#                  c(111:115),
#                  c(116:120),
#                  c(121:125),
#                  c(126:130),
#                  c(131:135),
#                  c(136:140),
#                  c(141:145),
#                  c(146:150),
#                  c(151:155),
#                  c(156:160),
#                  c(161:165),
#                  c(166:170),
#                  c(171:175),
#                  c(176:180),
#                  c(181:185),
#                  c(186:190),
#                  c(191:195),
#                  c(196:200),
#                  c(201:205),
#                  c(206:210),
#                  c(211:215),
#                  c(216:220),
#                  c(221:225),
#                  c(226:230),
#                  c(231:235),
#                  c(236:240),
#                  c(241:245),
#                  c(246:250),
#                  c(251:255),
#                  c(256:260),
#                  c(261:265),
#                  c(266:270),
#                  c(271:275),
#                  c(276:280),
#                  c(281:285),
#                  c(286:290),
#                  c(291:295),
#                  c(296:300),
#                  c(301:305),
#                  c(306:310),
#                  c(311:315),
#                  c(316:320),
#                  c(321:325),
#                  c(326:330),
#                  c(331:335),
#                  c(336:340),
#                  c(341:345),
#                  c(346:350),
#                  c(351:355),
#                  c(356:360),
#                  c(361:365),
#                  c(366:370),
#                  c(371:375),
#                  c(376:380),
#                  c(381:385),
#                  c(386:390),
#                  c(391:395),
#                  c(396:400),
#                  c(401:405),
#                  c(406:410),
#                  c(411:415),
#                  c(416:420),
#                  c(421:425),
#                  c(426:430),
#                  c(431:432),


filelist = list.files(RDS_FOLDER)

for (batch in batchlist){
      DUMMY <- foreach(i = min(batch):max(batch)) %dopar% {
        filename = paste(master_df$model_data_name[i],
                         ".rds",
                         sep="")
        out_file = paste(RDS_FOLDER,
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







