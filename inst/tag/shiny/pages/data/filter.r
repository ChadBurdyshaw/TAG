output$data_filter <- renderUI({
  list(
    sidebarLayout(
      sidebarPanel(
        selectizeInput("data_filter_stopwords_lang", "Stopwords Language", stopwords_list, "english"),
        checkboxInput("data_filter_checkbox_remstop", "Remove stopwords?", value=TRUE),
        
        hr(),
        
        checkboxInput("data_filter_checkbox_exclude", "Exclude list?", value=TRUE),
        checkboxInput("data_filter_checkbox_greedy", "Exclude greedily?", value=TRUE),
        checkboxInput("data_filter_checkbox_greedy", "Exclude ignores case?", value=FALSE),
        tags$textarea(id="data_filter_exclude", rows=1, cols=10, ""),
        
        actionButton("button_data_filter", "Filter"),
        render_helpfile("Filter", "data/filter.md")
      ),
      mainPanel(
        htmlOutput("data_filter_buttonaction")
      )
    )
  )
})



output$data_filter_buttonaction <- renderUI({
  must_have("corpus")
  
  temp <- eventReactive(input$button_data_filter, {
    withProgress(message='Processing...', value=0, {
      
      n <- input$data_filter_checkbox_remstop
      
      runtime <- system.time({
        if (input$data_filter_checkbox_remstop)
        {
          incProgress(0, message="Removing stopwords...")
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::removeWords, tm::stopwords(input$data_filter_stopwords_lang))
          incProgress(1/n/2)
        }
        if (input$data_filter_checkbox_exclude)
        {
          terms <- input$data_filter_exclude
#          terms <- paste0("(", paste0(unlist(strsplit(terms, split=",")), collapse="|"), ")")
          terms <- unlist(strsplit(terms, split=","))
          
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::removeWords, terms)
#          endofword <- paste0(terms, "(.*?)(\\s|\\n|[:punct:])")
#          endofline <- paste0(terms, "(.*?)")
#          
#          for (i in 1:length(localstate$corpus))
#          {
#            
#            localstate$corpus[[i]]$content <- gsub(localstate$corpus[[i]]$content, pattern=endofword, replacement="")
#            localstate$corpus[[i]]$content <- gsub(localstate$corpus[[i]]$content, pattern=endofline, replacement="")
#          }
        }
        
        incProgress(0, message="Updating tdm...")
        localstate$tdm <- tm::TermDocumentMatrix(localstate$corpus)
        setProgress(3/4, message="Updating wordcounts...")
        localstate$wordcount_table <- sort(rowSums(as.matrix(localstate$tdm)), decreasing=TRUE)
      })
      
      setProgress(1)
    })
    
    paste("Processing finished in", round(runtime[3], roundlen), "seconds.")
  })
  
  temp()
})

