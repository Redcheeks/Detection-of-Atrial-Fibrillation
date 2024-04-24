%% Import Training Data
clear all;

AFDB1 = load('AF_RR_intervals/afdb_1.mat');
TrainingVector{1} = AFDB1;
AFDB2 = load('AF_RR_intervals/afdb_2.mat');
TrainingVector{2} = AFDB2;
AFDB3 = load('AF_RR_intervals/afdb_3.mat');
TrainingVector{3} = AFDB3;
AFDB4 = load('AF_RR_intervals/afdb_4.mat');
TrainingVector{4} = AFDB4;
AFDB5 = load('AF_RR_intervals/afdb_5.mat');
TestVector{1} = AFDB5;
AFDB6 = load('AF_RR_intervals/afdb_6.mat');
TestVector{2} = AFDB6;
AFDB7 = load('AF_RR_intervals/afdb_7.mat');
TestVector{3} = AFDB7;

%% Visualize data

figure(1)
clf
plot(AFDB3.rr, 'b')
hold on;

for iter = 1:size((AFDB3.targetsRR),2)
    if(AFDB3.targetsRR(iter) == 1)
        plot(iter,0, 'r*')
    end
        
end

%% Run PCV detector

% Create Detector with training data;
window = 10; %in seconds
[AFDetector_PCV, PcvVector] = AFibDetector_PCV(TrainingVector, window);


%manually evaluate histogram and choose threshold

threshold = 0.2;

FeatureSelection(AFDetector_PCV, threshold);



%% Test detector with testing data;


OutputRR = {length(TestVector)};

for j = 1:length(TestVector) 
  OutputRR{j} = AFibTesting(AFDetector_PCV,TestVector{j});
end


%% Evaluate

figure(3)
clf
for i = 1:length(TrainingVector)
    subplot(2,2,i)
    plot(PcvVector{i}, 'b-')
    hold on;
    x = linspace(0, ceil(TrainingVector{i}.qrs(end)./1000), length(TrainingVector{i}.targetsQRS));
    plot(x,TrainingVector{i}.targetsQRS, 'r-');
    yline(threshold, 'k-.');
end









