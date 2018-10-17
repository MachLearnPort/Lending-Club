# TPO R script for Lending Club projects
# By: Jeff Schwartzentruber
# Date: April 29th 2017

PW <- "C:\\Users\\Jeff\\Google Drive\\Tailored Process Optimization\\TPO\\Lending_Club\\"

library(h2o) #Import h2o library (must be installed prior)
localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE,min_mem_size = "3g") #Initalize h2o instance
summarysetwd = PW # set working directory where file repo is

input <- h2o.importFile(path = paste(PW, "input.csv", sep=""), destination_frame = "input") #Load generated predict input.csv file, must be an h2o frame

## Attrition Model - NN
modelPath_A = paste(PW, "Model_Exports\\Attrition_NN_model\\deeplearning-0d64b33e-70e9-415a-8756-e57de66ddfb0", sep="") # Location of the exported model from flow
model_A <- h2o.loadModel(modelPath_A) #Load exported model
pred_A_h2o <- h2o.predict(model_A, input) #Predict with input.csv with generated model
pred_A=as.data.frame(pred_A_h2o) #convert h2o from to r frame
write.table(as.matrix(pred_A), file=paste(PW,"Predictions\\pred_A.csv", sep=""), row.names=FALSE, sep=",")

# h2o.shutdown(prompt = FALSE)  #Turn to TRUE for paralle computing


