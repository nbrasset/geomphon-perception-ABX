#' Samples binary responses from a logistic regression model with a
#' given coefficient set to a given value.
#'
#' @param d A data frame
#' @param response_var The name of a column in `d` containing only 0 and 1
#' @param predictor_var The name of a column in `d`
#' @param coef_value The coefficient value to use for sampling
#' 
#' @return data frame identical to `d`, with `response_var` replaced with
#' values sampled from a logistic regression model fit to `d` that has 
#' `response_var`as the response variable and `predictor_var` as the sole 
#' predictor variable, with the value of the coefficient for `predictor_var` 
#' replaced with `coef_value`
#' 
#' 
sample_binary <- function(d, response_var, predictor_var, coef_value) {
   if (!is.data.frame(d)) {
     stop("d is not a data frame")
   }
   if (!(response_var %in% names(d))) {
     stop(paste0("d must contain '", response_var, "' as a column"))
   }
   if (!(predictor_var %in% names(d))) {
     stop(paste0("d must contain '", predictor_var, "' as a column"))
   }
   if (!identical(as.double(sort(unique(d[[response_var]]))), c(0,1))) {
     stop("response variable should consist of only 0 and 1")
   }
   if (!is.numeric(coef_value)) {
     stop("value of coefficient must be numeric")
   }

  f <- paste(as.character(response_var), as.character(predictor_var), sep=" ~ ")
  
  m <- glm(formula(f), data=d, family="binomial")
  m$coefficients[predictor_var] <- coef_value
  pred_prob <- predict(m, type="response", newdata=d)
  for (i in 1:nrow(d)){
    d[[response_var]][i] <- sample(c(0,1), 1,
                                   prob=c((1-pred_prob[i]), pred_prob[i]))
  }
  return(d) 
}
