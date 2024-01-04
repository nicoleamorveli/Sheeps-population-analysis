#Final project R
#Install packages all packages
library(vroom)
library(plyr)
library(dplyr)
library("devtools")
library(tidyr)
library(fitdistrplus)
library(rstatix)
library(performance)
library(ggplot2)
library(Hmisc)

#Open data

mass_files <- fs::dir_ls(path="/Users/nicolemorveli/Desktop/R-programming/final_project/data/mass")
mass_files
mass_data <- vroom(mass_files, id="/Users/nicolemorveli/Desktop/R-programming/final_project/data/mass")
head(mass_data)

#read for NAO data
nao_files <- fs::dir_ls(path="/Users/nicolemorveli/Desktop/R-programming/final_project/data/NAO")
nao_files
nao_data <- vroom(nao_files, id="/Users/nicolemorveli/Desktop/R-programming/final_project/data/NAO")
head(nao_data)

#clean data

describe(nao_data)

mean_nao = 
  nao_data %>%
  dplyr::group_by(year) %>%
  dplyr::summarise(mean_nao_per_year = mean(NAO))

describe(mean_nao)

#Clean mass data

describe(mass_data)

#data is unstructured = mixed efffects

#get rid off 1 and 0 sex columns

filtered_data <- mass_data %>%
  dplyr::filter(sex == "f" | sex == "m")
describe(filtered_data)

#get rid of missing values in weight
mass_data_cleaned <-
  filtered_data %>%
  drop_na(weight)
describe(mass_data_cleaned)

#Merge with NAO data

combined_data <- mass_data_cleaned %>%
  left_join(mean_nao, by = "year")
combined_data

#Now the data is cleaned and ready to analyze
#first we can plot it
#We are going to do a linear rergession considering mixed effects

#Plot the data
#Scatter plot NAO (x) vs weight (y)

#For better visualization do mean weight per year
#and include a column w the numbers of individuals that were recorded
summary_data <- combined_data %>%
  group_by(year, mean_nao_per_year) %>%
  summarise(mean_weight = mean(weight), count_IDs = n_distinct(ID))

summary_data 
describe(summary_data)
#Add range for IDs
summary_data <- summary_data %>%
  mutate(range_IDs = case_when(
    count_IDs < 25 ~ "<25",
    between(count_IDs, 26, 50) ~ "25-50",
    between(count_IDs, 51, 75) ~ "50-75",
    count_IDs > 75 ~ ">75"
  ))

#Add range for years
summary_data <- summary_data %>%
  mutate(range_years = case_when(
    between(year, 1980, 1990) ~ "1980-1990",
    between(year, 1990, 2000) ~ "1990-2000",
    between(year, 2000, 2010) ~ "2000-2010",
    between(year, 2010, 2020) ~ "2010-2020",
  ))
summary_data


library(RColorBrewer)
library(ggplot2)
library(viridis)


# Assuming summary_data contains the necessary columns: mean_nao_per_year, mean_weight, count_IDs, year


# Use ggplot2 to create the plot
ggplot(summary_data, aes(x = mean_nao_per_year, y = mean_weight, shape = range_IDs, color = range_years)) +
  geom_point(alpha = 0.5, size = 9) +
  scale_shape_manual(values = c(15,16,17,18)) +  # Different shapes for each range
  scale_color_viridis_d() +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +  # Add a trend line
  labs(title = "Change of sheep's weight vs change of NAO over the years",
       x = "Mean NAO (North Atlantic Oscillation) per year",
       y = "Mean Weight of sheeps recorded per year",
       shape = "Numbers of individuals recorded") +
  labs(color = "Years") # Modify the title for shapes
  theme_minimal()

#CONCLUSIONS
#nao INCREASES OVER THE YEAR
#weight also increases 
#mixed effects caused by individual 

#Error distribution 
library(fitdistrplus)
install.packages("goftest")
library(goftest)
  
#use combined data
##fit a gaussian first
fit_gaus <- fitdist(combined_data$weight,
                        dist = 'norm')
##plot it out:
plot(fit_gaus)

#Statistical test
#here a p value >0.05 means there is no diffrence within the data and the model we are fitting
gofstat(fit_gaus)

#These statistics are commonly used to assess how 
#well the fitted distribution matches the observed data
# for KS
#warming that monte carlo approach was used as there is some repetitive data
#it may be that some sheeps weight the same for some years 
ks_result <- ks.test(combined_data$weight, "pnorm", mean = fit_gaus$estimate[1], sd = fit_gaus$estimate[2], exact = FALSE)
print(ks_result)
#result:  p-value = 5.596e-14
# for CM
cvm_result <- goftest::cvm.test(combined_data$weight, "pnorm", mean = fit_gaus$estimate[1], sd = fit_gaus$estimate[2])
print(cvm_result)
#result p-value < 2.2e-16

#So the p-value is less than 0.05 means we have to look for a other distribution 

#We will try my log function as the data is continous 
fit_log <- fitdist(combined_data$weight,
                    dist = 'lnorm')
##plot it out:
plot(fit_log)

#statistics
gofstat(fit_log)

#p-values
ks_result <- ks.test(combined_data$weight, "plnorm", meanlog = fit_log$estimate[1], sdlog = fit_log$estimate[2], exact=FALSE)
print(ks_result)
#p value 0.0004992
# Cramer-von Mises (CM) test
cm_result <- goftest::cvm.test(combined_data$weight, "plnorm", meanlog = fit_log$estimate[1], sdlog = fit_log$estimate[2])
print(cm_result)
#p value0.0005705
# Anderson-Darling (AD) test
ad_result <- goftest::ad.test(combined_data$weight, "plnorm", meanlog = fit_log$estimate[1], sdlog = fit_log$estimate[2])
print(ad_result)
#p-value 8.88e-05

#Does not seem that log function fits 

#Try with Gamma distribution 
#Why gamma? it seems to have a positive skewed
#Histogram of weights 
p =hist(combined_data$weight, main = "Histogram of Weight", xlab = "Weight")
#statistics mean> mediam?
summary(combined_data$weight)

#plot gamma distribution 
fit_gamma <- fitdist(combined_data$weight,
                      dist = 'gamma')
##plot it out:
plot(fit_gamma)
gofstat(fit_gamma)
combined_data$weight
#p -values
# Kolmogorov-Smirnov (KS) test
ks_result <- ks.test(combined_data$weight, "pgamma", shape = fit_gamma$estimate[1], rate = fit_gamma$estimate[2])
print(ks_result)

# Cramer-von Mises (CM) test
cm_result <- goftest::cvm.test(combined_data$weight, "pgamma", shape = fit_gamma$estimate[1], rate = fit_gamma$estimate[2])
print(cm_result)





#CHOOSING A MODEL

#Indeed, one of the most intuitive applications of nonlinear mixed-effects models 
#is to describe temporal within-individual responses and to identify factors determining variability among 
#individual responses. So in this case weight is the temporal individual reponse where
#NAO, sex?, pop size explains variability among individual responses




