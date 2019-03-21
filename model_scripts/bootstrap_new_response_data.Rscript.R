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

sample_binary_three(d = m1_dat,response_var = "user_corr",
              predictor_var = "var2", coef_value = 0) %>%
  write.csv(file="sampled_datasets/zero_resp.csv")


#need an input for purr that is a vector of coefs pulled from master df

purrr::map(master_df$coef_econ, mean)

for (i in 1:nrow(master_df)){
  sample_binary(d = m1_dat,
                response_var = "user_corr",
                predictor_var = "var2", 
                coef_value = 0) %>%
    write.csv(file="sampled_datasets/zero_resp.csv")
  
}
     




