library(dplyr) 

filter_df <- function(df, local_area, meals_provided, pets_welcome, carts_allowed){
  if (nrow(df) == 0) {
    stop("Dataframe is empty.")
  }
  
  if (meals_provided) df <- df |> filter(meals == 'yes')
  if (pets_welcome) df <- df |> filter(pets == 'yes')
  
  # Only filter by local_area if it's selected
  if (!is.null(local_area) && length(local_area) > 0) {
    df <- df |> filter(geo_local_area %in% local_area)
  }
  
  return(df)
}
