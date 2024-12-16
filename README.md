# QuizzesToXML

## Convert multiple-choice quiz files from Aiken format to XML for Canvas LMS

Summary of the R code used to transform quizzes from Aiken format text
files into xml files for La Tech's Canvas Learning Mgt System.

-   Place the text files (in Aiken format - see the example file in the
    main folder) into the text folder.

-   Run the R code in the parse_to_xml.R file. If successful, you should
    see a zip file for every quiz file in the output folder.

-   Load xml files one at a time into canvas using Import (either into a
    quiz or Item Bank).

### Note:

The clean_raw_text.R file requires a specific file structure that was
provided from a particular publisher. To use it may require extensive
editing to read your particular file structure. The code saves each
question in the Aiken format:

Which of the following is an example of a choice?

A)  bureaucratic procedures

B)  priorities attached to different objectives

C)  availability of resources

D)  labor laws

Answer: B
