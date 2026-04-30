#' Search for Variables Across Datasets
#'
#' Search for variables matching a pattern across multiple datasets.
#' Searches both variable names and variable labels.
#'
#' @param pattern A regular expression or literal string to match (case-insensitive).
#' @param data_list A named list of data frames to search.
#' @param datasets_info Optional data frame with column `name` listing dataset names.
#'   If NULL, uses names from `data_list`.
#'
#' @return Invisibly returns a data frame with columns:
#'   \describe{
#'     \item{dataset}{Name of the dataset}
#'     \item{variable}{Variable name}
#'     \item{label}{Variable label or "No label" if missing}
#'     \item{match_type}{Either "Variable Name" or "Label Text"}
#'   }
#'
#' @examples
#' \dontrun{
#' # Create sample data with labels
#' df1 <- data.frame(age = 1:3, income = c(50000, 60000, 70000))
#' attr(df1$age, "label") <- "Age in years"
#' attr(df1$income, "label") <- "Annual income"
#'
#' df2 <- data.frame(education = c("HS", "BA", "MA"), employment = c("Yes", "No", "Yes"))
#' attr(df2$education, "label") <- "Education level"
#' attr(df2$employment, "label") <- "Currently employed"
#'
#' # Create a named list of data frames (NOT a list of text names!)
#' my_datasets <- list(survey_2023 = df1, survey_2024 = df2)
#'
#' # Search across multiple datasets
#' search_variables("age", data_list = my_datasets)
#'
#' # Search for pattern in labels
#' search_variables("income", data_list = my_datasets)
#'
#' # WRONG - do not do this:
#' # wrong_list <- list(c("survey_2023", "survey_2024"))  # List of text!
#' # search_variables("age", data_list = wrong_list)  # Will fail!
#' }
#'
#' @export
search_variables <- function(pattern, data_list, datasets_info = NULL) {
  
  # Check that data_list is actually a list of data frames
  if (!is.list(data_list)) {
    stop("data_list must be a named list of data frames. Example: list(survey1 = df1, survey2 = df2)")
  }
  
  # Check if user passed a list of strings instead of data frames
  if (is.character(unlist(data_list))) {
    stop("data_list contains text/strings, not data frames. You need to pass the actual data frames. Example: list(survey1 = data1, survey2 = data2)")
  }
  
  # If datasets_info not provided, create from data_list names
  if (is.null(datasets_info)) {
    datasets_info <- data.frame(name = names(data_list), stringsAsFactors = FALSE)
  }
  
  results <- data.frame(
    dataset = character(),
    variable = character(),
    label = character(),
    match_type = character(),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_len(nrow(datasets_info))) {
    dataset_name <- datasets_info$name[i]
    if (!(dataset_name %in% names(data_list))) next
    
    data <- data_list[[dataset_name]]
    
    # Search variable NAMES
    vars_matching_names <- grep(pattern, names(data), ignore.case = TRUE, value = TRUE)
    
    for (var in vars_matching_names) {
      label <- attr(data[[var]], "label")
      results <- rbind(results, data.frame(
        dataset = dataset_name,
        variable = var,
        label = ifelse(is.null(label), "No label", label),
        match_type = "Variable Name",
        stringsAsFactors = FALSE
      ))
    }
    
    # Search variable LABELS
    all_vars <- names(data)
    for (var in all_vars) {
      label <- attr(data[[var]], "label")
      
      # Skip if no label or if we already matched this variable by name
      if (is.null(label) || var %in% vars_matching_names) next
      
      # Check if pattern matches the label
      if (grepl(pattern, label, ignore.case = TRUE)) {
        results <- rbind(results, data.frame(
          dataset = dataset_name,
          variable = var,
          label = label,
          match_type = "Label Text",
          stringsAsFactors = FALSE
        ))
      }
    }
  }
  
  # Sort results: by dataset first, then name matches before label matches
  results <- results[order(results$dataset,
                           factor(results$match_type, levels = c("Variable Name", "Label Text"))), ]
  
  # Print results
  .print_search_results(results)
  
  invisible(results)
}


#' Print Search Results Table
#'
#' Internal function to format and print search results.
#'
#' @param results Data frame with search results.
#'
#' @keywords internal
#' @noRd
.print_search_results <- function(results) {
  if (is.null(results) || nrow(results) == 0) {
    cat("No results found.\n")
    return(invisible(NULL))
  }
  
  cat("\n")
  
  # Print header
  cat(sprintf("%-20s %-20s %-50s %-15s\n", "dataset", "variable", "label", "match_type"))
  cat(rep("-", 105), "\n", sep = "")
  
  # Print rows
  for (i in seq_len(nrow(results))) {
    row <- results[i, ]
    label_short <- substr(as.character(row$label), 1, 50)
    cat(sprintf("%-20s %-20s %-50s %-15s\n",
                as.character(row$dataset),
                as.character(row$variable),
                label_short,
                as.character(row$match_type)))
  }
  
  cat(sprintf("\nTotal: %d matches\n\n", nrow(results)))
  
  invisible(results)
}


#' Examine a Variable in Detail
#'
#' Display detailed information about a specific variable including its label,
#' class, missing values, value labels, and summary statistics.
#'
#' @param var_name Character string. Name of the variable to examine.
#' @param data Data frame containing the variable.
#' @param verbose Logical. If TRUE, print detailed information to console.
#'
#' @return Invisibly returns a list with elements:
#'   \describe{
#'     \item{name}{Variable name}
#'     \item{label}{Variable label}
#'     \item{class}{Variable class}
#'     \item{n_unique}{Number of unique non-missing values}
#'     \item{n_missing}{Number of missing values}
#'   }
#'
#' @examples
#' \dontrun{
#' df <- data.frame(age = c(25, 30, 35))
#' attr(df$age, "label") <- "Age in years"
#' examine_variable("age", data = df)
#' }
#'
#' @export
examine_variable <- function(var_name, data, verbose = TRUE) {
  
  if (!is.data.frame(data)) {
    stop("data must be a data frame")
  }
  
  if (!(var_name %in% names(data))) {
    cat(sprintf("Variable '%s' NOT FOUND in dataset\n", var_name))
    return(invisible(NULL))
  }
  
  var_data <- data[[var_name]]
  var_label <- attr(var_data, "label")
  var_labels <- attr(var_data, "labels")
  
  if (verbose) {
    cat(sprintf("\n=== Variable: %s ===\n", var_name))
    cat(sprintf("Label: %s\n", ifelse(is.null(var_label), "No label", var_label)))
    cat(sprintf("Class: %s\n", paste(class(var_data), collapse = ", ")))
    cat(sprintf("Missing: %d (%.1f%%)\n",
                sum(is.na(var_data)),
                100 * sum(is.na(var_data)) / length(var_data)))
    
    # Show value labels if categorical
    if (!is.null(var_labels)) {
      cat("Value Labels:\n")
      print(var_labels)
    }
    
    # Show summary
    if (length(unique(var_data[!is.na(var_data)])) <= 10) {
      cat("\nFrequency Table:\n")
      print(table(var_data, useNA = "ifany"))
    } else {
      cat("\nSummary (non-missing):\n")
      print(summary(var_data[!is.na(var_data)]))
    }
  }
  
  invisible(list(
    name = var_name,
    label = var_label,
    class = class(var_data),
    n_unique = length(unique(var_data[!is.na(var_data)])),
    n_missing = sum(is.na(var_data))
  ))
}


#' Show Variable Context in Dataset
#'
#' Display a variable along with specified number of variables before and after it
#' in dataset order.
#'
#' @param var_name Character string. Name of the variable to show context for.
#' @param data Data frame containing the variable.
#' @param before Integer. Number of variables to show before the target variable.
#'   Default is 5.
#' @param after Integer. Number of variables to show after the target variable.
#'   Default is 5.
#' @param verbose Logical. If TRUE, print formatted output.
#'
#' @return Invisibly returns a data frame with columns:
#'   \describe{
#'     \item{pos}{Position of the variable in the dataset}
#'     \item{variable}{Variable name}
#'     \item{label}{Variable label}
#'     \item{target}{Indicator showing target variable}
#'   }
#'
#' @examples
#' \dontrun{
#' df <- data.frame(a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8)
#'
#' # Show 5 before and 5 after (default)
#' show_variable_context("e", data = df)
#'
#' # Show only 2 before and 2 after
#' show_variable_context("e", data = df, before = 2, after = 2)
#'
#' # Show 10 before and 3 after
#' show_variable_context("e", data = df, before = 10, after = 3)
#' }
#'
#' @export
show_variable_context <- function(var_name, data, before = 5, after = 5, verbose = TRUE) {
  
  if (!is.data.frame(data)) {
    stop("data must be a data frame")
  }
  
  if (!(var_name %in% names(data))) {
    cat(sprintf("Variable '%s' not found in dataset\n", var_name))
    return(invisible(NULL))
  }
  
  all_vars <- names(data)
  
  # Find position of target variable
  var_position <- which(all_vars == var_name)
  
  if (length(var_position) == 0) {
    cat(sprintf("Variable '%s' not found in dataset\n", var_name))
    return(invisible(NULL))
  }
  
  # Get indices for variables before and after
  start_idx <- max(1, var_position - before)
  end_idx <- min(length(all_vars), var_position + after)
  
  context_vars <- all_vars[start_idx:end_idx]
  
  # Build results dataframe
  results <- data.frame(
    pos = start_idx:end_idx,
    variable = context_vars,
    label = sapply(context_vars, function(v) {
      label <- attr(data[[v]], "label")
      ifelse(is.null(label), "No label", label)
    }),
    target = ifelse(context_vars == var_name, " <--", ""),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  
  if (verbose) {
    cat(sprintf("\n=== Variable Context: '%s' ===\n", var_name))
    cat(sprintf("Position: %d of %d total variables\n\n", var_position, length(all_vars)))
    print(results)
    cat("\n")
  }
  
  invisible(results)
}
