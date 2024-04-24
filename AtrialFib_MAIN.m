%% Import Training Data
clear all;

AFDB1 = load('AF_RR_intervals/afdb_1.mat');
DataVector{1} = AFDB1;
AFDB2 = load('AF_RR_intervals/afdb_2.mat');
DataVector{2} = AFDB2;
AFDB3 = load('AF_RR_intervals/afdb_3.mat');
DataVector{3} = AFDB3;
AFDB4 = load('AF_RR_intervals/afdb_4.mat');
DataVector{4} = AFDB4;
AFDB5 = load('AF_RR_intervals/afdb_5.mat');
DataVector{5} = AFDB5;
AFDB6 = load('AF_RR_intervals/afdb_6.mat');
DataVector{6} = AFDB6;
AFDB7 = load('AF_RR_intervals/afdb_7.mat');
DataVector{7} = AFDB7;

%% Visualize data

figure(1)
plot(AFDB1.rr, 'b')
hold on;

for iter = 1:size((AFDB1.targetsRR),2)
    if(AFDB1.targetsRR(iter) == 1)
        plot(iter,0, 'r')
    end
        
end

%% Run PCV detector and evaluate

% Create Detector with training data;
window = 5; %in seconds
AFDetector_PCV = AFibDetector([AFDB1,AFDB2, AFDB3, AFDB4], window);

FeatureSelection(AFDetector_PCV, features, window)
% Test detector with all the data;


OutputRR = {1:7};

for j = 1:7 
  OutputRR{j} = AFibTesting(AFDetector_PCV,DataVector{j});
end


%% Evaluate


