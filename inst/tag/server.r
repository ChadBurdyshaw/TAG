library(shiny)
library(tm)
library(ggplot2)


source(file="shiny/utils/buttonfixer.r")
source(file="shiny/utils/help.r")

stopwords_list <- c("danish", "dutch", "english", "finnish", "french", "german", "hungarian", "italian", "norwegian", "portuguese", "russian", "spanish", "swedish")

booklist_names <- readLines("data/books/booklist_names.txt")
booklist <- dir("data/books/", pattern=".rda")

# manage, view, visualize, explore, transform
shinyServer(
  function(input, output, session)
  {
    ### Any state objects should go here (treat it as a list)
    localstate <- reactiveValues()
    
    files <- dir("./shiny", recursive=TRUE, pattern="[.]r$")
    files <- paste0("./shiny/", files)
    for (file in files) source(file=file, local=TRUE)
  }
)
