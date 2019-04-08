#fit_and_save_stan_mod

#' fit and save a stan mod 
#'
#' @param stan_model_filename 
#' @param standat 
#' @param chains 
#' @param iterations 
#' @param seed 
#' @param output_filename 
#' @return 
#


fit_save_stan_mod <- function(stan_model_filename,
                                  standat,
                                  chains,
                                  iterations,
                                  seed,
                                  output_filename) {
  
    model <- rstan::stan(stan_model_filename,
                         data = standat,
                         chains = chains,
                         iter = iterations,
                         seed = seed)
    
    saveRDS(model, file=output_filename)
  }
  
  