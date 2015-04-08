library(shiny)
shinyUI(
  fluidPage(
    titlePanel(h1("Predicting A Regents Pass Rate Using Logistic Regression")),
    sidebarLayout(
      sidebarPanel(
        helpText("Each CSV you upload should have one header row, with student ID in the first column and score in the second."),
        fileInput("d1", "Upload CSV of old predictor scores"),
        fileInput("d2", "Upload CSV of new predictor scores"),
        fileInput("regents", "Upload CSV of old regents scores"),
        helpText("Enter the name of the regents exam"),
        textInput("testName", ""),
        selectInput("alphaLevel", 
                    label = "How certain do you want to be about the results?", 
                    choices = c("90%", "95%", "99%"), selected = "95%"),
        submitButton("Submit")
        ),
      
      mainPanel(
        h3("The process is as follows:"),
        tags$ol(
          tags$li("Create CSV (comma separated values) files for last year's predictor exam, last year's regents, and this year's regents."),
          tags$li("The first column must include student ID numbers, but they should not be actual student ID's.  You can create random numbers to assign to students before creating the files, as long as they are consistent between the old predictor and old regents files."),
          tags$li("The second column should be the scores.  The values for the regents scores should be between 0 and 100.  The values for the predictor can be on any scale, as long as it is consistent between the two predictor files."),
          tags$li("Upload each of the files using the buttons on the left.  After you upload the third, your results will appear."),
          tags$li("To customize the results, enter the name of the exam, select your desired level of certainty, and hit Sumbit"),
          tags$li("Questions?  Comments?  Want the source code?  Email ", tags$a(href="mailto:pdebarros@greentechhigh.org","pdebarros@greentechhigh.org"),".")
          ),
        h1(textOutput("response"))
      )
    )
  )
)