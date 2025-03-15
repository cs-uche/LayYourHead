library(dplyr)   
library(leaflet) 
library(ggplot2)

create_map <- function(df){
  
  if (nrow(df) == 0) {
    stop("The filtered data frame is empty, cannot create pie chart.")
  }
  map <- leaflet(df) |> 
    addTiles() |> 
    addMarkers(
      ~longitude, ~latitude, 
      popup = ~paste0("<b>Facility Name: </b>", facility, 
                      "<br><b>Phone: </b>", phone, 
                      "<br><b>Category: </b>", category),
      clusterOptions = markerClusterOptions()
    )
  
  return(map)
}


get_pie_chart <- function(df){
  if (nrow(df) == 0) {
    stop("The filtered data frame is empty, cannot create pie chart.")
  }
  
  df_category_counts <- df |> 
    group_by(category) |> 
    summarise(count = n()) 
  
  category_colors <- c(
    "Males" = "#2c7fb8", 
    "Youths" = "#b8562c",
    "Adults" = "#7fcdbb" 
  )
  
  pie_chart <- ggplot(df_category_counts, aes(x = "", y = count, fill = category)) +
    geom_bar(stat = "identity", width = 1, show.legend = TRUE) + 
    coord_polar(theta = "y") +  # Convert to a pie chart
    scale_fill_manual(values = category_colors) +  
    theme_void() + 
    theme(
      legend.position = "top", 
      legend.text = element_text(size = 15), 
      legend.key.size = unit(1, "cm"), 
      legend.title = element_blank() 
    )
  
  return(pie_chart)
}
