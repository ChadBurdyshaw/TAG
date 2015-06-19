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
      actionButton("button_data_input_book", "Choose!")
    ),
    mainPanel(
      htmlOutput("data_input_book_buttonaction")
    )
  )
})



output$data_input_book_buttonaction <- renderUI({
  observeEvent(input$button_data_input_book, {
    withProgress(message='Reading data...', value=0, {
      localstate$runtime <- system.time({
        book <- input$data_books
        bookfile <- booklist[which(booklist_names == book)]
        
        load(paste0("data/books/", bookfile))
        
        localstate$corpus <- corpus
        localstate$tdm <- tdm
        localstate$wordcount_table <- wordcount_table
        
#        assign("corpus", corpus, envir=session)
#        tdm <- tm::TermDocumentMatrix(corpus)
#        assign("tdm", tdm, envir=session)
#        wordcount_table <- sort(rowSums(as.matrix(tdm)), decreasing=TRUE)
#        assign("wordcount_table", wordcount_table, envir=session)
      })
    })
  })
  
  
  output <- eventReactive(input$button_data_input_book, {
    if (is.null(localstate$runtime))
      HTML("")
    else
      HTML(paste("The<i>", input$data_books, "</i>corpus is now ready to use!\nLoading finished in", round(localstate$runtime[3], 3), "seconds."))
  })
  
  output()
})
