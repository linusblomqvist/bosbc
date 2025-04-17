library(shiny)
source("read_accounts_file.R")

# Define UI
ui <- fluidPage(
  tags$head(includeHTML("google-analytics.Rhtml")),
  titlePanel("Birds of Santa Barbara County"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Select a species:"),
      selectizeInput(
        "species", 
        label = NULL,
        choices = c("", bosbc_accounts$species),  # Add an empty value for the placeholder
        selected = NULL,
        options = list(placeholder = "Start typing a species name...")
      ),
      hr(),  # Add a horizontal divider
      
      # Title for additional resources
      uiOutput("resources_title"),
      
      # Dynamically generated hyperlinks
      uiOutput("birdview_link"),  # Link to BirdView
      uiOutput("ebird_link"),     # Link to eBird
      uiOutput("cbc_link"),       # Link to Santa Barbara CBC
      uiOutput("bbs_link"),       # Link to Santa Barbara Breeding Bird Study
      
      # Shareable link
      uiOutput("shareable_link")
    ),
    
    mainPanel(
      h2(textOutput("header")),  # Header for the species name
      uiOutput("description")    # Dynamic description
    )
  ),
  
  # Footer Section
  tags$footer(
    style = "position: relative; margin-top: 20px; width: 100%; background-color: #f8f9fa; padding: 10px; text-align: center; font-size: 12px; color: #6c757d;",
    "Birds of Santa Barbara County is written by Paul Lehman. For more information, click ",
    tags$a(
      href = "http://sbcobirding.com/lehmanbosbc.html",
      target = "_blank",
      "here."
    )
  )
)

server <- function(input, output, session) {
  # Parse the query string and set the default selection
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query$species)) {
      updateSelectizeInput(session, "species", selected = query$species)
    }
  })
  
  # Header for species name
  output$header <- renderText({
    req(input$species)
    input$species
  })
  
  # Description for the species
  species_description <- reactive({
    req(input$species)
    species_row <- subset(bosbc_accounts, species == input$species)
    if (nrow(species_row) > 0) {
      species_row$account
    } else {
      "<p style='color: red;'>Species not found. Please try again.</p>"
    }
  })
  
  output$description <- renderUI({
    HTML(species_description())
  })
  
  # Title for additional resources
  output$resources_title <- renderUI({
    req(input$species)
    tags$h4(paste("Additional resources for", input$species))
  })
  
  # Render BirdView hyperlink
  output$birdview_link <- renderUI({
    req(input$species)
    species_row <- subset(bosbc_accounts, species == input$species)
    if (nrow(species_row) > 0 && !is.na(species_row$species_url)) {
      tags$p(
        tags$a(
          href = species_row$species_url,
          target = "_blank",
          rel = "noopener noreferrer",
          "BirdView"
        )
      )
    }
  })
  
  # Render eBird hyperlink
  output$ebird_link <- renderUI({
    req(input$species)
    species_row <- subset(bosbc_accounts, species == input$species)
    if (nrow(species_row) > 0 && !is.na(species_row$ebird_url)) {
      tags$p(
        tags$a(
          href = species_row$ebird_url,
          target = "_blank",
          rel = "noopener noreferrer",
          "eBird"
        )
      )
    }
  })
  
  # Render Santa Barbara CBC hyperlink
  output$cbc_link <- renderUI({
    req(input$species)
    species_row <- subset(bosbc_accounts, species == input$species)
    if (nrow(species_row) > 0 && !is.na(species_row$cbc_url)) {
      tags$p(
        tags$a(
          href = species_row$cbc_url,
          target = "_blank",
          rel = "noopener noreferrer",
          "Santa Barbara CBC"
        )
      )
    }
  })
  
  # Render Santa Barbara Breeding Bird Study hyperlink
  output$bbs_link <- renderUI({
    req(input$species)
    species_row <- subset(bosbc_accounts, species == input$species)
    if (nrow(species_row) > 0 && !is.na(species_row$bbs_url)) {
      tags$p(
        tags$a(
          href = species_row$bbs_url,
          target = "_blank",
          rel = "noopener noreferrer",
          "Santa Barbara Breeding Bird Study"
        )
      )
    }
  })
  
  # Render Shareable Link
  output$shareable_link <- renderUI({
    req(input$species)
    species_name <- input$species
    shareable_url <- paste0("https://linusblomqvist.shinyapps.io/bosbc/?species=", URLencode(species_name))
    
    tags$p(
      tags$a(
        href = shareable_url,
        target = "_blank",
        rel = "noopener noreferrer",
        "Shareable link to this account"
      )
    )
  })
}

# Run the app
shinyApp(ui, server)
