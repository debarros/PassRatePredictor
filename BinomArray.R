#BinomArray.R

#This function generates a 3 dimensional array of binomial simulations
#It takes 3 arguments
#  sims = the number of simulations to be run.  This determines the number of "planes" in the resulting array
#  prob.matrix = a matrix of probabilities.  The (i,j) entry is used as the parameter for the simulation of the (i,j,k) entries for k = 1:sims
#  size = the size parameter of the rbinom call.  It is a single positive integer.

#The output (sim.array) is a 3-D array.  
#The columns and rows correspond to the columns and rows of prob.matrix.  
#Each plane corresponds to a simulation using the entire prob.matrix

rbinom.A = function(sims = 1, prob.matrix, size=1){
  print("doing a simulation")
  #Create the array by applying rbinom to each entry in the matrix
  sim.array = apply(X = prob.matrix, MARGIN = c(1,2), FUN = rbinom, n = sims, size = size)  
  
  #reorganize the array so that the first two dimensions correspond to the dimensions of sim.array, and the third corresponds to the simulations
  sim.array = aperm(a = sim.array, perm = c(2, 3, 1)) 

  #Keep the names of the first two dimensions, and add "Simulations" as the name of the third dimension
  names(dimnames(sim.array)) = c(names(dimnames(sim.array)[1:2]),"Simulations")
  
  #Return the result
  return(sim.array)
}