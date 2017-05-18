#Automated.R

# This allows a user to select a folder that contains folders that contain the relevant input CSV's
# Relevant folders are identified, the simulations are run, and the resulting predictions are saved in each folder

StorePredictions = function(yearFolder = choose.dir()){
  subFolders = list.dirs(yearFolder)
  useFolders = vector(mode = "character")
  requiredFiles = c("1.csv","2.csv","regents.csv")
  for(i in subFolders){
    thesefiles = list.files(i)
    if(all(requiredFiles %in% thesefiles)){
      useFolders = c(useFolders, i)
    }
  }
  
  for(i in useFolders){
    print(i)
    d1 = read.csv(paste0(i,"/1.csv"))             #Read in the prior year predictor
    d2 = read.csv(paste0(i,"/2.csv"))             #Read in the new data
    regents = read.csv(paste0(i,"/regents.csv"))   #Read in the prior regents scores
    
    list[d1, d2] <- CleanData(d1[,c(1,3)], d2[,c(1,3)], regents[,c(1,3)])  #Clean up the data
    
    PassRates <- GetSuccessRates(d1,d2) #get the pass rates and return them
    
    ConfPointSet = list("90%" = c(11,191),"95%" = c(6,196),"99%" = c(2,200))
    ConfChoice = 2
    ConfPoints = ConfPointSet[[ConfChoice]]
    alphaLevel = names(ConfPointSet)[[ConfChoice]]
    
    CI = quantile(PassRates, probs = seq(0,1,.005), names = F)[ConfPoints]*100
    
    outSent = OutputSentence(testName = "",PassRates,alphaLevel,CI)
    
    fileConn <- file(paste0(i,"/output.txt"))
    writeLines(outSent, fileConn)
    close(fileConn)
    
  } # /for
}