%TPO - for IBM HR Dataset
%By: Jeff Schwartzentruber
% NOTE: Before executing, change PW to be the directory of HR_IBM folder,
% and make simialar change in the R-script that runs the ML models
clear;
clc;
close;
PW='D:\Users\Jeff\Google Drive\Tailored Process Optimization\TPO\Lending_Club\';
clear_output(PW); %Clear all previous results from output folder to not disrupt the post processing
tic;


%% Declare Variables
Pop_size=60;
Gen_size=30;

%% Import dataset (or partial datset) and parse ** Change filename inside
% This function imports the total cleaned CSV file (called inside
% function). Afterwhich, it parses and codes and string structures into
% numeric (so that it can run with the GA) and outputs the a complete
% numeric dataset (X_map), the map to decode the mapping, the columns that
% had strings, along with the header of the dataset. Final output is the
% strcture in array form (X_MAP)

[X, header, Map, X_map, Scol, X_MAP] = importdata(PW);

%% Feature normalization
% get the mean and standard dev for later use before the cost function comp
% Needed step, so that each var gets viewed equally, until the weight start
% to play a role

[mu, sigma] = Feat_Norm(X_MAP);


%% GA - Determining Baseline best for ranking
% Initalize random row from X_MAP to act as starting point
ind = ceil(rand * size(X_MAP,1));
X0 = X_MAP(ind,:); %Inital population array if need
ScolO=(Scol(Scol~=0))'; %For keeping interger values in the GA

% Create upper and lower bounds
LB=zeros(1,size(X_MAP,2));
UB=zeros(1,size(X_MAP,2));
for i=1:size(X_MAP,2)
    LB(1,i)=min(X_MAP(:,i));
    UB(1,i)=max(X_MAP(:,i));
end
count=0; %Initalize count
fitval=100; %Initlaize

%Output function saves the state of the simualtion, so that later we can
%conduct post processing
options=gaoptimset('PopulationSize',Pop_size,'Generations',Gen_size,'Display','iter','PlotFcns', {@gaplotbestf,@gaplotmaxconstr,@gaplotscorediversity,@gaplotscores},'TolFun',1e-4, 'OutputFcns', @outputfcn);%,'InitialPopulation',X0);

% GA notes:
% Used modified anonmoyus function call to pass header and X_rec to GA
% Last bract is IntCon, which holds those indicies in the x interger and is
% based on the Scol output

[x,fval,output] = ga(@(x)Objectivefcn(x, header, Map, ScolO, mu, sigma, PW),length(LB),[],[],[],[],LB,UB,[],[ScolO],options)

[X_rec, Y_rec] = postProcess(Gen_size, PW);

%Determin optimal index
[M, I]=min(Y_rec);
X_opt=X_rec(I,:); %Isolate optimal config

% Extract the ranking array
[Rank_score]=Cust_var(X_MAP, X_opt);
