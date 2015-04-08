#Using Logistic Regression to predict the regents pass rates
#By Paul de Barros
#Updated 2015-02-07
#send questions and comments to pdebarros@greentechhigh.org

#There are three files that are required
#  1.csv - predictor scores, along with student ID, from prior year
#  2.csv - predictor scores, along with student ID, from current year
#  regents.csv - regents scores, along with student ID, from prior year
#In all cases, the column headers should be StudNum, Score.

#If prior data is being pulled from multiple years:
#  Predictor and regents scores get matched by student ID
#  If the same student took both the predictor and the regents in both prior years, there will be problems.
#  To avoid issues, append some letter to all student ID's in 1.csv and regents.csv for one of the years
#  Then combine the 1.csv and regents.csv for the two years


library(rv)
library(shiny)

shinyServer(
  function(input, output) {
    output$response = reactive({
      d1.in = input$d1
      d2.in = input$d2
      regents.in = input$regents
      if(is.null(d1.in)){return("")}
      if(is.null(d2.in)){return("")}
      if(is.null(regents.in)){return("")}
      d1 = read.csv(d1.in$datapath)  # Read in the prior year predictor
      d2 = read.csv(d2.in$datapath)  # Read in the new data
      regents = read.csv(regents.in$datapath)  # Read in the prior regents scores
      
      #Rename the columns
      colnames(d1) = c("StudNum","Score")
      colnames(d2) = c("StudNum","Score")
      colnames(regents) = c("StudNum","Score")
      
      #Match the regents scores with the predictor scores
      for (i in 1:nrow(d1)){
        if (d1$StudNum[i] %in% regents$StudNum){
          d1$Regents[i] = regents$Score[which(regents$StudNum == d1$StudNum[i])]
        }else{
          d1$Regents[i] = NA
        }
        d1$drop[i] = sum(is.na(d1[i,]))
      }
      
      #Get rid of the missing data rows
      d1 = d1[which(d1$drop == 0),]
      d2$drop = is.na(d2$StudNum)
      d2 = d2[which(d2$drop == FALSE),]
      
      #Create the Passed variable
      d1$Passed = 0
      d1$Passed[which(d1$Regents > 64)] = 1
      source("GetSuccessRates.R")
      source("http://gsubfn.googlecode.com/svn/trunk/R/list.R")
      
      list[PassRates,new.probs] = GetSuccessRates(d1,d2)
      
      ConfPoints = switch(input$alphaLevel,
                          "90%" = c(11,191),
                          "95%" = c(6,196),
                          "99%" = c(2,200))
      
      CI = quantile(PassRates, probs = seq(0,1,.005), names = F)[ConfPoints]*100
      
      
      paste0(c("If all students take the ", 
               input$testName, " regents, ",
               "I predict a pass rate of  ",
               round(mean(new.probs)*100),
               "%.  ",
               "I am ", input$alphaLevel , " sure that the pass rate will be between ",
               as.character(round(CI[1])),
               "% and ",
               as.character(round(CI[2])),
               "%."),
             collapse = "")
    })
  }
)