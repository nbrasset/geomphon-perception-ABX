#' initializes master dataframe to be used to create datasets and standats in
#' next script. 
#' 
#' 
#'@param vars list of strings of names of each variable
#'@param coef_vals list of numeric values to be used as coefficients for 
#'         each variable 
#' @param num_data_sets integer number of dfs to be sampled for each coef value
#'     (sampling occurs in a different script)
#
#' @return data frame of length [num_data_sets]*with `coefs_econ`, `coefs_loc`
#' with an ID for each dataset, specifying which variables have positive 
#' expected values (pos_vars), which model should be correct, 
#'
#' 
#' 
#'
#'#reshape, dplyr, zoo

#initialize empty data frame

#fill in coeffs * num datasets 

#calculate and fill in positive_vars

#based on positive_vars fill in model_correct

#for each block of  coeffs, repeat for each model 

#create the name of the csv for the data (data is NOT created here)

#create the name of the standat (standat is NOT created here)


create_masterdf <- function(vars, coef_vals,num_data_sets) {
  if (!is.list(vars)) {
    stop("vars must be a list")
  }
  if (!is.list(coef_vals)) {
    stop("coef_vals must be a list")
  }
  if (!is.integer(num_data_sets)) {
    stop("num_data_sets must be an integer")
  }
  
  
  df<-expand.grid(coef_vals,coef_vals, coef_vals)
  x <- c("coef_econ","coef_loc", "coef_glob")
  colnames(df) <- x
 
  df$pos_vars<- 
    case_when(
      df$coef_econ >  0 & df$coef_glob >  0 & df$coef_loc >  0 ~ "econ_glob_loc",
      df$coef_econ >  0 & df$coef_glob >  0 & df$coef_loc <= 0 ~ "econ_glob",
      df$coef_econ >  0 & df$coef_glob <= 0 & df$coef_loc >  0 ~ "econ_loc",
      df$coef_econ <= 0 & df$coef_glob >  0 & df$coef_loc >  0 ~ "glob_loc",
      df$coef_econ >  0 & df$coef_glob <= 0 & df$coef_loc <= 0 ~ "econ",
      df$coef_econ <= 0 & df$coef_glob >  0 & df$coef_loc <= 0 ~ "glob",
      df$coef_econ <= 0 & df$coef_glob <= 0 & df$coef_loc >  0 ~ "loc",
      df$coef_econ <= 0 & df$coef_glob <= 0 & df$coef_loc <= 0 ~ "none")
 
  
  #expand by the list of all the models 
  model_list<-as.data.frame(c("econ_glob_loc", "econ_glob", "econ_loc","glob_loc","econ", 
                "glob","loc","none"))
  df_mods<-expand.grid.df(model_list,df)
  names(df_mods)[1]<- 'model'
  
  
  #add a model correct column
  df_mods$modelcorrect<-case_when(df_mods$pos_vars==df_mods$model~ "yes",
                                   df_mods$pos_vars!=df_mods$model~"no")
  
  
  #create standat name column
  
  #FIXme add model name to standat
  df_mods$standat_filename<-paste("econ_",df_mods$coef_econ,
                                  "_loc_",df_mods$coef_loc,
                                  "_glob_",df_mods$coef_glob,
                                  ".stan", sep="")
  
  #create csv name 
  df_mods$csv_filename<-paste("econ_",df_mods$coef_econ,
                                  "_loc_",df_mods$coef_loc,
                                  "_glob_",df_mods$coef_glob,
                                  ".csv", sep="")
  
  #multiply the whole thing by the number of datasets wanted. 
  
 #full_df<- coredata(df_mods)[rep(seq(nrow(df_mods)),2),]
 full_df<-do.call("rbind", replicate(num_data_sets, df_mods, simplify = FALSE))
  
return(full_df) 
}
