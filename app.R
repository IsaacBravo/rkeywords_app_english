library(shiny)
library(bslib)
library(udpipe)
library(cleanNLP)
library(quanteda)
library(quanteda.textstats)


cnlp_init_udpipe()

# source("sean_functions.R")
source("spacyr_functions.R")

# Function to convert boolean search string to individual terms
convert_bool <- function(x) {
  # Remove operators
  x <- gsub("AND|OR|NOT", "", x)
  # Remove parentheses
  x <- gsub("[\\(\\)]", "", x)
  # Remove wildcards
  x <- gsub("\\*", "", x)
  # Split into vector and trim whitespace
  terms <- trimws(unlist(strsplit(x, "\\s+")))
  # Remove empty strings
  terms <- terms[terms != ""]
  return(terms)
}

ui <- page_sidebar(
  title = "Keyword Generator",
  sidebar = sidebar(
    textInput("rawString",
              "Enter search string:",
              value = "Immigrant* OR migrant* OR asylum seeker* OR visa*"),
    fileInput("corpusFile",
              "Upload corpus file (RDS):",
              accept = ".rds"),
    selectInput("modelPath",
              "Select GloVe model:",
              choices = c("glove.6B.50d.txt", "glove.6B.100d.txt", "glove.6B.200d.txt", "glove.6B.300d.txt"),
              selected = "glove.6B.300d.txt"),
    selectInput("nCandidates",
                "Number of Candidates:",
                choices = c(25, 50, 100, 150, 200),
                selected = 100),
    selectInput("n",
                "Number of Keywords for Query:",
                choices = c(3, 5, 10, 20, 30, 40, 50),
                selected = 10),
    actionButton("process", "Process Keywords", class = "btn-primary")
  ),

  card(
    card_header("Results"),
    card_body(
      card(
        bslib::card_header(
          class = "d-flex justify-content-between",
          "seedWords",
          # div(
          #   shiny::actionButton("copy_seedWords", label = "", icon = shiny::icon("copy"))
          # )
        ),
        verbatimTextOutput("seedWords"),
      ),
      card(
        card_header(
          class = "d-flex justify-content-between",
          "keywordsNew",
          # div(
          #   shiny::actionButton("copy_keywordsNew", label = "", icon = shiny::icon("copy"))
          # )
        ),
        verbatimTextOutput("keywordsNew"),
      ),
      card(
        card_header(
          class = "d-flex justify-content-between",
          "Final Query",
          # div(
          #   shiny::actionButton("copy_queryOutput", label = "", icon = shiny::icon("copy"))
          # )
        ),
        verbatimTextOutput("queryOutput"),
      )
    )
  )
)

server <- function(input, output, session) {
  # Initialize spacy when the app starts

  # observe({
  #   spacy_initialize(model = "en_core_web_sm")
  # })

  # Process data when button is clicked
  observeEvent(input$process, {


    req(input$rawString)
    req(input$corpusFile)

    # Start the progress indicator
    shinybusy::show_modal_spinner(spin = "circle", text = "Processing...")

    # Convert boolean search string to seed words
    seedWords <- convert_bool(input$rawString)

    # Read corpus file
    rawCorp <- readRDS(input$corpusFile$datapath)

    # Generate new keywords
    keywordsNew <- automate_keywords(
      seedWords = seedWords,
      corpus = rawCorp,
      modelPath = paste0("./models/", input$modelPath),
      # modelPath = input$modelPath,
      nCandidates = as.numeric(input$nCandidates)
    )

    # Create query
    queryNew <- create_query(keywordsNew, n = as.numeric(input$n), type = "regex")

    # Display results
    output$seedWords <- renderPrint({
      cat("Seed Words:\n")
      print(seedWords)
    })

    output$keywordsNew <- renderPrint({
      cat("\nGenerated Keywords:\n")
      print(keywordsNew)
    })

    output$queryOutput <- renderPrint({
      cat("\nGenerated Query:\n")
      print(queryNew)
    })

    # Stop the progress indicator
    shinybusy::remove_modal_spinner()

  })

  # Clean up spacy when the session ends
  onStop(function() {
    spacy_finalize()
  })

}

options(shiny.launch.browser = TRUE)

# JavaScript function for copying text
jsCode <- "
Shiny.addCustomMessageHandler('copyText', function(message) {
  var text = document.getElementById(message.id).innerText;
  navigator.clipboard.writeText(text).then(() => {
    alert('Copied: ' + text);
  }).catch(err => {
    console.error('Failed to copy text: ', err);
  });
});
"

shinyApp(ui, server, options = list(js = jsCode))
