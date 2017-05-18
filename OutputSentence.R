#OutputSentence.R



OutputSentence = function(testName,PassRates,alphaLevel,CI){
  paste0(c("If all students take the ", 
           testName, " regents, ", 
           "I predict a pass rate of  ", 
           round(mean(PassRates)*100), "%.  ",           #This shows the average pass rate across all the simulations
           "I am ", alphaLevel , 
           " sure that the pass rate will be between ",      #This shows the confidence level selected by the user
           as.character(round(CI[1])), "% and ", 
           as.character(round(CI[2])), "%."),  #This pulls the upper and lower bounds of the confidence interval
         collapse = "") #This says to put the text together with nothing separating the parts
}