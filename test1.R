library(mallet)
library(pdftools)
library(rJava)
library(readtext)
library(litdata)
library(dplyr)


sources<-readtext("C:/SDG_classifier/SDGclassy-master/classifier/sources/cl_base_new/*txt")


sdg.instances <- 
  mallet.import(id.array = row.names(sources), 
                text.array = sources[["text"]], 
                stoplist = "C:\\mallet_R\\extra-exclude-words_new.txt",
                token.regexp = "\\p{L}[\\p{L}\\p{P}]+\\p{L}")

topic.model <- MalletLDA(num.topics=18, alpha.sum = 1, beta = 0.1)
topic.model$loadDocuments(sdg.instances)

topic.model$setAlphaOptimization(20, 50)
topic.model$train(2000)

write_mallet_state(topic.model, "temp_mallet_state.gz")
inf<-inferencer(topic.model)

write_inferencer <- function (inf, out_file) {
  fos <- .jnew("java/io/FileOutputStream", out_file)
  oos <- .jnew("java/io/ObjectOutputStream",
               .jcast(fos, "java/io/OutputStream"))
  oos$writeObject(inf)
  oos$close()
}

write_inferencer(inf, "inf.mallet")
write_mallet_instances(sdg.instances, "sdg.instances.mallet")

newtext<-readtext("C:/mallet_R/PDF_tests/*pdf")

com<-compatible_instances(newtext$doc_id, newtext$text, sdg.instances)

moo<-infer_topics(inf,com)

write.table(moo, "output.txt")

output<-read.table("output.txt")

colnames(output)<-c("Life on Land", "Industry and Innovation", "Decent Work",
                    "Zero Hunger", "Responsible Consumption","Sustainable Cities",
                    "Peace and Justice", "Clean Water", "Reduced Inequalities",
                    "Partnerships", "No Poverty","Quality Education","Good Health",
                    "Filter","Life Below Water", "Gender Equality", "Affordable Energy",
                    "Climate Action")

output<-output %>% select("Life on Land", "Industry and Innovation", "Decent Work",
                          "Zero Hunger", "Responsible Consumption","Sustainable Cities",
                          "Peace and Justice", "Clean Water", "Reduced Inequalities",
                          "Partnerships", "No Poverty","Quality Education","Good Health",
                          "Life Below Water", "Gender Equality", "Affordable Energy",
                          "Climate Action")                 

rownames(output)<-c("Poverty.txt", "Marine.txt")

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

g<-ggplot(all, aes(y=Value, x=ID)) + 
  geom_col(stat="identity", fill=all$colour)+
  coord_flip()+
  theme_classic()+
  xlab("Mean SDGs")+
  ylab("Proportion fit")


g
