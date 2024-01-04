rm(list=ls())
#Take the data
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
#install.packages("Hmisc")
library("Hmisc")
library(tidyr)
#Tyding data
library("Hmisc")
#install.packages("fitdistrplus")
library(fitdistrplus)
library(rstatix)
library(performance)
library(ggplot2)
describe(all_data)

#Hypothesis
#A random effect could be the group name (and/or thrower)
#considering 
#round(na_drop_data$Distance, digits = 2)
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

IBT =
  na_drop_data %>%
  dplyr::rename(Group_name = `Group Name`) %>%
  ##group by
  dplyr::group_by(Group_name, Thrower, Bucket, Distance) %>%
  dplyr::distinct(Group_name, Thrower, Bucket, Distance, Species,Success) %>%
  ##the summarise function
  dplyr::summarise(count_unique_species = sum(Success))
#This is the data we are going to use
IBT
#And the model 
#count_unique_species ~ Distance + Bucket + Distance:Bucket
#group_name as a random effect
#for this we are going to use glmmTMB package
install.packages("glmmTMB")
library(glmmTMB)
#we are going to use random interceps 
#you specify random intercept effects using + (1 | group)

#Choose distribution ?
#fitdist()
library(fitdistrplus)
fit_pois <- fitdist(IBT$count_unique_species,
                      dist = 'pois')
plot(fit_pois)
#try basic statistics
gofstat(fit_pois)

#seems not a good fir tuse negative binomial
fit_binom <- fitdist(IBT$count_unique_species,
                    dist = 'nbinom')
plot(fit_binom)
#try statistics
gofstat(fit_binom)
#use negative binomial 
##fit a random effects model
m_mod <- glmmTMB(count_unique_species ~
                    Bucket +
                    Distance +
                    Bucket:Distance +
                    (1|Group_name),
                  data=IBT,
                  family="nbinom1")

##look at the model summary:
summary(m_mod)
#how much variance is given by the random effect (very small)
#we can look at both variance for fixed and overall
#canculate using r.squaredGLMM 
install.packages("MuMIn")
library(MuMIn)
#calculate variance again using r.squaredGLMM
r.squaredGLMM(m_mod)
#R2m is variabce explained by fixed effects
#R2c is variance by the entire model (both )
#MODEL FITS
#So we are going to use a new package DHARMa which can help us assess the model fit more robustly. 
#This works by using the model fit to simulate residuals which incorporate the uncertainty in the model, 
#see ?simulateResiduals for a good explanation.
install.packages("DHARMa")
library("DHARMa")
## simulate the residuals from the model
##setting the number of sims to 1000 (more better, according to the DHARMa help file)
m_mod2_sim <- simulateResiduals(m_mod, n = 1000)

##plot out the residuals so is a qqplot if we have a pvalue<0.05 then our data 
#is different from the model
#the other plot we want line close to horizontal 
plot(m_mod2_sim)
#Which seems to suggest our data is overdispersed. Overdispersion is often the result
#of missing predictors or a misspecified model structure, so we will come back to this below.
testDispersion(m_mod)
#is not doing a bad job

#NESTED EFFECTS?
#GROUP OR INDIVIDUAL?
#we consider the thrower effect so we need to reshape
#we add thrower to the code
##fit a random effects model
#to add nested effect we only add the /thrower
m_mod2 <- glmmTMB(count_unique_species ~ scale(Distance) +
                    scale(Bucket) +
                    scale(Distance):scale(Bucket) +
                   (1|Group_name/Thrower),
                 data=IBT,
                 family="nbinom1")

                 
summary(m_mod2)

#Sometimes you have to specifiy the optmizatin you are doing
#try to scale to make them comparable thats the scale thing

#now lets check again
m_mod2_sim <- simulateResiduals(m_mod2, n = 1000)
plot(m_mod2_sim)
#Cross random effecys
#where two or more variables can create distinct groupings.
#we ca test outliers
## test to see where there are outliers, in our case not significant so we dont need to worry
testOutliers(m_mod2,
             plot = TRUE)
testZeroInflation(m_mod2,
                  plot = TRUE)
#for temporal data 
## see if there is temporal autocorrelation in the residuals
#testTemporalAutocorrelation(my_model,
                            #time = ?,
                            #plot = TRUE)
#final checks
## add in the predicted values from the model:
IBT$predicted <- predict(m_mod2,
                                data = IBT,
                                type = "response")
##plot the predicted against the observed
ggplot(IBT, aes(x = count_unique_species,
                       y = predicted)) +
  geom_point(col="grey") +
  geom_abline(slope = 1) +
  theme_minimal() +
  xlab("Observed") +
  ylab("Predicted")

#interpreting our model
#Install broom.mixed and dotwhisker#
install.packages("broom.mixed")
install.packages("dotwhisker")
library(broom.mixed)
library(dotwhisker)
## reshape the outputs of the model into a tidy format:
tidied_model_data <- broom.mixed::tidy(m_mod2, conf.int = TRUE) %>% 
  ##clean up the random effect names
  mutate(term=ifelse(grepl("sd__(Int",term,
                           fixed=TRUE),
                     paste(group,term,sep="."),
                     term))
##plot it
ggplot(tidied_model_data, aes(x=estimate, y=term)) + 
  geom_point() + 
  geom_errorbar(aes(xmin=conf.low, xmax=conf.high),                       
                width=0.3, 
                col="grey50") +
  theme_bw()
