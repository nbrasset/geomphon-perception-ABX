#comapre loos 

master_df<-readr::read_csv("master_df.csv")

#calculate which pairs are of interest 
correct_mods<-dplyr::filter(master_df, modelcorrect=="yes")
cor_mod_7<-correct_mods[rep(seq_len(nrow(correct_mods)), each=7),]
correct_model<-cor_mod_7$model_data_name
wrong_mods<-dplyr::filter(master_df,modelcorrect=="no")
wrong_model<-wrong_mods$model_data_name
mod_pairs<-cbind(wrong_model,correct_model)
mod_pairs<-as.data.frame(mod_pairs)

#compare loos of those pairs, return output to new file 


for i in (1:nrow(mod_pairs)) {
  wrong_mod<-readRDS("econ_1_loc_-1_glob_-1_mod_loc.rds")
  corr_mod<-readRDS(mod_pairs$correct_model[i])
  loo_wrong<-loo(wrong_mod)
  loo_corr<- loo(corr_mod)
  comparison<-compare(loo_wrong,loo_corr)
  print(mod_pairs$wrong_model[i],mod_pairs$correct_model[i], comparison)
}


