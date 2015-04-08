# PassRatePredictor
Use simulations based on logisitic regression to predict the pass rate of a group

This `shiny` app does the following:
  1. Builds a logistic regression model based on old predictor and outcome scores
  1. Assigns a outcome pass probability to each new predictor score
  1. Performs 1,000 simulations of the the new group taking the outcome test
  1. Provides and estimate and confidence interval for the percentage of the new group that will pass

During the simulations, each individual is treated as a Bernoulli random variable.
The predictor score can be on any scale.  Hoever, for the outcome score, passing is (currently) considered to be at least 65.
