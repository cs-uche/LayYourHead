library(fresh)
library(sf)      
library(shiny)
library(shinydashboard)

source('./process_data.R')      # Loads filter_df()
source('./get_output_charts.R') # Loads create_map() and get_pie_chart()


options(shiny.port = 8050, shiny.autoreload = TRUE)

bc_theme <- create_theme(
  adminlte_color(
    light_blue = "#003366"
  )
)

df <- read.csv("../data/clean/homeless-shelter-locations.csv")  

ui <- dashboardPage(
  
  dashboardHeader(title = "Vancouver Shelters"),  
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Filters", tabName = "filters", icon = icon("filter")),
      
      selectizeInput(
        inputId = "select_local_area",
        label = "Select the Local Area",
        choices = NULL, 
        multiple = TRUE
      ),
      
      checkboxInput("meals_provided", "Are Meals Provided?", value = TRUE),
      checkboxInput("pets_welcome", "Are Pets Welcome?", value = TRUE),
      checkboxInput("carts_allowed", "Are Carts Allowed?", value = TRUE)
    )
  ),
  
  dashboardBody(
    use_theme(bc_theme),
    
    fluidRow(
      # Map (Center, Larger)
      box(
        title = "Homeless Facility Locations",
        status = "primary",
        solidHeader = TRUE,
        width = 8,  # Large map area
        height = 'auto',
        leafletOutput("map_plot", height = "500px")
      ),
      
      # Pie Chart (Right, Smaller)
      box(
        title = "Distribution of Facility Categories",
        status = "primary",
        solidHeader = TRUE,
        width = 4,  # Smaller pie chart
        height = 'auto',
        plotOutput("pie_chart", height = "350px")  # Adjust height
      )
    ),
    
    # Sticky Footer
    tags$footer(
      style = "
        position: fixed;
        bottom: 0;
        left: 0;
        width: 100%;
        text-align: center;
        padding: 5px;
        background-color: #003366;
        color: white;
        font-size: 12px;
      ",
      tags$p(
        "This dashboard was designed to support non-profit organizations in assisting displaced individuals across Vancouver."
      ),
      tags$p(
        "Data sourced from ",
        tags$a(href = "https://opendata.vancouver.ca/explore/dataset/homeless-shelter-locations/", 
               "City of Vancouver Open Data Portal", target = "_blank", style = "color: white; text-decoration: underline;"),
        " | Developed by Sopuruchi Chisom ",
        tags$a(href = "https://github.com/cs-uche", "(cs-uche)", target = "_blank", style = "color: white; text-decoration: underline;")
      ),
      
      tags$p(
        "© ", format(Sys.Date(), "%Y"), " Sopuruchi Chisom. All rights reserved.",
        style = "margin-top: 5px; font-size: 10px;"
      )
    )
  )
)


server <- function(input, output, session) {
  # Populate selectInput choices dynamically
  observe({
    updateSelectInput(session, "select_local_area", choices = unique(df$geo_local_area))
  })
  
  # Reactive filtered data
  filtered_data <- reactive({
    filter_df(df, input$select_local_area, input$meals_provided, 
              input$pets_welcome, input$carts_allowed)

  }) 
  
  # Render Map
  output$map_plot <- renderLeaflet({
    create_map(filtered_data())
  })
  
  # Render Pie Chart
  output$pie_chart <- renderPlot({
    get_pie_chart(filtered_data())
  })
}


shinyApp(ui, server)