%TPO - for IBM HR Dataset
%SUBPROCESS - Optimize candidate performance
%By: Jeff Schwartzentruber
% NOTE: Before executing, change PW to be the directory of HR_IBM folder,
% and make simialar change in the R-script that runs the ML models
clear;
clc;
close;
PW='D:\Users\Jeff\Google Drive\Tailored Process Optimization\TPO\HR_Project\HR_IBM_SR\';
clear_output(PW); %Clear all previous results from output folder to not disrupt the post processing
tic;

%% Declare Variables
Pop_size=30;
Gen_size=20;

%% Import dataset (or partial datset) and parse ** Change filename inside
% This function imports the total cleaned CSV file (called inside
% function). Afterwhich, it parses and codes and string structures into
% numeric (so that it can run with the GA) and outputs the a complete
% numeric dataset (X_map), the map to decode the mapping, the columns that
% had strings, along with the header of the dataset. Final output is the
% strcture in array form (X_MAP)

%*** This is not optimized, currently loading whole dataset when only 1
%line is needed, and the uppper and lower bounds extracted from the base
%line run. Fix in future releases

[X, header, Map, X_map, Scol, X_MAP] = importdata(PW);

%% Feature normalization
% get the mean and standard dev for later use before the cost function comp
% Needed step, so that each var gets viewed equally, until the weight start
% to play a role

[mu, sigma] = Feat_Norm(X_MAP);

%% GA - For providing recomendation on how to improve and employees performance
% Select candidate to optimize performance *NOTE: Could loop through and
% do all employees and generate a tailored action plan for each one
C_no=4; %Select candidate number 4 to perform optimization on
X0=X_MAP(end-1,:); %Select mmost sever candidate (at the bottom of the ranking)

%Devleop an attrition (X2) improvement plan based on the top five factors
%(that are varible) of the GBM analysis:
%X20: OverTime
%X3: Business Travel
%X17: Monthly income
%X1: Age <Not able to change>
%X16: Marital Status <not able to change>
% Plus the others
%With the objective to increase performance whistl mitigating costs (i.e.
%trade off between stock and salary hike and performance)

P_vars=[20, 3, 27]; %X vars being optimized
ScolO=(Scol(Scol~=0))'; %For keeping interger values in the GA
ScolOI=[1, 2]; %Set interger values for optimization of overtime and Buiness travel (indices of P_vars

% Create upper and lower bounds
LB=zeros(1,size(P_vars,2));
UB=zeros(1,size(P_vars,2));
for i=1:size(P_vars,2)
    LB(1,i)=min(X_MAP(:,P_vars(i)));
    UB(1,i)=max(X_MAP(:,P_vars(i)));
end

count=0; %Initalize count
fitval=100; %Initlaize

%Output function saves the state of the simualtion, so that later we can
%conduct post processing
options=gaoptimset('PopulationSize',Pop_size,'Generations',Gen_size,'Display','iter','PlotFcns', {@gaplotbestf,@gaplotmaxconstr,@gaplotscorediversity,@gaplotscores},'TolFun',1e-4, 'OutputFcns', @outputfcn);%,'InitialPopulation',X0);

% GA notes:
% Used modified anonmoyus function call to pass header and X_rec to GA
% Last bracket is IntCon, which holds those indicies in the x interger and is
% based on the Scol output
DB_stop=1;
[x,fval,output] = ga(@(x)Objectivefcn(x, header, Map, ScolO, mu, sigma, P_vars, X0, PW),length(LB),[],[],[],[],LB,UB,[], [ScolOI], options)

[X_rec, Y_rec] = postProcess(Gen_size, PW);

%Determin optimal index
[M, I]=min(Y_rec);
X_opt=X_rec(I,:); %Isolate optimal config

% Extract the ranking array
[Rank_score]=Cust_var(X_MAP, X_opt);
