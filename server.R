#Using Logistic Regression to predict the regents pass rates
#By Paul de Barros
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

source("GetSuccessRates.R") #This file contains the code to compute the predicted pass rates
source("list.R") #this contains code that allows functions to return lists

shinyServer(function(input, output) {
  output$response = reactive({
    d1.in = input$d1
    d2.in = input$d2
    regents.in = input$regents
    if(is.null(d1.in)){return("")} #wait until the files are loaded
    if(is.null(d2.in)){return("")} #wait until the files are loaded
    if(is.null(regents.in)){return("")} #wait until the files are loaded
    d1 = read.csv(d1.in$datapath)  # Read in the prior year predictor
    d2 = read.csv(d2.in$datapath)  # Read in the new data
    regents = read.csv(regents.in$datapath)  # Read in the prior regents scores
    
    #Rename the columns
    colnames(d1) = c("StudNum","Score")
    colnames(d2) = c("StudNum","Score")
    colnames(regents) = c("StudNum","Score")
    
    #Match the regents scores with the predictor scores
    for (i in 1:nrow(d1)){
      if (d1$StudNum[i] %in% regents$StudNum){ #if this student has an outcome score
        d1$Regents[i] = regents$Score[which(regents$StudNum == d1$StudNum[i])] #put the outcome score in that row
      }else{ # if the student does not have an outcome score
        d1$Regents[i] = NA # put NA in that row
      }
      d1$drop[i] = sum(is.na(d1[i,])) #indicate whether the row should be dropped
    } #end of for loop
    
    #Get rid of the missing data rows
    #In d1, the drop variable indicates whether it should be kept (0) or dropped (>0)
    d1 = d1[which(d1$drop == 0),] #subset d1 to only the rows with complete data
    d2$drop = is.na(d2$StudNum) #In d2, the drop variable indicates whether the row includes actual data (in case there are extra empty rows at the bottom)
    d2 = d2[which(d2$drop == FALSE),] #subset d2 to only those rows that have a student number
    
    #Create the Passed variable
    d1$Passed = 0 #set the default value to fail
    d1$Passed[which(d1$Regents > 64)] = 1 #set any outcome score greater than 64 to pass (this will need to be >= PassCutoff, after PassCutoff is defined)
    
    #Get the predicted pass rates
    list[PassRates,new.probs] = GetSuccessRates(d1,d2)
    
    #select the locations of the quantiles of the confidence intervals
    ConfPoints = switch(input$alphaLevel,
                        "90%" = c(11,191),
                        "95%" = c(6,196),
                        "99%" = c(2,200)) #note that there are 201 elements in the vector, so 200 corresponds to the .995 quantile
    
    #select the actual confidence interval quantiles
    CI = quantile(PassRates, probs = seq(0,1,.005), names = F)[ConfPoints]*100
    
    #produce the output
    paste0(c("If all students take the ", 
             input$testName, " regents, ",
             "I predict a pass rate of  ", round(mean(new.probs)*100), "%.  ",
             "I am ", input$alphaLevel , " sure that the pass rate will be between ",
             as.character(round(CI[1])), "% and ", as.character(round(CI[2])), "%."),
           collapse = "")
  }) #end of reactive function defining output$response
}) #end of shinyServer