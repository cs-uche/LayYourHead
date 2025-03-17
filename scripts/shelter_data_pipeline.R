library("arrow")
library("sf")
library("dplyr")
library("optparse")

option_list <- list(
  make_option("--download", action = "store_true", default = FALSE,
              help = "Download shelter data from the City of Vancouver"),
  make_option("--process", action = "store_true", default = FALSE,
              help = "Process and clean the shelter data"),
  make_option("--url", type = "character", default = "https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/homeless-shelter-locations/exports/parquet?lang=en&timezone=America%2FLos_Angeles",
              help = "URL of the dataset"),
  make_option("--raw_path", type = "character", default = "./data/raw/homeless-shelter-locations.parquet",
              help = "Path to save the raw downloaded data"),
  make_option("--clean_path", type = "character", default = "./data/clean/homeless-shelter-locations.csv",
              help = "Path to save the cleaned data")
)

# Parse Command Line Arguments
opt <- parse_args(OptionParser(option_list = option_list))

get_shelter_from_url <- function(url, save_to){
  
  dir.create(dirname(save_to), showWarnings = FALSE, recursive = TRUE)
  
  message("Downloading data from: ", url)
  download.file(url, save_to, mode = "wb")
  
  cat("✅ Download complete! File saved to:", save_to)
}

process_shelter_data <- function( data_path, save_to){
  if (!file.exists(data_path)) {
    stop("❌ Error: Data file not found at ", data_path)
  }
  
  message("🔄 Processing shelter data...")
  
  df <- read_parquet(data_path)
  
  decode_wkb <- function(wkb) {
    if (!is.null(wkb)) {
      point <- st_as_sf(st_as_sfc(wkb, crs = 4326))  
      return(c(st_coordinates(point))) 
    }
    return(c(NA, NA))  
  }
  
  coords <- t(sapply(df$geo_point_2d, decode_wkb)) 
  df$longitude <- coords[,1]
  df$latitude <- coords[,2]
  
  df <- df |>  filter(!is.na(latitude) & !is.na(longitude))
  
  df <- df |> 
    mutate(category = recode(category, 
                             "Adults (all genders)" = "Adults",
                             "Youth (all genders)" = "Youths",
                             "Men" = "Males"
    ))
  
  df_cleaned <- df |> 
    select(facility, category, phone, meals, pets, carts, geo_local_area, latitude, longitude)
  
  write.csv(df_cleaned, save_to, row.names = FALSE)
  message("✅ Data processing complete! Cleaned data saved to: ", save_to)
}


# execute the function
if (opt$download) {
  get_shelter_from_url(opt$url, opt$raw_path)
}

if (opt$process) {
  process_shelter_data(opt$raw_path, opt$clean_path)
}

message("✅Script execution completed!")