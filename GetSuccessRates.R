GetSuccessRates = function(d1,d2){

  print("running GetSuccessRates")
    
  #Create the model
  #model1 holds the mathematical model
  #the "glm" function creates a general linear model
  #"Passed ~ Score" defines the model, saying that we want to model Passed (whether the student passed the regents) using "Score" (the score on the predictor test)
  #"logit" refers to the fact that this is logistic regression
  #"data=d1" tells glm to use the data in the "d1" object, which has the predictor scores, regents scores, and pass indicator
  model1 = glm(Passed ~ Score, family=binomial(logit), data=d1)
  
  
  #Next, we want to account for the fact that the model might not be perfect
  #"posterior" is a function in the "rv" package.  It creates simulated posterior distributions of the model parameters.
  #Basically, "posterior" switches the model from a point prediction to something that represents our uncertainty
  #The coefficients in the "rvModel" are treated as random variables whose means are the point estimates from the simple model
  rvModel = posterior(model1)
  
  
  
  #Now we need to get the coefficients from the model
  #This creates a matrix with 2 rows and 4,000 columns
  #The first row is the intercept coefficient; the second is the variable coefficient
  #Each column is a different model
  rvCoeffs = rbind(rvModel$beta[[1]], rvModel$beta[[2]])
  dimnames(rvCoeffs) = list("Coefficients" = NULL, "Models" = NULL)
  
  
  
  #Create a matrix to hold the predictor data
  #This creates a matrix with 2 rows and n columns
  #The first row is 1 (so that the intercept coefficient can be brought it unchanged)
  #The second row is the predictor variable value
  #Each column is a different student
  predictor = rbind(1, d2$Score)
  dimnames(predictor) = list("Variables" = NULL, "Students" = NULL)
  
  
  #find the log odds for each student under each model
  logOdds = crossprod2(rvCoeffs, predictor)
  
  
  #Convert log odds to probabilities
  probabilities = plogis(logOdds)
  #The "plogis" is the inverse of the logit (log odds) function
  #plogis(x) = 1/(1+exp(-x))
  #logit(x) = ln(x/(1-x))
  #plogis takes values between -infinity and +infinity and squishes them into the interval [0,1]
  #logit takes probabilities in the interval [0,1] and spreads them out over all real numbers
  
  
  
  #Create a set of 100 simulations of the new regents for each variant of the model
  sim.array = rbinom.A(sims = 100, prob.matrix = probabilities)
  #The "rbinom.A" function basically performs coin flips for each entry in the probability matrix
  #The "sims = 100" paramater means that it creates 100 matrices of simulated results, 
  #  each of which has one outcome for each student for each model
  #Since rv's posterior function generates 4000 samples of the parameters, 
  #    there are 4000 models, and 400,000 simulations, for each student
  
  #Next, get the pass rate for each simulation
  PassRates = apply(X = sim.array, MARGIN =c(1,3), FUN = mean)
  #This averages across all students within a particular simulation of a partiocular model, which gives that pass rate
  #The "passRates" object is therefore a 100x4000 matrix of possible pass rates
  
  return(as.vector(PassRates)) #return the passRates
}