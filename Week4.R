#Install packages
library("vroom")
library("devtools")
library("tidyverse")
library("Hmisc")
library("dplyr")
library("ggplot2")

#Input data
files <- fs::dir_ls(path="/Users/nicolemorveli/Desktop/R-programming/Week3/Data/Edited")
files
all_group_data <- vroom(files, id="/Users/nicolemorveli/Desktop/R-programming/Week3/Data/Edited")

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
all_group_data
##make our ggplot object
ggplot(all_group_data, aes(x = height)) +
  ##tell it we want ao histogram, and to colour the histogram by the different groups
  geom_histogram(aes(fill=sex)) +
  ##make it on two different facets
  facet_wrap(~ sex) +
  ##set the theme to a simple background
  theme_bw() +
  ##tidy up by surpressing the legend
  theme(legend.position = "none")
#ggpubr package
install.packages("ggpubr")
library(ggpubr)
##make the qqplot, we need to specify where the x values are
##and also that we have groups (which will be plotted in different colors)
ggqqplot(all_group_data, x="height", color="sex")

install.packages("rstatix")
library(rstatix)
library(palmerpenguins)
##load the data set
data(penguins)
##carry out an independant t-test
##specify our data
our_test <- all_group_data %>%
  ##specify the t test and the formula for it (value as a function of group, value~group)
  ##also tell it to return a more detailed output 
  t_test(height~sex, detailed=T) %>%
  ##return the significances too
  add_significance()
##look at the results
our_test
#there is a difference between the two groups
##fit a glm()
#tye gaussian specification is that we are assuming our error acts normally
mod_flipper <- glm(flipper_length_mm ~ species,
                   ##specify the data
                   data = penguins,
                   ##specify the error structure
                   family = "gaussian")

#this if for checking if our model fits the data well
install.packages("performance")
library("performance")
check_model(mod_flipper)
#now lets check the model
summary(mod_flipper)
#they take adelie as the normal (alphabtical order) and then do the other differences so you have the add the mean 
#intercept to the estimate values. in the last column we can see that the values are signficant
#we can not say chinstrap is different from gentoo yet
#read about multiple comparisons test
## load the multcomp pack

