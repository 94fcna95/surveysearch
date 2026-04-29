# surveysearch

Efficiently navigate and understand large survey datasets with variable discovery and exploration tools. Whether you're exploring unfamiliar survey data or validating variable availability across datasets `surveysearch` can help streamline and simplify the ordeal.

- **Discover** variables by searching across multiple datasets simultaneously, matching both variable names and descriptive labels
- **Understand** variable characteristics at a glance—including labels, data types, missing patterns, and value distributions  
- **Navigate** questionnaire structure by viewing variables in context with their surrounding questions

## Installation

Install from GitHub:

```r
# install.packages("devtools")
devtools::install_github("malo-raballand/surveysearch")
```

## Quick Start

### Discover variables across datasets

```r
library(surveysearch)

# Load your survey data
survey_2023 <- read.csv("survey_2023.csv")
survey_2024 <- read.csv("survey_2024.csv")

# Search across both datasets at once
my_datasets <- list(survey_2023 = survey_2023, survey_2024 = survey_2024)

search_variables("income", data_list = my_datasets)

# Results printed to console in formatted table
# Also returnable as object for further analysis
```


### Examine variable properties

```r
# Get comprehensive information about a single variable

examine_variable("age", data = survey_2023)

# Output includes: label, data type, missing count, value labels, 
# frequency distribution (for categorical) or summary stats (for continuous)
```

### Explore questionnaire context

```r
# Understand where a variable sits within your survey

show_variable_context("q15", data = survey_2023)

# Shows 5 variables before and after your target, with their labels
# Useful for understanding questionnaire flow and related questions

# Customize the context window
show_variable_context("q15", data = survey_2023, before = 10, after = 3)
```
## Additional information 
- **Base-R compatible**: Works seamlessly with Base-R operations—chain results with `|`, `subset()`, `merge()`, and other standard functions
- **Export-ready**: Results can be easily formatted for LaTeX tables, CSV files, or integrated into larger analytical pipelines
- **Package is currently in further testing and development, any insight/recommendations is welcome. CRAN publication submitted**

## Functions

| Function | Purpose |
|----------|---------|
| `search_variables(pattern, data_list)` | Find variables by name or label across multiple datasets |
| `examine_variable(var_name, data)` | Inspect variable properties and distribution |
| `show_variable_context(var_name, data, before, after)` | View variables in their questionnaire context |

## Requirements

- R >= 3.5.0

## License

MIT License — see [LICENSE](LICENSE) file for details

## Author

Malo Raballand  
[malo.raballand@sciencespo.fr](mailto:malo.raballand@sciencespo.fr)

## Citation (Optional)

If `surveysearch` was useful in your research, please consider citing it:

```
Raballand, M. (2026). surveysearch: Tools for navigating survey datasets. 
R package version 0.1.0.
```
