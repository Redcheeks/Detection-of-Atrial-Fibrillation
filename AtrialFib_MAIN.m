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
TestVector{1} = TrainingVector{1};
TestVector{2} = TrainingVector{2};
TestVector{3} = TrainingVector{3};
TestVector{4} = TrainingVector{4};

AFDB5 = load('AF_RR_intervals/afdb_5.mat');
TestVector{5} = AFDB5;
AFDB6 = load('AF_RR_intervals/afdb_6.mat');
TestVector{6} = AFDB6;
AFDB7 = load('AF_RR_intervals/afdb_7.mat');
TestVector{7} = AFDB7;

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


OutputRR = cell(length(TestVector),1); %contains [detectRRVector, pcvVector] for each data_set
OutPcv = cell(length(TestVector),1);

for j = 1:length(TestVector) 
    
  [OutputRR{j}, OutPcv{j}] = AFibTesting(AFDetector_PCV,TestVector{j});
end


%% Evaluate

figure(3);
clf
for i = 1:length(TrainingVector)
    ax(i) = subplot(2,2,i);
    
    plot(PcvVector{i}, 'b-')
    hold on;
    x = linspace(0, ceil(TrainingVector{i}.qrs(end)./1000), length(TrainingVector{i}.targetsQRS));
    plot(x,TrainingVector{i}.targetsQRS*0.2, 'r-');
    yline(threshold, 'k-.');
    ylim([0 0.5])
    xlabel('Time s');
    ylabel('P_{cv} value');
    title('Training Set ' + string(i))
end
linkaxes(ax,'xy')
legend('Pcv value', 'TargetRR', 'Threshold');
xlabel('Time s');
ylabel('P_{cv} value');


figure(4);
clf
for i = 5:length(TestVector)   
    ax(i) = subplot(2,2,i-3);
    
    plot(OutPcv{i}, 'b-')
    hold on;
    x = linspace(0, ceil(TestVector{i}.qrs(end)./1000), length(TestVector{i}.targetsQRS));
    plot(x,TestVector{i}.targetsQRS*0.2, 'r-');
    yline(threshold, 'k-.');
    ylim([0 0.5])
    xlabel('Time s');
    ylabel('P_{cv} value');
    title('Testing Set ' + string(i))
end
linkaxes(ax,'xy')
legend('Pcv value', 'TargetRR', 'Threshold');
xlabel('Time s');
ylabel('P_{cv} value');

%% Performance meassure


FN_tot = {};
FP_tot = {};
TN_tot = {};
TP_tot = {};

for set_nbr = 1 : length(OutputRR) 
    curr_dataset = sprintf('AFDB%d', set_nbr) %funkar inte riktigt än
    diff = curr_dataset.targetsRR - OutputRR{set_nbr}
    

    FN_tot(end+1) = sum(diff>0, 'all');
    FP_tot(end+1) = sum(diff<0, 'all');

    TN_tot(end+1) = sum(OutputRR{1} == 0) - FN_tot(set_nbr);
    TP_tot(end+1) = sum(OutputRR{1} == 1) - FP_tot(set_nbr);

end

% fixa sensitivity och specificity i en vektor för performance meassures i
% loopen ovan
Sensitivity = TP / (TP + FN)
Specificity = TN / (FP + TN)


