#functions.R

library(shiny) 
library(rv)
source("GetSuccessRates.R") #This file contains the code to compute the predicted pass rates
source("list.R")            #this contains code that allows functions to return lists
source("CleanData.R")       #function to clean up the data
source("crossprod2.R")      #function to make matrix multiplication carry over dimension names
source("BinomArray.R")      #function to use a matrix of proabilities to generate a 3-D array of simulations
Sample1 = read.csv("www/SampleOldPredictor.csv")
Sample2 = read.csv("www/SampleNewPredictor.csv") 
Sample3 = read.csv("www/SampleRegents.csv")