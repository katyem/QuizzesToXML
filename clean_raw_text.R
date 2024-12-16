# Load required library
# This file creates XML multiple choice questions from a text file for inclusion in a Canvas zip file.
packages <- c('fs', 'readtext', 'officer')

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
  }
  library(p, character.only = TRUE)
}

# library(stringr)

# Define function to parse text file
parse_questions <- function(file_path, output_file) {
  # Read file content
  content <- readLines(file_path)
  
  # Remove unnecessary lines (header, extra info after each question, blank lines)
  content <- content[4:length(content)] # Start from line 4
  content <- content[!grepl("^(Learning Objective|AACSB|Difficulty Level|^$)", content)]
  
  # Extract questions, options, and answers
  question_indices <- grep("^\\d+\\)", content) # Lines with questions
  questions <- list()
  # Initialize a vector to store the formatted questions
  formatted_questions <- c()

  for (i in 1:70) {
    start <- question_indices[i]
    end <- ifelse(i < length(question_indices), question_indices[i + 1] - 1, length(content))
    
    # Extract question text and options
    question_block <- content[start:end]
    question_text <- sub("^[0-9]+\\) ", "", question_block[1]) # Remove the item number
    options <- question_block[2:5]
    answer <- sub("^Answer:\\s+", "", question_block[6])
    
    # Store as a list item
    questions[[i]] <- list(
      question = question_text,
      options = options,
      answer = answer
    )
    
    # Append the formatted question to the result vector
    formatted_questions <- c(
      formatted_questions,
      question_text,
      options,
      answer
    )
  }
  # Write the formatted questions to the output file
  writeLines(formatted_questions, output_file)
  cat("Formatted questions written to", output_file, "\n")
  
}

# Define the directories
input_dir <- "C:/Users/tilma/Documents/Class/New Org Leadership/Yukl book/Questions/text"
output_dir <- "C:/Users/tilma/Documents/Class/New Org Leadership/Yukl book/Questions/output"
setwd("C:/Users/tilma/Documents/Class/New Org Leadership/Yukl book/Questions")  
# Create output directory if it doesn't exist
if (!dir_exists(output_dir)) {
  dir_create(output_dir)
}


# List all Word document files in the input directory
file_list <- dir_ls(input_dir, type = "file", glob = "*.txt")


# Loop through each file, transform and save the result
for (file_path in file_list) {
  output_file <- path(output_dir, paste0(path_ext_remove(path_file(file_path)), ".txt"))
  parse_questions(file_path, output_file)
}


# View parsed questions
parsed_questions
