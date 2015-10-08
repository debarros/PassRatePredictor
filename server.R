#Using Logistic Regression to predict the regents pass rates
#By Paul de Barros
#send questions and comments to pdebarros@greentechhigh.org

#There are three files that are required
#  1.csv - predictor scores, along with student ID, from prior year
#  2.csv - predictor scores, along with student ID, from current year
#  regents.csv - regents scores, along with student ID, from prior year
#The program expects there to be a header row in the data files
#The column headers can be anything, as long as the first column has ID's and the second has scores.
#The file names can also be whatever you want them to be.

#If prior data is being pulled from multiple years:
#  Predictor and regents scores get matched by student ID
#  If the same student took both the predictor and the regents in both prior years, there will be problems.
#  To avoid issues, append some letter to all student ID's in 1.csv and regents.csv for one of the years
#  Then combine the 1.csv and regents.csv for the two years


#Load the required libraries and other source code
#The file "functions.R" actually just includes commands to load other libraries and source files
source("functions.R")


#The following is the function that runs on the server side
shinyServer(function(input, output) {
  
  print("running shinyServer")
  
  #This converts the selected confidence interval from ui drop down into a end points of the confidence interval
  ConfPoints = reactive({ 
    switch(input$alphaLevel,      #"switch" acts as a lookup, converting the selected confidence level into a pair of numbers
           "90%" = c(11,191),
           "95%" = c(6,196),
           "99%" = c(2,200)) #note that there are 201 elements in the vector, so 200 corresponds to the .995 quantile
  }) #end of function to define ConfPoints
  
  
  #Create variables to hold the inputs
  d1.in = reactive({input$d1})
  d2.in = reactive({input$d2})
  regents.in = reactive({input$regents})
  
  
  #Calculate the possible pass rates.  
  #This will run once when all three files are uploaded
  #It will run again each a new file is uploaded
  PassRates <- reactive({
    print("running PassRates function")
    
    if(is.null(d1.in())){return("")}            #wait until the files are loaded
    if(is.null(d2.in())){return("")}            #wait until the files are loaded
    if(is.null(regents.in())){return("")}       #wait until the files are loaded
    
    d1 = read.csv(d1.in()$datapath)             #Read in the prior year predictor
    d2 = read.csv(d2.in()$datapath)             #Read in the new data
    regents = read.csv(regents.in()$datapath)   #Read in the prior regents scores
    
    list[d1, d2] <- CleanData(d1, d2, regents)  #Clean up the data
    
    GetSuccessRates(d1,d2)                      #get the pass rates and return them
  }) #end of function to define PassRates
  
  
  
  #Set the upper and lower bounds of the confidence interval
  #This will run each time PassRates are calculated, or ConfPoints is changed
  CI = reactive({quantile(PassRates(), probs = seq(0,1,.005), names = F)[ConfPoints()]*100})
  
  output$response = reactive({    
    
    print("running reactive function to get output$response")
    
    if(is.null(d1.in())){return("")}            #wait until the files are loaded
    if(is.null(d2.in())){return("")}            #wait until the files are loaded
    if(is.null(regents.in())){return("")}       #wait until the files are loaded
    
    paste0(c("If all students take the ", 
             input$testName, " regents, ",                                                 #The "testName" component of the "input" object holds the title of the test, as typed in by the user
             "I predict a pass rate of  ", 
             round(mean(PassRates())*100), "%.  ",           #This shows the average pass rate across all the simulations
             "I am ", input$alphaLevel , 
             " sure that the pass rate will be between ",      #This shows the confidence level selected by the user
             as.character(round(CI()[1])), "% and ", 
             as.character(round(CI()[2])), "%."),  #This pulls the upper and lower bounds of the confidence interval
           collapse = "")                                                                  #This says to put the text together with nothing separating the parts
    
  }) #end of reactive function defining output$response
  
  
  
  output$Sample1 <- downloadHandler(
    filename = "SampleOldPredictor.csv",
    content = function(file) {write.csv(Sample1, row.names = FALSE, file)}
  )
  
  output$Sample2 <- downloadHandler(
    filename = "SampleNewPredictor.csv",
    content = function(file) {write.csv(Sample2, row.names = FALSE, file)}
  )
  
  output$Sample3 <- downloadHandler(
    filename = "SampleRegents.csv",
    content = function(file) {write.csv(Sample3, row.names = FALSE, file)}
  )
  
}) #end of shinyServer