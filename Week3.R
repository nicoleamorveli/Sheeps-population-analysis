#week3
library(vroom)
#File path
#wad_dat <- vroom("~/Desktop/R-programming/Week3/Data/group_data.csv")
##first we set the working directory (which is the location of the current r script you are working on):
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
#check the folders
##Look two folders up the chain.
vroom("../Data/group_data_sapir.csv")
##List all the files in the folder called Data
##save these file names as an object called "files"
files <- fs::dir_ls(path="../Data/Edited")

##these are the files
files


##then load these file names using vroom
all_group_data <- vroom(files)

#install janitor
install.packages("janitor")
library(readxl)
library(janitor)
library(dplyr)

#Cleaning data
clean_names(all_group_data)
x##install the tidyverse
install.packages("tidyverse")
##load the tidyverse
library("tidyverse")
#what type of data
##what class is the object
class(all_group_data)
##look at the data
all_group_data
#summarize data
install.packages("Hmisc")
library("Hmisc")
describe(all_group_data)
#Any issues? 
#CHINA w capital letters (repeated)
#Sex is wrong spelled F female Fmelae feale M Male male
#Correct sex
all_group_data$sex[all_group_data$sex=="Feale"]<-"Female"
#Correct Sex
all_group_data$sex[all_group_data$sex=="F"]<-"Female"
#Correct Sex
all_group_data$sex[all_group_data$sex=="female"]<-"Female"
all_group_data$sex
#Correct male
all_group_data$sex[all_group_data$sex=="M"]<-"Male"
#Correct male
all_group_data$sex[all_group_data$sex=="male"]<-"Male"
all_group_data$sex
#Correct country
all_group_data$country_of_birth[all_group_data$country_of_birth == "CHINA"]<-"China"
#Describe again
describe(all_group_data)
library(dplyr)
#check for duplicated
duplicated(all_group_data)
#Visualize
## make a ggplot object
ggplot(data = all_group_data, aes(x = age, y = height))
## a scatter plot
ggplot(data = all_group_data, aes(x = age, y = height)) + 
  ## points
  geom_point()
#Filtering
##Uses pipelines
all_group_data%>%
  filter(country_of_birth == "UK")
#Difference in heights in sex?
##make a ggplot
ggplot(all_group_data, aes(x=height, fill=sex))+
  ##add a histogram geom
  geom_histogram(alpha=0.5, position="identity")

#Save plots
##specify the directory and name of the pdf, and the width and height
pdf("~/Desktop/R-programming/Week3/Code/Plots/height_sex_histogram2.pdf", width = 6, height = 4)

##make a ggplot
ggplot(all_group_data, aes(x=height, fill=sex))+
  ##add a histogram geom
  geom_histogram(alpha=0.5, position="identity")

##stop the pdf function and finish the .pdf file
dev.off()
#Summarizing data
##our data
all_group_data %>%
  ##the summarise function
  summarise(mean_height = mean(height))
#group_by
##our data
all_group_data %>%
  ##group by
  group_by(sex) %>%
  ##the summarise function
  summarise(mean_height = mean(height, na.rm=T))
#next challenges

