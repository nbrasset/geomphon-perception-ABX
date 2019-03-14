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


sample_binary<-"sample_binary_function.R"
source(sample_binary)

#m1_dat$var1<-m1_dat$var1-mean(m1_dat$var1)
#m1_dat$var2<-m1_dat$var2-mean(m1_dat$var2)
#m1_dat$var3<-m1_dat$var3-mean(m1_dat$var3)


sample_binary(d = m1_dat,response_var = "user_corr",
                         predictor_var = "var2", coef_value = 0) %>%
write.csv(file="sampled_datasets/zero_resp.csv")

sample_binary(d = m1_dat,response_var = "user_corr",
                        predictor_var = "var2", coef_value = 1) %>%
write.csv(file="sampled_datasets/pos_resp.csv")

sample_binary(d = m1_dat,response_var = "user_corr",
                        predictor_var = "var2", coef_value = -1) %>%
write.csv(file="sampled_datasets/neg_resp.csv")

sample_binary(d = m1_dat,response_var = "user_corr",
                        predictor_var = "var2", coef_value = 2) %>%
write.csv(file="sampled_datasets/pos_resp_2.csv")

sample_binary(d = m1_dat,response_var = "user_corr",
                        predictor_var = "var2", coef_value = -2) %>%
write.csv(file="sampled_datasets/neg_resp_2.csv")


sample_binary(d = m1_dat,response_var = "user_corr",
              predictor_var = "var2", coef_value = 3) %>%
  write.csv(file="sampled_datasets/pos_resp_3.csv")

sample_binary(d = m1_dat,response_var = "user_corr",
              predictor_var = "var2", coef_value = -3) %>%
  write.csv(file="sampled_datasets/neg_resp_3.csv")


sample_binary(d = m1_dat_130,response_var = "user_corr",
              predictor_var = "var2", coef_value = 1) %>%
  write.csv(file="sampled_datasets/pos_resp_s130.csv")

sample_binary(d = m1_dat_130,response_var = "user_corr",
              predictor_var = "var2", coef_value = -1) %>%
  write.csv(file="sampled_datasets/neg_resp_s130.csv")