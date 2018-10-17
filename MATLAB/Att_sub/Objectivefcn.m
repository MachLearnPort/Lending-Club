function [f] = Objectivefcn(x, header, Map, ScolO, mu, sigma, P_vars, X0, PW) %Need to make sure this function is the same as the anonymous call in the Ga
%   NOTE: the A, R, S variables do not play a role in this operation, and
%   should be removed

%Create the input file for candidate 4 with the revisions from the GA
X=X0;
for i=1:size(P_vars,2) %For loop changes only X values considered in the 
    X(P_vars(i))=x(i);
end

% Prediction inject - only use when predicting

% Generate input.csv file
inputT(X, header, Map, ScolO, PW);

% Run h2o R-scripts to extract objective function TPO features
dos('"C:\Program Files\R\R-3.4.0\bin\x64\Rscript" "D:\Users\Jeff\Google Drive\Tailored Process Optimization\TPO\HR_Project\HR_IBM_SR\R_master.r"')

% Read generated Prediction Values - ** change file name inside
[Pred_V, A] = read(PW);

% Feature Normalization - Normalized about 1
for i=1:size(Pred_V,1)
    Pred_VN(:,i)=1+((Pred_V(i)-mu(i))/sigma(i)); %**** Verify Sigma and MU are in the same order as Pred_VN
end

%Extract normailzed value
A_n=abs(Pred_VN(1,1));

% TPO function
f=A_n; %TPO function for optimizing A

toc;
end