output$analyse_lda_fit <- renderUI(
  sidebarLayout(
    sidebarPanel(
      h5("Latent Dirichlet Allocation"),
      sliderInput("lda_ntopics", "Number of Topics", min=1, max=20, value=3),
      selectizeInput("lda_method", "Method", c("Gibbs", "VEM"), "Gibbs"),
      actionButton("lda_button_fit", "Fit"),
      render_helpfile("LDA", "analyse/lda_fit.md")
    ),
    mainPanel(
      textOutput("analyse_lda_fit_")
    )
  )
)

output$analyse_lda_fit_ <- renderText({
  temp <- eventReactive(input$lda_button_fit, {
    withProgress(message='Fitting the model...', value=0,
    {
      incProgress(0, message="Transforming to document-term matrix...")
      DTM <- qdap::as.dtm(localstate$corpus)
      
      print("asdf") # watch the terminal and be amazed!
      
      incProgress(1/2, message="Fitting the model...")
      localstate$lda_mdl <- topicmodels::LDA(DTM, k=input$lda_ntopics, method=input$lda_method)
      
      setProgress(1)
    })
    
    capture.output(localstate$lda_mdl)
  })
  
  temp()
})



output$analyse_lda_topics <- renderUI(
  sidebarLayout(
    sidebarPanel(
      h5("Latent Dirichlet Allocation"),
      sliderInput("lda_nterms", "Number of Terms", min=1, max=50, value=10),
      render_helpfile("LDA", "analyse/lda_topics.md")
    ),
    mainPanel(
      renderTable({
        if (!is.null(localstate$lda_mdl))
          topicmodels::terms(localstate$lda_mdl, input$lda_nterms)
        else
          stop("You must first fit a model in the 'Fit' tab!")
      })
    )
  )
)

