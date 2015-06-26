output$data_transform <- renderUI({
  list(
    sidebarLayout(
      sidebarPanel(
        checkboxInput("data_transform_checkbox_makelower", "Make lowercase?", value=TRUE),
        checkboxInput("data_transform_checkbox_rempunct", "Remove punctuation?", value=TRUE),
        checkboxInput("data_transform_checkbox_remnum", "Remove numbers?", value=TRUE),
        checkboxInput("data_transform_checkbox_remws", "Remove extra whitespace?", value=TRUE),
        checkboxInput("data_transform_checkbox_stem", "Stem?", value=FALSE),
        
        actionButton("button_data_transform", "Transform"),
        render_helpfile("Transform", "data/transform.md")
      ),
      mainPanel(
        htmlOutput("data_transform_buttonaction")
      )
    )
  )
})



output$data_transform_buttonaction <- renderUI({
  must_have("corpus")
  
  temp <- eventReactive(input$button_data_transform, {
    withProgress(message='Processing...', value=0, {
      
      n <- input$data_transform_checkbox_makelower + 
           input$data_transform_checkbox_rempunct + 
           input$data_transform_checkbox_remnum + 
           input$data_transform_checkbox_remws + 
           input$data_transform_checkbox_stem
      
      runtime <- system.time({
        if (input$data_transform_checkbox_makelower)
        {
          incProgress(0, message="Setting to lowercase...")
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::content_transformer(tolower))
          incProgress(1/n/2)
        }
        if (input$data_transform_checkbox_rempunct)
        {
          incProgress(0, message="Removing punctuation...")
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::removePunctuation)
          incProgress(1/n/2)
        }
        if (input$data_transform_checkbox_remnum)
        {
          incProgress(0, message="Removing numbers...")
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::removeNumbers)
          incProgress(1/n/2)
        }
        if (input$data_transform_checkbox_remws)
        {
          incProgress(0, message="Stripping whitespace...")
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::stripWhitespace)
          incProgress(1/n/2)
        }
        if (input$data_transform_checkbox_stem)
        {
          incProgress(0, message="Stemming...")
          localstate$corpus <- tm::tm_map(localstate$corpus, tm::stemDocument)
          incProgress(1/n/2)
        }
        
        incProgress(0, message="Updating tdm...")
        localstate$tdm <- tm::TermDocumentMatrix(localstate$corpus)
        setProgress(3/4, message="Updating wordcounts...")
        localstate$wordcount_table <- sort(rowSums(as.matrix(localstate$tdm)), decreasing=TRUE)
        
        localstate$sum_wordlens <- NULL
        localstate$lda_mdl <- NULL
        localstate$ng_mdl <- NULL
      })
      
      setProgress(1)
    })
    
    paste("Processing finished in", round(runtime[3], roundlen), "seconds.")
  })
  
  temp()
})

