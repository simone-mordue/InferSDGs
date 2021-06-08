#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("SDG Classifier"),


        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot"),
            fileInput(inputId = "upload",
                      label = "Choose pdf files",
                      accept = ".pdf",
                      multiple = TRUE),
            tableOutput("files"),
            textOutput("text")
        )
    )
)
