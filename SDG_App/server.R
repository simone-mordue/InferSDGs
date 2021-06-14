
library(litdata)
library(rJava)
library(readtext)
library(pdftools)
library(mallet)
library(shiny)
library(dplyr)
library(reshape2)
library(debugme)


source("functions.R")
sdg.instances1<-read_mallet_instances("sdg.instances.mallet")
inf <- read_inferencer("inf.mallet")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    observe({
        file1 = input$upload
        
        if (is.null(file1)){
            return(NULL)
        }
        data1 = readtext(file1$datapath)
        output$text <- renderText({
            writeLines(data1[,2])})
            output$distPlot<-renderPlot({
                newtext<-data1
            
            com<-compatible_instances(newtext$doc_id, newtext$text, sdg.instances1)
            topics<-infer_topics(inf, com)
            write.table(topics, "output.txt")
            
            output<-read.table("output.txt")
            
            colnames(output)<-c("Life Below Water","Responsible Consumption","Affordable Energy",
                                "Partnerships","Decent Work","Filter", "Zero Hunger", "Sustainable Cities",
                                "Life on Land","Peace and Justice","Clean Water", "Good Health",
                                "Reduced Inequalities","No Poverty", "Climate Action",
                                "Industry and Innovation","Gender Equality", "Quality Education")
            
            output<-output %>% select("Life on Land", "Industry and Innovation", "Decent Work",
                                      "Zero Hunger", "Responsible Consumption","Sustainable Cities",
                                      "Peace and Justice", "Clean Water", "Reduced Inequalities",
                                      "Partnerships", "No Poverty","Quality Education","Good Health",
                                      "Life Below Water", "Gender Equality", "Affordable Energy",
                                      "Climate Action")                 
            
            rownames(output)<-c(newtext$doc_id)
            
            data <- apply(output, 1, function(output) output/ sum(output, na.rm = TRUE))
            data <- t(data)
            data<-as.data.frame(data)
            
            SDGorder<-c("No Poverty","Zero Hunger", "Good Health","Quality Education", "Gender Equality","Clean Water", "Affordable Energy", "Decent Work", "Industry and Innovation",
                        "Reduced Inequalities","Sustainable Cities", "Responsible Consumption", 
                        "Climate Action", "Life Below Water", "Life on Land","Peace and Justice",
                        "Partnerships")
            
            Finaltable<-data[SDGorder]
            
            # 4.8 read in SDG colour chart
            colours<-read.csv("SDGcolours.csv")
            Mean.table<-colMeans(Finaltable)
            Mean.table<-as.data.frame(Mean.table)
            Mean.table<-t(Mean.table)
            mean<-melt(Mean.table)
            each<-t(Finaltable)
            each<-melt(each)
            colnames(each)<-c("Goal", "ID", "Value")
            colnames(mean)<-c("ID", "Goal", "Value")
            mean$ID<-"Mean"
            
            all<-rbind(each, mean)
            n<-nrow(newtext)
            all$colour<-rep(colours$Colour, n+1)
            
          G<-ggplot(all, aes(y=Value, x=ID)) + 
                geom_col(fill=all$colour)+
                coord_flip()+
                theme_classic()+
                xlab("Mean SDGs")+
                ylab("Proportion fit")
          G})
        })
    })
    


