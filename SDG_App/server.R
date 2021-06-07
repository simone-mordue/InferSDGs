#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(mallet)
library(shiny)
source("Infer.R")
data<-all

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    

    output$distPlot <- renderPlot({
        ggplot(data, aes(y=Value, x=ID)) + 
            geom_col(fill=data$colour)+
            theme_classic()+
            xlab("Mean SDGs")+
            ylab("Proportion fit")

    })
    output$files <- renderTable(input$upload)
    

})

