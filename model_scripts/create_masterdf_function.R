#' initializes master dataframe to be used to create datasets and standats in
#' next script. 
#' 
#' 
#'@param vars vector of strings of names of each variable
#'@param coef_vals vector of numeric values to be used as coefficients for 
#'         each variable 
#' @param num_data_sets  number of dfs to be sampled for each coef value
#'     (sampling occurs in a different script)
#
#' @return data frame of length [num_data_sets]*with `coefs_econ`, `coefs_loc`
#' with an ID for each dataset, specifying which variables have positive 
#' expected values (pos_vars), which model should be correct, 
#'
#' 
#' 
#'
#'

create_masterdf <- function(vars, coef_vals,num_data_sets) {
  if (!is.vector(vars)) {
    stop("vars must be a list")
  }
  if (!is.vector(coef_vals)) {
    stop("coef_vals must be a list")
  }
  if (!is.numeric(num_data_sets)) {
    stop("num_data_sets must be numeric")
  }
  
  df<-expand.grid(coef_vals,coef_vals,coef_vals)
  x <- c("coef_econ","coef_loc", "coef_glob")
  colnames(df) <- x

    
  #expand by the list of all the models 
  model_list<-as.data.frame(c("econ_glob_loc", "econ_glob", "econ_loc","glob_loc","econ", 
                                "glob","loc","none"))
  df_mods<-reshape::expand.grid.df(model_list,df)
  names(df_mods)[1]<- 'model_name'
  
  
df_mods$pos_vars<-
  dplyr::case_when(
     df_mods$model_name =="econ_glob_loc" ~ "Econ+Glob+Loc",
     df_mods$model_name =="econ_glob"~ "Econ+Glob",
     df_mods$model_name =="econ_loc"  ~ "Econ+Loc",
     df_mods$model_name =="glob_loc" ~ "Glob+Loc",
     df_mods$model_name =="econ" ~ "Econ",
     df_mods$model_name =="glob"~ "Glob",
     df_mods$model_name =="loc"~ "Loc",
     df_mods$model_name =="none"~ "")

  df_mods$neg_vars<-
    dplyr::case_when(
      df_mods$model_name =="econ_glob_loc" ~  "",
      df_mods$model_name =="econ_glob"~"Loc",
      df_mods$model_name =="econ_loc"~ "Glob",
      df_mods$model_name =="glob_loc"~ "Econ",
      df_mods$model_name =="econ"~"Glob+Loc",
      df_mods$model_name =="glob"~"Econ+Loc",
      df_mods$model_name =="loc"~"Econ+Glob",
      df_mods$model_name =="none"~ "Econ+Glob+Loc")
  

  
  #add a model correct column
  df_mods$modelcorrect<-dplyr::case_when(df_mods$pos_vars==df_mods$model_name~ "yes",
                                   df_mods$pos_vars!=df_mods$model_name~"no"
                                   )
  
  #add a stan file column
  df_mods$stanfile<-dplyr::case_when(df_mods$model_name=="none"~ "stan_models/master_neg.stan",
                                     df_mods$model_name=="econ_glob_loc"~ "stan_models/master_pos.stan",
                                     df_mods$model_name!="econ_glob_loc"&df_mods$model_name!="none"~"stan_models/master_model.stan"
                                     )
  
  #create model name column
  df_mods$model_data_name<-paste("econ_",df_mods$coef_econ,
                                  "_loc_",df_mods$coef_loc,
                                  "_glob_",df_mods$coef_glob,
                                  "_mod_",df_mods$model_name, sep=""
                            )
  
  #create csv name 
  df_mods$csv_filename<-paste("econ_",df_mods$coef_econ,
                                  "_loc_",df_mods$coef_loc,
                                  "_glob_",df_mods$coef_glob,
                                  ".csv", sep=""
                              )
  
  #multiply the whole thing by the number of datasets wanted. 
  
 full_df<- zoo::coredata(df_mods)[rep(seq(nrow(df_mods)),2),]
 full_df<-do.call("rbind", replicate(num_data_sets, df_mods, simplify = FALSE))
  
return(full_df) 
}
