# Load shiny package
library(shiny)

# Run app
source("app.R")
shinyApp(ui, server)

# Publish app
library(rsconnect)
deployApp()
