output$analyse_ngram_fit <- renderUI(
  sidebarLayout(
    sidebarPanel(
      h5("N-Grams"),
      sliderInput("ngram_n", "Number of words per 'gram' (n)", min=1, max=10, value=2),
      actionButton("ngram_button_fit", "Fit"),
      render_helpfile("Ngram Fit", "analyse/ngram_fit.md")
    ),
    mainPanel(
      textOutput("analyse_ngram_fit_")
    )
  )
)

output$analyse_ngram_fit_ <- renderText({
  must_have("corpus")
  
  temp <- eventReactive(input$ngram_button_fit, {
    withProgress(message='', value=0,
    {
      runtime <- system.time({
        incProgress(0, message="Collapsing corpus...")
        text <- ngram::concatenate(sapply(localstate$corpus, function(i) i$content), collapse=" ")
        
        incProgress(1/2, message="Fitting the model...")
        localstate$ng_mdl <- ngram::ngram(text, n=input$ngram_n)
        
        setProgress(1)
      })
    })
    
    paste0("Fit an ngram object with ", localstate$ng_mdl@ngsize, " ", localstate$ng_mdl@n, "-grams in ", round(runtime[3], roundlen), " seconds.")
  })
  
  temp()
})



output$analyse_ngram_phrasetable <- renderUI({
  mainPanel(
    DT::dataTableOutput("analyse_ngram_inspect_")
  )
})

output$analyse_ngram_inspect_ <- DT::renderDataTable({
  must_have("corpus")
  must_have("ng_mdl")
  
  withProgress(message='Generating phrase table...', value=0, {
    pt <- ngram::get.phrasetable(localstate$ng_mdl)
    pt$prop <- round(pt$prop, roundlen)
    rownames(pt) <- NULL
    
    incProgress(3/4, message="Rendering...")
    DT::datatable(pt, extensions="Scroller", escape=TRUE,
      options = list(
        deferRender = TRUE,
        dom = "frtiS",
        scrollY = 300,
        width = 500,
        scrollCollapse = TRUE
      )
    )
  })
})



output$analyse_ngram_babble <- renderUI({
  sidebarLayout(
    sidebarPanel(
      h5("Ngram Babbling"),
      sliderInput("ngram_babble_genlen", "Number of terms", min=5, max=500, value=20),
      textInput("ngram_babble_seed", "Seed"),
      render_helpfile("Ngram Babbling", "analyse/ngram_babble.md")
    ),
    mainPanel(
      renderText({
        must_have("corpus")
        must_have("ng_mdl")
        
          withProgress(message='Generating nonsense...', value=0,
          {
            seed <- input$ngram_babble_seed
            if (seed == "")
              seed <- ngram:::getseed()
            else if (is.na(as.integer(seed)))
              stop("Seed must be a number!")
            else
              seed <- as.integer(seed) ### FIXME warning for non-ints
            
            res <- ngram::babble(localstate$ng_mdl, genlen=input$ngram_babble_genlen, seed=seed)
          })
          
          res
        
      })
    )
  )
})

