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
plot(AFDB3.rr(find(AFDB3.targetsRR == 1)), 'r')
plot(AFDB3.rr(find(AFDB3.targetsRR == 0)), 'b')
hold on;

% for iter = 1:size((AFDB3.targetsRR),2)
%     if(AFDB3.targetsRR(iter) == 1)
%         plot(iter,AFDB3.rr(iter), 'r*')
%     else
%         plot(iter,AFDB3.rr(iter), 'b')
%     end
%         
% end

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


%% Evaluate - draw figures of results and threshold.

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

%% Performance measure  - table output

FN_tot = cell(length(TestVector),1);
FP_tot = cell(length(TestVector),1);
TN_tot = cell(length(TestVector),1);
TP_tot = cell(length(TestVector),1);
performance = cell([length(TestVector)+1, 2]); % Sensitivity for first col and specificity for second col

for set_nbr = 1 : length(OutputRR) 
    
    diff = TestVector{set_nbr}.targetsRR - OutputRR{set_nbr};
    
    FN_tot{set_nbr} = sum(diff>0, 'all');
    FP_tot{set_nbr} = sum(diff<0, 'all');
    TN_tot{set_nbr} = sum(OutputRR{set_nbr} == 0) - FN_tot{set_nbr};
    TP_tot{set_nbr} = sum(OutputRR{set_nbr} == 1) - FP_tot{set_nbr};
    
    performance{set_nbr, 1} = TP_tot{set_nbr} ./ (TP_tot{set_nbr} + FN_tot{set_nbr}); % Sensitivity
    performance{set_nbr, 2} = TN_tot{set_nbr} ./ (FP_tot{set_nbr} + TN_tot{set_nbr}); % Specificity
end

performance{end, 1} = sum(cell2mat(TP_tot)) / (sum(cell2mat(TP_tot)) + sum(cell2mat(FN_tot))); % Avg sensitivity
performance{end, 2} = sum(cell2mat(TN_tot)) / (sum(cell2mat(FP_tot)) + sum(cell2mat(TN_tot))); % Avg specificity

% Sensitivity = TP / (TP + FN)
% Specificity = TN / (FP + TN)

Data_set = ["Patient 1"; "Patient 2"; "Patient 3"; "Patient 4"; "Patient 5"; "Patient 6"; "Patient 7"; "Average"];
Sensitivity = performance(:, 1);
Specificity = performance(:, 2);
pcv_results = table(Data_set, Sensitivity, Specificity);

