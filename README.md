Exploring Factors That Shape Soay Sheep's Weight
Project Overview
This project explores how climatic and biological factors influence the weight of Soay sheep, with a focus on the North Atlantic Oscillation (NAO). The study aims to identify the impact of both internal (sex, age) and external (climatic) factors on weight changes over time. Generalized linear and mixed models were used to examine these relationships.

Key Objectives:
Understand the effect of NAO on sheep weight.
Investigate how sex, age, and past weight influence sheep weight.
Build a robust predictive model for sheep weight using longitudinal data.
Data Sources
nao_data: Monthly NAO index values (1980–2020), focusing on summer months (June–August).
mass_data_cleaned: Soay sheep records, including ID, age, sex, site of observation, and weight for each year.
Project Workflow
1. Data Preparation
Data was cleaned and filtered to focus on sheep with consistent longitudinal records.

NAO Data: Mean NAO values were calculated for each summer (June–August).

mean_nao <- nao_data %>%
  dplyr::filter(month %in% c("June", "July", "August")) %>%
  dplyr::group_by(year) %>%
  dplyr::summarise(mean_nao_per_year = mean(NAO))

Sheep Data: Records with missing weights and invalid sex data were removed. The data was further filtered to include only sheep with more than 5 consecutive yearly records.
cumulative_combined_data <- combined_data %>%
  filter(ID %in% count_appearances$ID)

2. Visual Data Exploration
Weight data was visualized against NAO, year, and population size to observe general trends. Additionally, a histogram of weight was plotted to assess the response variable's distribution.

3. Error Structures and Goodness-of-Fit
The following tests and statistics were calculated to assess the normality of the weight data:

Normal Distribution Fit:
Kolmogorov-Smirnov: 0.054
Akaike's Information Criterion (AIC): 4142.104
P-values for tests: K-S (0e+00), Anderson-Darling (6e-07)
Log-Normal Distribution Fit:
Kolmogorov-Smirnov: 0.0336
AIC: 4082.703
P-values: K-S (0.208), Anderson-Darling (0.156)
Results indicated that a log-normal distribution fit the data better than a normal distribution.

Modeling Process
1. Generalized Linear Models (GLM)
Initial GLMs were fitted to explore the effect of internal factors (age, sex) on weight.

Model 1: GLM with sex and age

model_1 <- glm(weight ~ age + sex, data = cumulative_combined_data, family = gaussian(link = "log"))

model_2 <- glm(weight ~ age * sex, data = cumulative_combined_data, family = gaussian(link = "log"))

The models indicated that sex and age had significant effects, but could not explain the entire variation due to the longitudinal nature of the data.

2. Mixed Effects Models (GLMM)
Given the longitudinal structure, mixed-effects models were applied to account for individual sheep's repeated measurements over time.

Model 3: Mixed effect with sex, age, and random effect (ID)

model_3 <- glmmTMB(weight ~ age + sex + (1 | ID), data = cumulative_combined_data, family = lognormal(link = "log"))

model_4 <- glmmTMB(weight ~ mean_nao_per_year + age + sex + (1 | ID), data = cumulative_combined_data, family = lognormal(link = "log"))

model_5 <- glmmTMB(weight ~ mean_nao_per_year + age + sex + (1 | ID) + (1 | year), data = cumulative_combined_data, family = lognormal(link = "log"))

model_6 <- glmmTMB(weight ~ mean_nao_per_year + age + sex + lag_weight + (1 | ID) + (1 | year), data = cumulative_combined_data, family = lognormal(link = "log"))

 Results
Goodness-of-Fit for Models
AIC Comparison:
Model 4: 1257.96
Model 5: 1178.25
Model 6: 971.99 (Best fit)
Key Findings from Model 6:
NAO: Significant positive effect on weight.
Sex: Males generally heavier than females.
Age: Weight decreases with age.
Lag Weight: Previous year’s weight is a strong predictor of current weight.
Age-Sex Interaction: A small but significant interaction, suggesting different aging patterns by sex.
Model Diagnostics:
Residual Analysis: No significant autocorrelation detected.
Outlier Test: Outliers were within expected limits.
Conclusion
Model 6 effectively captures the influence of both internal factors (sex, age, lag weight) and external factors (NAO) on Soay sheep weight. The findings suggest that climatic conditions (represented by NAO) and biological factors like sex and age play a significant role in shaping weight patterns over time. Further exploration is needed to examine the interaction between age and sex, as well as temporal autocorrelations.

Repository Contents
data/: Contains cleaned datasets (mean_nao, mass_data_cleaned).
scripts/: R scripts for data processing, visualization, and modeling.
figures/: Visualizations and residual plots from models.
results/: Output summaries of GLM and GLMM models

How to Run the Project
Install necessary R packages:

install.packages(c("dplyr", "ggplot2", "glmmTMB", "DHARMa"))

Run data_preparation.R for data cleaning and preparation.
Execute modeling.R to run GLMs and GLMMs.

