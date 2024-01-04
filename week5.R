library(vroom)
#install.packages("plyr")
library(plyr)
#read for data 
files <- fs::dir_ls(path="/Users/nicolemorveli/Desktop/R-programming/Week5/Original_data")
files

all_data <- vroom(files, id="/Users/nicolemorveli/Desktop/R-programming/Week5/Original_data")
head(all_data)

#install packages
library(dplyr)
library("devtools")
install.packages("Hmisc")
library("Hmisc")
library(tidyr)
#Tyding data
library("Hmisc")

describe(all_data)

#get rid of na data
#color Orange is wrong
all_data$Species[all_data$Species=="Orange"]<-"orange"
#replace ligntblue with lightblue
all_data$Species[all_data$Species=="lighblue"]<-"lightblue"
#replace lighblue with lightblue
all_data$Species[all_data$Species=="ligntblue"]<-"lightblue"
#darkpblue with darkblue
all_data$Species[all_data$Species=="darkpblue"]<-"darkblue"
#blue with darkblue
all_data$Species[all_data$Species=="blue"]<-"darkblue"
#darnk green to green
all_data$Species[all_data$Species=="darkgreen"]<-"green"
#light pink to pink 
all_data$Species[all_data$Species=="lightpink"]<-"pink"
#describe again 
describe(all_data)

#get rud if NA data
na_drop_data <-
  ##take our original data set
  all_data %>%
  ##filter out any values equal to NA in our sex column
  drop_na(`Group Name`, Thrower, Attempt, Species, Bucket, Distance)
 head(na_drop_data)
#describe again
describe(na_drop_data)

#Round data to 2 decimals

round(na_drop_data$Distance, digits = 2)

na_drop_data
#Reshape data: I want unique species for each island 
#create other data frame
# filter and them combine


#now count how many unique species there are in each island. Create a new dataframe
#This is done because you want to divide per group 
#and consider the attemps as real data
#in grouping it matters the order
#SO first you have to consider the group division and then the island
#and then you like divide per unique count being the last one sucess 
#Finally you sum the sucess so it will be the unique species that migrated to the island
IBT =
na_drop_data %>%
  dplyr::rename(Group_name = `Group Name`) %>%
  ##group by
  dplyr::group_by(Group_name, Bucket, Distance) %>%
  dplyr::distinct(Group_name, Bucket, Distance, Species,Success) %>%
  ##the summarise function
  dplyr::summarise(count_unique_species = sum(Success))
#This is the data we are going to use
IBT

#First plot the data
#Histogram because is count data
library(ggplot2)
library(hrbrthemes)
#convert data into a factor
IBT$Bucket <- as.factor(IBT$Bucket)
IBT$Distance  <- as.numeric(IBT$Distance)
##make a ggplot
#plot(IBT, x= IBT$Distance, y=IBT$count_unique_species)
#boxplot + scatterplot (better)
#then facegrid for bucket 

p=ggplot(IBT, aes(x=Distance, y= count_unique_species, color=Bucket))+ 
  geom_point(size=3) +
  theme_ipsum()
p
  #scale_x_continuous(breaks =seq(0,5, by=1))




#ggplot(IBT, aes(x = Distance, y = count_unique_species, fill = Bucket)) +
 # geom_bar(stat = "identity") +
 # labs(title = "Count of Unique Species by Distance",
  #     x = "Distance",
 #      y = "Count of Unique Species") +
  #facet_grid(. ~ Bucket) +
 # theme_minimal() +
  #theme(axis.text.x = element_text(angle = 45, hjust = 1),
   #     plot.title = element_text(hjust = 0.5, size = 10),  # Adjust title size
    #    legend.text = element_text(size = 5),  # Adjust legend text size
     #   legend.title = element_text(size = 6))  # Adjust legend title size

#Before deciding we can check which distributions may fit the model
install.packages("fitdistrplus")
library(fitdistrplus)
plotdist(IBT$count_unique_species, histo = TRUE, demp = TRUE)
#Check the kurtosis and skewness
descdist(IBT$count_unique_species, boot = 1000)
#fit a distribution
fp <- fitdist(IBT$count_unique_species, "pois")
fg <- fitdist(IBT$count_unique_species, "nbinom")

#plot
plot.legend <- c("poisson", "binomial")
denscomp(list(fp, fg), legendtext = plot.legend)
qqcomp(list(fp, fg), legendtext = plot.legend)
cdfcomp(list(fp, fg), legendtext = plot.legend)
ppcomp(list(fp, fg), legendtext = plot.legend)

#fIT A MODEL INTO MY DATA
#H1=Size and Distance have an effect on the number of species present in the island
#H2=Size has an effect on the number of species present in the island
#H3=Distance has an effect on the number of species present in the island
#x= distance, bucket y=count_species_unique
#y(species)= a + bo(distance) + b1(size) + b2(distance*size)
#We are going to use poisson 
hist(IBT$count_unique_species)
#Model 
install.packages("rstatix")
library(rstatix)
mod_species <- glm(count_unique_species ~ Distance + Bucket + Distance:Bucket, 
              data=IBT, 
              family = poisson(link = "log"))
mod_species
#Asses the model fit
#plot the observed vs the predicted
##visualize the fitted vs observed values
install.packages("performance")
library(performance)
library(ggplot2)
fit_data <- data.frame("predicted"= mod_species$fitted.values,
                       "observed" = IBT$count_unique_species)

mod_species$fitted.values
##plot them
ggplot(fit_data, aes(x=observed, y=predicted)) + 
  geom_point() + 
  ##add a 1:1 line
  geom_abline(intercept = 0) +
  ##add a linear regression to your data
  geom_smooth(method="lm",
              col="lightblue",
              se = F) +
  ##set the theme
  theme_classic()

#check model 
summary(mod_species)
#cehck x2 and then ftrom there calculate the pvalue
x2= 4.1198e+01 - 2.2204e-15
x2
#pvalues is <0.05
#negative binomial is the pther option
#run again w binomial but first transformed data (proportion) respect to what? each specie?
#tools to visualize model
install.packages("interactions")
install.packages("jtools")
library(jtools)
library(interactions)

summ(mod_species)

