#CleanData.R

CleanData = function(d1, d2, regents){
  
  print("running CleanData")
  
  #Rename the columns
  #This will make the data easier to merge
  colnames(d1) = c("StudNum","Score")
  colnames(d2) = c("StudNum","Score")
  colnames(regents) = c("StudNum","Score")
  
  
  #Match the regents scores with the predictor scores
  #This would be better done using the "match()" function, but I didn't know it when I originally wrote this section of code
  for (i in 1:nrow(d1)){                                                     #For each score in the old predictor scores files,
    if (d1$StudNum[i] %in% regents$StudNum){                                 #if this student has an outcome score in the regents file,
      d1$Regents[i] = regents$Score[which(regents$StudNum == d1$StudNum[i])] #put the outcome score in that row, pairing it with the predictor score.
    }else{                                                                   #If the student does not have an outcome score in the regents file,
      d1$Regents[i] = NA                                                     #put NA in that row to indicate that the student's regents score is missing.
    }
    d1$drop[i] = sum(is.na(d1[i,])) #Indicate whether the row should be dropped.  Any row with NA for the student ID, predictor score, or regents score will be dropped.
  } #end of for loop
  
  
  #Get rid of the missing data rows in the predictor-regents score pairings
  #This section will be eliminated once the procedure for handling missing data is implemented
  #In d1, the "drop" variable indicates whether it should be kept (0) or dropped (>0)
  d1 = d1[which(d1$drop == 0),]         #Subset d1 to only the rows with complete data
  
  
  #In case there are extra empty rows at the bottom of the new predictor score file, those should be identified and eliminated
  #This is not an elimination of missing data; it's just cleaning up a messy file
  d2$drop = is.na(d2$StudNum)           #In d2, the drop variable indicates whether the row includes actual data 
  d2 = d2[which(d2$drop == FALSE),]     #Subset d2 to only those rows that have a student number
  
  
  #Create the "Passed" variable in d1
  #This is a variable that indicates whether the student passed the regents
  #0 indicates failed, 1 indicates passed
  d1$Passed = 0                           #set the default value to fail
  d1$Passed[which(d1$Regents >= 65)] = 1  #For the students with regents scores of least 65, set "Passed" to 1 
  #Note: this will need to be ">= PassCutoff" rather than ">=65", after PassCutoff is defined
  
  return(list(d1, d2))
}
