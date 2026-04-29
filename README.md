# surveysearch

Provides tools to search for variables across multiple survey datasets,
examine variable properties (labels, values, missingness), and explore variable
context within datasets. Useful for navigating complex survey data with many
variables and understanding variable relationships and metadata.

## Overview

`surveysearch` provides tools to navigate complex survey data with many variables. It helps you:

- **Search** for variables by name or label across datasets
- **Examine** variable properties including labels, values, and missingness patterns
- **Explore** variable context to understand survey structure and questionnaire flow

## Installation

You can install the development version from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("malo-raballand/surveysearch")
```

## Usage

### Search for variables

```r
# Search for variables containing "education"
search_variables("educ")

# Store results for further analysis
results <- search_variables("income")
View(results)
```

### Examine a variable

```r
# Display detailed information about a variable
examine_variable("age", data = my_dataset)

# Get information without printing
info <- examine_variable("income", data = my_dataset, verbose = FALSE)
```

### Show variable context

```r
# See a variable's position in the survey with surrounding questions
show_variable_context("q501", data = my_dataset)
```

## Functions

- `search_variables()` - Search for variables across datasets
- `examine_variable()` - Get detailed information about a specific variable
- `show_variable_context()` - View a variable's context within a dataset

## Requirements

- R >= 3.5.0
- `haven` - for reading Stata, SPSS, and SAS files
- `dplyr` - for data manipulation
- `tidyr` - for tidying data

## License

MIT License - see LICENSE file for details

## Author

Malo Raballand (malo.raballand@sciencespo.fr)
