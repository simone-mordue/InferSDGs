#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(litdata)
library(readtext)
library(pdftools)
library(mallet)
library(shiny)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    observe({
        file1 = input$upload
        
        if (is.null(file1)){
            return(NULL)
        }
        data1 = readtext(file1$datapath)
        output$text <- renderText({
            writeLines(data1[,2])
        })
    })
    
})


