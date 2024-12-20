# This program creates xml multiple-choice items from a text file in Aiken file format for inclusion in a Canvas zip file.  More later... maybe...
# Authors: Tilman Sheets and chatGPT e.g., https://stackoverflow.com
# Required packages
# Ensure required packages are installed and loaded
# This program creates xml multiple-choice items from a text file in Aiken file format for inclusion in a Canvas zip file.  More later... maybe...
packages  <- c("XML", "stringi", "zip")

for(p in packages){
  if(!require(p, character.only = T)){
    install.packages(p)
  }
  library(p, character.only = T)
}

# Directory paths

main_dir <-   'C:/Users/Your_folders'  ## the directory on YOUR system 
text_dir <- file.path(main_dir, 'text')
temp_dir <- file.path(main_dir, "temp")  # Temporary folder for output
output_dir <- file.path(main_dir, "output")  # Final zip file location
output_name <- "Myers Chapter"  # Name for output files   Results in "Myers Chapter 01.xml"
# Ensure directories exist
dir.create(temp_dir, showWarnings = FALSE)
dir.create(output_dir, showWarnings = FALSE)

xml_template <- readChar(file.path(main_dir, "xml.text.template.xml"), 
                         file.info(file.path(main_dir, "xml.text.template.xml"))$size)
manifest_template <- readChar(file.path(main_dir, "manifest.template.xml"), 
                              file.info(file.path(main_dir, "manifest.template.xml"))$size)


# Function to generate a random alphanumeric string of a given length
generate_random_string <- function(length) {
  stri_rand_strings(1, length, pattern = "[a-z0-9]")
}

clean_string <- function(input_string) {
  # Replace special XML characters
  input_string <- gsub("&", "&amp;", input_string)
  input_string <- gsub("'", "&apos;", input_string)
  
  return(input_string)
}

# Function to process each question
process_question <- function(question_lines) {
  
  question <- question_lines[1]
  options <- question_lines[2:5] 
  options <- substr(options, 4, nchar(options))
  answer <- substr(question_lines[6], nchar(question_lines[6]), nchar(question_lines[6]))
  # Formatting answer
  answer_num <- switch(answer, A = 1, B = 2, C = 3, D = 4)
  
  # Building the CSV line
  # randomize the options order and save the answer
  op_order <- sample(c(1:4))
  csv_line <- c(question, 
                options[op_order[1]], 
                options[op_order[2]], 
                options[op_order[3]], 
                options[op_order[4]],
                which(op_order == answer_num))
  return(csv_line)
}

setwd(text_dir)  
# Get list of all text files in the folder
files <- list.files(pattern = "\\.txt$")

# Read and process each text file = files[3]    z = 2
for (z in 1:length(files)) {  
  
  if (substr(files[z],1,1) != c('~')) {  #  clears up an issue with some type of hidden files with a tilde 
        chapter_number <- as.numeric(gsub("\\D", "", files[z]))     
        file_name <- files[z]
        manifest_file <- sprintf(manifest_template, chapter_number, generate_random_string(33))  # Only changing the chapter number in the manifest header.
      
        # Create the XML header with placeholders for dynamic values
        xml_header_template <- '<?xml version="1.0" encoding="ISO-8859-1"?>
        <questestinterop xmlns="http://www.imsglobal.org/xsd/ims_qtiasiv1p2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/ims_qtiasiv1p2 http://www.imsglobal.org/xsd/ims_qtiasiv1p2p1.xsd">
          <assessment ident="%s" title="%s">
            <qtimetadata>
              <qtimetadatafield>
                <fieldlabel>cc_maxattempts</fieldlabel>
                <fieldentry>1</fieldentry>
              </qtimetadatafield>
            </qtimetadata>    
          <section ident="root_section">'
        
        
        random_indent = generate_random_string(33) # Generate a random string of the same length as the original ident  
        # Replace placeholders with dynamic values
        xml_header <- sprintf(xml_header_template, random_indent, paste(output_name, chapter_number))
        
        
        lines <- readLines(file_name)
        num_lines <- length(lines)
        
        csv_lines <- data.frame(question = NA, 
                                option1 = NA, 
                                option2 = NA, 
                                option3 = NA, 
                                option4 = NA, 
                                answer = NA)
        
        lp <- 1   
        i = 1
        while (i <= num_lines) {
          # Each question is 6 lines long - 1 question, 4 options, 1 answer
          if ((i + 5) <= num_lines) {
            question_lines <- lines[i:(i+5)]
            csv_line <- process_question(question_lines)
            csv_lines[lp,] <- csv_line
            i <- i + 6  # Move to the next question block
            lp <- lp+1
          } else {
            break
          }
        }
        
        ## We now have questions for one chapter  ## $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
        
        items <- csv_lines
        
        xml_file <- ""
        # i <- 1
        # Loop through each row of the dataframe
        for (i in 1:nrow(items)) {
          # Generate random strings for ident and other fields
          random_ident <- generate_random_string(33)
          random_field <- generate_random_string(33) # and others as needed
          random_ass <- generate_random_string(33)
          # Prepare the question and options
          question <- items$question[i]
          
          # Prepare the correct answer
          item_id = i*1000
          correct_answer <- item_id + (as.numeric(items$answer[i])-1)  # e.g., 1000-1003
          
          short_question <- substr(question, 1, 40)
          
          # Remove partial word at the end, if any
          # The regex looks for a space followed by any characters until the end of the string
          # and replaces it with nothing
          short_question <- sub("\\s+\\S*$", "", short_question)
          
          # Replace in the XML template
          xml_modified <- sprintf(xml_template, 
                                  random_ident, 
                                  short_question, 
                                  random_field, 
                                  question, 
                                  item_id,
                                  items[i, 2], 
                                  (item_id+1),
                                  items[i,3], 
                                  item_id+2,
                                  items[i,4], 
                                  item_id+3,
                                  items[i,5], 
                                  correct_answer )
          xml_file <- paste(xml_file, xml_modified, sep = "\n")
          
          if (nchar(question) == 0 || any(is.na(items[i, 2:6]))) {
            stop(sprintf("Malformed data in question %d of chapter %d", i, z))
          }
          cat(xml_modified)
          # Print or save the modified XML
          
        }
        
        xml_file <- clean_string(xml_file)
        
        ## $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
        # Define the output directory
        
        # create footer  
        xml_footer <- "</section> \n     </assessment> \n  </questestinterop> \n"
        doc <- paste(xml_header, xml_file, xml_footer, sep = "\n")
        # put all questions into xml
        
        file_name <- substr(files[z],1,4)
        doc <- xmlParse(doc)  
        output1 <- file.path(temp_dir, "questions.xml")
        saveXML(doc, file = output1)
        
        doc2 <- xmlParse(manifest_file)
        output2 <- file.path(temp_dir, "imsmanifest.xml")
        saveXML(doc2, file = output2)
        zip_name <- paste(output_dir, "/Ch", chapter_number, "_Meyers.zip", sep = "")
        zip::zipr(zip_name, files = c(output1, output2))
        print(zip_name)
  }

}




