#' Adds the prediction columns to a piped command set
#' 
#' Adds a new column with the results form predict_fit() to a piped command set.
#' If add_interval is set to TRUE, then it will add two additional columns, one 
#' for the lower and another for the upper prediction interval bounds.  
#' 
#' 
#' @param df A data.frame or tibble
#' @param model An R object, typically an R model, but it can also bee a regular data frame 
#' that has a parsed model already loaded.
#' @param add_interval Switch that indicates if the prediction interval columns should be added. Defaults
#' to FALSE
#' @param interval The prediction interval, defaults to 0.95. It is ignored if add_interval is set to
#' FALSE
#' @param vars The name of the variables that this function will produce. It defaults to "fit", "upper", and "lower".
#'
#' @examples
#' 
#' library(dplyr)
#' 
#' df <- data.frame(x = c(1, 2, 5, 6 ,6), y = c(2, 3, 6, 5, 4))
#' model <- lm(x ~ y, df)
#' df %>%
#'   predict_to_column(model, add_interval = TRUE)
#'
#' @import rlang
#' @importFrom purrr reduce
#' @import dplyr
#' @export
predict_to_column <- function(df, model, add_interval = FALSE, interval = 0.95, vars = c("fit", "upper", "lower")){
  
  fit <- vars[1]
  upper <- vars[2]
  lower <- vars[3]
  
  df <- mutate(df, !! fit := !! predict_fit(model))
  
  if(add_interval){
    
    formulas <- c(sym(fit) , predict_interval(model, interval = interval))
    upper_formula <- reduce(formulas, function(l, r) expr((!!l) + (!!r)))
    lower_formula <- reduce(formulas, function(l, r) expr((!!l) - (!!r)))
    
    df <- mutate(df, 
                 !! upper := !! upper_formula,
                 !! lower := !! lower_formula)
  }
  
  df
}