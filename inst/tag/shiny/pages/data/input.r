# -----------------------------------------------------------
# Utils --- must be loaded here
# -----------------------------------------------------------

update_tdm <- function()
{
  evalfun(localstate$tdm <- tm::TermDocumentMatrix(localstate$corpus),
    comment="Update term-document matrix")
}


update_wordcount <- function()
{
  evalfun(localstate$wordcount_table <- sort(rowSums(as.matrix(localstate$tdm)), decreasing=TRUE), 
    comment="Update wordcount table")
}



# -----------------------------------------------------------
# shiny
# -----------------------------------------------------------

output$data_import <- renderUI({
  sidebarLayout(
    sidebarPanel(
      ### TODO
#      radioButtons(inputId="data_infile", label="Select File:", c("txt"="txt", "dir"="dir", "rda"="rda"), selected="txt", inline=TRUE),
      conditionalPanel(condition = "input.data_infile == 'state'",
        fileInput('uploadState', 'Load previous app state:', accept=".rda"),
        uiOutput("refreshOnUpload")
      ),
      selectizeInput("data_books", "Books", booklist_names),
      actionButton("button_data_input_book", "Choose!"),
      actionButton("button_data_input_clear", "Clear")
    ),
    mainPanel(
      renderUI(localstate$out)
    )
  )
})



set_data <- function(input)
{
  observeEvent(input$button_data_input_book, {
    if (input$button_data_input_book > 0)
    {
      clear_state()
      
      withProgress(message='Loading data...', value=0, {
        runtime <- system.time({
          book <- input$data_books
          bookfile <- booklist[which(booklist_names == book)]
          
          load(paste0("data/books/", bookfile))
          
          localstate$corpus <- corpus
          localstate$tdm <- tdm
          localstate$wordcount_table <- wordcount_table
        })
        
        setProgress(1)
      })
      
      localstate$out <- HTML(paste("The<i>", input$data_books, "</i>corpus is now ready to use!\nLoading finished in", round(runtime[3], roundlen), "seconds."))
    }
  })
  
  
  invisible()
}

clear_data <- function(input)
{
  observeEvent(input$button_data_input_clear, {
    if (input$button_data_input_clear > 0)
    {
      clear_state()
      localstate$out <- HTML("Cleared!")
    }
  })
  
  
  invisible()
}



clear_modelstate <- function()
{
  localstate$explore_wordlens <- NULL
  
  localstate$lda_mdl <- NULL
  localstate$lda_out <- NULL
  
  localstate$ng_mdl <- NULL
  localstate$ng_out <- NULL
  
  invisible()
}

clear_state <- function()
{
  localstate$corpus <- NULL
  localstate$tdm <- NULL
  localstate$wordcount_table <- NULL
  
  clear_modelstate()
  
  invisible()
}


#          data(crude, package="tm")
#          localstate$corpus <- crude
#          localstate$tdm <- tm::TermDocumentMatrix(localstate$corpus)
#          localstate$wordcount_table <- sort(rowSums(as.matrix(localstate$tdm)), decreasing=TRUE)
