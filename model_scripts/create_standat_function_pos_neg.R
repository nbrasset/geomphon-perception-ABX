
#' Creates a standat file to be input to the model 
#' given coefficient set to a given value.
#'
#' @param data_file a .csv data file with columns user_corr, "subject_id""trip_id_2"
#' @param pos_vars a character vector of the positive variables 
#' with plus signs between s.t. they will create a formula
#' @param neg_vars a character vector of the negative variables 
#' with plus signs between s.t. they will create a formula
#' @return standat list which will be the "file" input of stan()

create_standat <- function(data_file, pos_vars, neg_vars) {
  dataset <- readr::read_csv(data_file)
  
  
  #FIXME check null case
  #if pos_vars is not empty, do this. IF there are pos_vars, add the entry pos_vars 
  # to the list
  #if both are empty print out a warning because that should never happen
  
  
  x_oth <- unname(model.matrix(~1, dataset)) # unconstrained
  attr(x_oth, "assign") <- NULL
  x_u <- unname(model.matrix(~1, dataset)) # unmodelled (subject-level)
  attr(x_u, "assign") <- NULL
  x_w <- unname(model.matrix(~1, dataset)) # unmodelled (item-level)
  attr(x_w, "assign") <- NULL  
  
  dep_var <- dataset[["response_var"]]
  subj_var <- dataset[["subject"]]
  item_var <- dataset[["trial"]]
  
  
  stan_list<- list(accuracy=as.integer(dep_var),
                   subj=as.numeric(factor(subj_var)),
                   item=as.numeric(factor(item_var)),
                   N_obs = nrow(dataset),
                   N_cf_oth = ncol(x_oth),
                   N_cf_u = ncol(x_u),
                   N_cf_w = ncol(x_w),
                   x_oth = x_oth,
                   x_u = x_u,
                   x_w = x_w,
                   N_subj=length(unique(subj_var)),
                   N_item=length(unique(item_var)))
  
  if ( is.na(neg_vars) & is.na(pos_vars)) {
    print ("No constrained variables: something has gone wrong")
  }

  if (!is.na(pos_vars)) {
    pos_formula <- as.formula(paste("~", pos_vars, "-1"))
    x_cns_pos <- unname(model.matrix(pos_formula, dataset)) # constrained positive
    attr(x_cns_pos, "assign") <- NULL
    
    stan_list[["x_cns_pos"]] <- x_cns_pos
    stan_list["N_cf_cns_pos"] <- ncol(x_cns_pos)
  }
  
  if (!is.na(neg_vars)) {
    neg_formula <- as.formula(paste("~", neg_vars, "-1"))
    x_cns_neg <- unname(model.matrix(neg_formula, dataset)) # constrained positive
    attr(x_cns_neg, "assign") <- NULL
    
    stan_list[["x_cns_neg"]] <- x_cns_neg
    stan_list["N_cf_cns_neg"] <- ncol(x_cns_neg)
  }
  
  
  return(stan_list)
}