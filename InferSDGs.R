#remotes::install_github("agoldst/litdata",
#                         INSTALL_opts=c("--no-multiarch"))
library(mallet)
library(pdftools)
library(rJava)
library(readtext)
library(litdata)
library(dplyr)
library(reshape2)
library(ggplot2)

### source functions
source("functions.R")

### read in text
newtext<-readtext("./PDF_tests/*txt")

### load instance list from topic model
sdg.instances1<-read_mallet_instances("sdg.instances.mallet")
inf <- read_inferencer("inf.mallet")

### find matching instances (words) from new text and topic model
com<-compatible_instances(newtext$doc_id, newtext$text, sdg.instances1)

### infer topics of new text
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
all$colour<-rep(colours$Colour, 3)

ggplot(all, aes(y=Value, x=ID)) + 
  geom_col(fill=all$colour)+
  coord_flip()+
  theme_classic()+
  xlab("Mean SDGs")+
  ylab("Proportion fit")

write.csv(all, "./SDG.csv")
