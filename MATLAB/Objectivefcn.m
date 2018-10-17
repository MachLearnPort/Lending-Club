function [f] = Objectivefcn(x, header, Map, ScolO, mu, sigma, PW) %Need to make sure this function is the same as the anonymous call in the Ga

% Generate input.csv file
inputT(x, header, Map, ScolO, PW);

% CHANGE BETWEEN SYSTEMS
% Run h2o R-scripts to extract objective function TPO features
dos('"C:\Program Files\R\R-3.4.0\bin\x64\Rscript" "D:\Users\Jeff\Google Drive\Tailored Process Optimization\TPO\HR_Project\HR_IBM_SR\R_master.r"')

% Read generated Prediction Values - ** change file name inside
[Pred_V, A] = read(PW);

% Feature Normalization - Normalized about 1
for i=1:size(Pred_V,1)
    Pred_VN(:,i)=1+((Pred_V(i)-mu(i))/sigma(i)); %**** Verify Sigma and MU are in the same order as Pred_VN
end

%Extract the normailzed values from Pred_vN
A_n=abs(Pred_VN(1,1));

%Initalize/Set Policy Weights
W1=1; %Policy weight on Attrition

% TPO function
f=W1*A_n; %TPO function for optimizing A

toc;
end