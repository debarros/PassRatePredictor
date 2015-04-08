GetSuccessRates = function(d1,d2){
  
  #Create the model
  model1 = glm(Passed ~ Score, family=binomial(logit), data=d1)
  
  rvModel = posterior(model1)
  x = c(rvModel[[1]][[1]],rvModel[[1]][[2]])
  rvCoeffs = array(data = x, dim = c(2,length(x)/2))
  
  #Compute the pass rate for the new group
  Coeffs = coefficients(model1)
  new.probs <- plogis(Coeffs[1] + Coeffs[2]*d2$Score)
  
  rv.new.probs = plogis(rvCoeffs[1,] + tcrossprod(rvCoeffs[2,], d2$Score))
  
  print(3)
  #Use random simulation to get the confidence interval
  x = matrix(nrow = 1000, ncol = length(new.probs))
  for(i in 1:length(new.probs)){
    x[,i] = rbinom(1000,1,new.probs[i])
  }
  
  print(4)
  PassRates = numeric()
  for (i in 1:1000){
    PassRates[i] = mean(x[i,])  
  }
  print(5)
  returner = list(PassRates,new.probs)
  return(returner)
}