# Exploring Factors That Shape Soay Sheep's Weight

## Project Overview

This project explores how climatic (North Atlantic Oscillation, NAO) and biological factors (age, sex) influence the weight of Soay sheep over time. Generalized linear models (GLM) and mixed models (GLMM) are used to investigate these relationships and build predictive models for sheep weight.

## Key Objectives

- Understand the effect of **NAO** on sheep weight.
- Investigate how **sex**, **age**, and **past weight** impact sheep weight.
- Build a robust predictive model for sheep weight using longitudinal data.

## Data Sources

- **nao_data**: Monthly NAO index values from 1980–2020 (focus: June–August).
- **mass_data_cleaned**: Soay sheep records, including ID, age, sex, site, and weight.

## Project Workflow

### 1. Data Preparation

Data was cleaned, focusing on sheep with consistent longitudinal records. Mean NAO values for each summer (June–August) were calculated.

```
mean_nao <- nao_data %>%
  dplyr::filter(month %in% c("June", "July", "August")) %>%
  dplyr::group_by(year) %>%
  dplyr::summarise(mean_nao_per_year = mean(NAO))
```

Sheep records with missing weights and invalid sex data were removed, and the data was filtered to include sheep with more than 5 consecutive yearly records.

```
cumulative_combined_data <- combined_data %>%
  filter(ID %in% count_appearances$ID)
```

2. Visual Data Exploration
Weight trends were visualized against NAO, year, and population size. Additionally, a histogram of weight was plotted to assess the response variable's distribution.

3. Error Structures and Goodness-of-Fit
The fit was compared between normal and log-normal distributions. A log-normal distribution fit better based on lower AIC scores:

Normal Distribution: Kolmogorov-Smirnov (K-S): 0.054, AIC: 4142.104
Log-Normal Distribution: K-S: 0.0336, AIC: 4082.703
4. Modeling Process
GLM Models:
Model 1: Investigated effects of age and sex on sheep weight.

```
model_1 <- glm(weight ~ age + sex, data = cumulative_combined_data, family = gaussian(link = "log"))
```
Model 2: Explored the interaction between age and sex.

```
model_2 <- glm(weight ~ age * sex, data = cumulative_combined_data, family = gaussian(link = "log"))
```

## GLMM Models:
Model 3: Added random effects for individual sheep (ID).

```
model_3 <- glmmTMB(weight ~ age + sex + (1 | ID), data = cumulative_combined_data, family = lognormal(link = "log"))

```
Model 6: Best model, incorporating NAO, lag weight, age, and sex, with random effects for ID and year.

```
model_6 <- glmmTMB(weight ~ mean_nao_per_year + age + sex + lag_weight + (1 | ID) + (1 | year), data = cumulative_combined_data, family = lognormal(link = "log"))

```
## 5.Results
Model 6 showed the best fit with an AIC score of 971.99. Key findings include:

NAO had a significant positive effect on sheep weight.
Sex: Males were generally heavier than females.
Age: Weight decreases with age.
Lag Weight: Past weight is a strong predictor of current weight.

## 6.Model Diagnostics
Residual analysis showed no significant autocorrelation, and outlier tests confirmed that outliers were within expected limits.


## Repository Contents
data/: Contains cleaned datasets (mean_nao, mass_data_cleaned).
scripts/: R scripts for data processing, visualization, and modeling.
figures/: Visualizations and residual plots from models.
results/: Output summaries of GLM and GLMM models.

