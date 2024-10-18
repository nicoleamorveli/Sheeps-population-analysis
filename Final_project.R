
"Sheep Weight vs NAO Analysis"


# Sheep Weight vs NAO Analysis

## Overview

This project explores the relationship between the North Atlantic Oscillation (NAO) and sheep weight, using statistical modeling and data analysis techniques. The dataset includes measurements of sheep body weight recorded over several years, along with corresponding NAO values. The primary objective is to determine if there is a significant relationship between NAO and sheep weight using **mixed-effects models** and various probability distributions.

---

## Dataset

The dataset contains the following features:

- `year`: Year in which the measurements were recorded.
- `weight`: Body weight of sheep.
- `sex`: Sex of the sheep (`m` for male, `f` for female).
- `ID`: Unique identifier for individual sheep.
- `NAO`: North Atlantic Oscillation index values for each year.

The dataset is divided into two files:
- **mass_data**: Contains sheep weight and sex information.
- **nao_data**: Contains NAO index values by year.

---

## Project Steps

### 1. Data Cleaning

- **NAO Data**: The NAO index data was grouped by year, and the average NAO per year was computed.
- **Mass Data**: The mass data was filtered to include only valid entries for sex (`m` and `f`), and rows with missing weight values were removed.

### 2. Merging Data

- The cleaned mass data was merged with the NAO data using the `year` column as the key. This allowed us to analyze the relationship between sheep weight and NAO values.

### 3. Exploratory Data Analysis (EDA)

- **Summary Statistics**: Descriptive statistics were generated for both datasets to understand the distributions and ranges of key variables.
- **Data Visualization**: A scatter plot was created to visualize the relationship between NAO and sheep weight, using different shapes and colors to represent the number of individual sheep recorded per year and the time range (e.g., 1980–1990, 1990–2000).

### 4. Statistical Modeling

Several probability distributions were tested to model the distribution of sheep weight:

- **Normal Distribution**: Initially, a Gaussian (normal) distribution was fitted to the sheep weight data.
  - Goodness-of-fit statistics were calculated using the **Kolmogorov-Smirnov (KS)** test, **Cramer-von Mises (CM)** test, and **Anderson-Darling (AD)** test.
  - Results indicated that the normal distribution did not fit the data well (p-values < 0.05).

- **Log-Normal Distribution**: The data was also fitted using a log-normal distribution.
  - The results showed better fit compared to the normal distribution, but still did not adequately explain the variation in sheep weight.

- **Gamma Distribution**: Finally, a gamma distribution, known for its positive skew, was fitted to the sheep weight data.
  - The gamma distribution showed the best fit based on goodness-of-fit statistics, with p-values suggesting a reasonable match between the observed data and the gamma model.

### 5. Mixed-Effects Modeling

- Given the hierarchical nature of the data (multiple measurements per sheep, and sheep recorded over time), a **nonlinear mixed-effects model** was proposed.
- This model accounts for both **within-individual responses** (changes in weight over time for the same sheep) and **between-individual variability** (differences between individual sheep responses).

---

## Results

- **Data Visualization**: A scatter plot with a trend line demonstrated a positive correlation between NAO and mean sheep weight, with weight generally increasing as NAO values increased over time.
- **Model Selection**: The **gamma distribution** was chosen as the best fit for the sheep weight data based on goodness-of-fit tests. The mixed-effects model was recommended for further investigation, as it can help identify factors (such as NAO) that influence the variability in sheep weight over time.

---

## Conclusion

- The analysis suggests that there is a significant relationship between NAO values and sheep weight, with higher NAO values generally corresponding to higher sheep weights.
- The gamma distribution was the best fit for the data, and a mixed-effects model can provide further insights into individual and population-level responses.

---

## How to Run the Analysis

1. Install necessary R packages:

    ```r
    install.packages(c("vroom", "plyr", "dplyr", "tidyr", "ggplot2", "fitdistrplus", "goftest", "Hmisc", "viridis", "performance"))
    ```

2. Clone this repository:

    ```bash
    git clone https://github.com/your-username/sheep-nao-analysis.git
    ```

3. Open and run the R script or R Markdown file provided to reproduce the analysis.

---

## Future Work

- **Model Refinement**: Further work can refine the mixed-effects model to explore individual sheep responses to NAO and other environmental factors.
- **Additional Variables**: Incorporating more environmental or biological variables could help explain variations in sheep weight.
- **Longer Time Periods**: Extending the dataset with more years could provide a clearer understanding of long-term trends.





