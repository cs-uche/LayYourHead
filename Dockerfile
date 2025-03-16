# Use the official R Shiny image
FROM rocker/shiny:latest

# Install system dependencies (adjust as needed)
RUN apt-get update && apt-get install -y \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev 

# Ensure the R packages are installed (adjust as needed)
RUN R -e "install.packages(c('fresh', 'shinydashboard', 'leaflet', 'ggplot2', 'dplyr', 'sf'))"

# Set working directory to 'src' where your app.R is located
WORKDIR /home/shiny-app/src

COPY /src /home/shiny-app/src  
COPY /data/clean /home/shiny-app/data/clean

RUN chmod -R 755 /home/shiny-app/src

# Explicitly run your Shiny
CMD ["R", "-e", "shiny::runApp('/home/shiny-app/src', port = 3838, host = '0.0.0.0')"]