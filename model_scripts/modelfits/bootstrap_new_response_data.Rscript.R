#!/usr/bin/env Rscript

# takes as input a .csv with column user_corr coded as integer 0/1 and 
# column var 2. 
# creates three new data sets of the same form, with responses based on 
# coefficient values of var 2 of 0,1, and -1. 

#create a dataset 


m1_dat<-read.csv("m1_dat.csv")
m1_dat_130 <- purrr::map_df(seq_len(5),
                            ~ dplyr::mutate(m1_dat,
                                            subject_id=paste0(subject_id, .)))

create_masterdf<-"create_masterdf_function.R"
source(create_masterdf)

master_df<- create_masterdf(vars=c("econ","glob","loc"),
                             coef_vals=c(-1,0,1),
                             num_data_sets = 2)

sample_binary_three<-"sample_binary_three_vars_function.R"
source(sample_binary_three)

uniq_filenames<-unique(master_df$csv_filename)

for (i in 1:length(uniq_filenames)){
sample_binary_three(d = m1_dat,
                response_var = "user_corr",
                predictor_vars = c("var1","var2","var3"),
                coef_values = c(master_df$coef_econ[i],
                                master_df$coef_glob[i],
                                master_df$coef_loc[i])
                ) %>%
    write.csv(file=paste("sampled_datasets/",
                         uniq_filenames[i],
                         sep=""))
}
     

#


