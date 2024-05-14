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
for data = 1:2
    
index_change = [1];
temp = TrainingVector{data}.targetsRR(1);
colortmp = ['b', 'r']; % I think we always start with Non-AF?
for iter = 1:length(TrainingVector{data}.rr)
    if(TrainingVector{data}.targetsRR(iter) == temp)
    else
        temp = TrainingVector{data}.targetsRR(iter); %current state
        index_change(end+1) =  iter; %Save index where target changes
        colortmp(end+1) = colortmp(end-1); %add change in color.
    end  
end
index_change(end+1) = length(TrainingVector{data}.rr); % End index

subplot(2,1,data)
hold on;
for j = 1:(length(index_change)-1)
    plot(index_change(j):index_change(j+1),TrainingVector{data}.rr(index_change(j):index_change(j+1)), colortmp(j))
end


title ('Patient ' + string(data))
ylabel('RR interval');
xlabel('Time');
legend('Non-AF','AF');

end
%%
figure(2)
clf
for data = 3:4
    
index_change = [1];
temp = TrainingVector{data}.targetsRR(1);
colortmp = ['b', 'r']; % I think we always start with Non-AF?
for iter = 1:length(TrainingVector{data}.rr)
    if(TrainingVector{data}.targetsRR(iter) == temp)
    else
        temp = TrainingVector{data}.targetsRR(iter); %current state
        index_change(end+1) =  iter; %Save index where target changes
        colortmp(end+1) = colortmp(end-1); %add change in color.
    end  
end
index_change(end+1) = length(TrainingVector{data}.rr); % End index

subplot(2,1,data-2)
hold on;
for j = 1:(length(index_change)-1)
    plot(index_change(j):index_change(j+1),TrainingVector{data}.rr(index_change(j):index_change(j+1)), colortmp(j))
end


title ('Patient ' + string(data))
ylabel('RR interval');
xlabel('Time');
legend('Non-AF','AF');

end
%% Run PCV detector

% Create Detector with training data;
window = 10; % in seconds
[AFDetector_PCV, PcvVector] = AFibDetector_PCV(TrainingVector, window);


%manually evaluate histogram and choose threshold
threshold = 0.2;

FeatureSelection(AFDetector_PCV, threshold);



%% Test detector with testing data, Pcv;

OutputRR = cell(length(TestVector),1); %contains [detectRRVector, pcvVector] for each data_set
OutPcv = cell(length(TestVector),1);

for j = 1:length(TestVector)
  [OutputRR{j}, OutPcv{j}] = AFibTesting(AFDetector_PCV,TestVector{j});
end


%% Evaluate Pcv - draw figures of results and threshold.

figure(3);
clf
for i = 1:length(TrainingVector)
    ax(i) = subplot(2,2,i);
    
    % Splitting data to AF and non AF
    AF_red = PcvVector{i}; 
    AF_red(AF_red<threshold) = threshold; % classified as non-AF
    AF_blue = PcvVector{i};
    AF_blue(AF_blue>threshold) = threshold; % classified as AF
    plot(AF_blue, 'b-')
    hold on
    plot(AF_red,'r-')

%     plot(PcvVector{i}, 'b-')
%     hold on;
%     x = linspace(0, ceil(TrainingVector{i}.qrs(end)./1000), length(TrainingVector{i}.targetsQRS));
%     plot(x,TrainingVector{i}.targetsQRS*0.2, 'r-');
    yline(threshold, 'k-.','LineWidth',1.5);
    ylim([0 0.5])
    xlabel('Time s');
    ylabel('P_{cv} value');
    title('Training Set ' + string(i))
end
linkaxes(ax,'xy')
legend('Pcv value', 'DetectRR', 'Threshold');
xlabel('Time s');
ylabel('P_{cv} value');


figure(4);
clf
for i = 5:length(TestVector)   
    ax(i) = subplot(2,2,i-4);
    
    % Splitting data to AF and non AF
    AF_red = OutPcv{i}; 
    AF_red(AF_red<threshold) = threshold; % classified as non-AF
    AF_blue = OutPcv{i};
    AF_blue(AF_blue>threshold) = threshold; % classified as AF
    plot(AF_blue, 'b-')
    hold on
    plot(AF_red,'r-')


%     plot(OutPcv{i}, 'b-')
%     hold on;
%     x = linspace(0, ceil(TestVector{i}.qrs(end)./1000), length(TestVector{i}.targetsQRS));
%     plot(x,TestVector{i}.targetsQRS*0.2, 'r-');
    yline(threshold, 'k-.','LineWidth',1.5);
    ylim([0 0.5])
    xlabel('Time s');
    ylabel('P_{cv} value');
    title('Testing Set ' + string(i-4))
end
linkaxes(ax,'xy')
legend('Pcv value', 'DetectRR', 'Threshold');
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
% Accuracy = (TP + FN) / (TP + TN + FP + FN)
Accuracy = (TP_tot + FN_tot) / (TP_tot + TN_tot + FP_tot + FN_tot)

Data_set = ["Patient 1"; "Patient 2"; "Patient 3"; "Patient 4"; "Patient 5"; "Patient 6"; "Patient 7"; "Average"];
Sensitivity = performance(:, 1);
Specificity = performance(:, 2);
pcv_results = table(Data_set, Sensitivity, Specificity);

%% Run Shannon detector, fungerar ej

% Create Detector with training data;
window = 100; %in beats
[AFDetector_SampEn, SampEnVector] = AFibDetector_shannon(TrainingVector, window);




FeatureSelection(AFDetector_SampEn, threshold);

%% SVM feats extraction
window = 10; %in seconds
% featVector = cell(35960,7);
svm_featVector = {};
svm_label = [];
[AFDetector_svm, svm_featVector, svm_label] = AFibDetector_SVM_feats(TrainingVector, window, svm_featVector, svm_label);
writetable(svm_featVector, 'mat_feats_table.csv', 'WriteVariableNames', false) % used in separate code in python
writematrix(transpose(svm_label), 'mat_labels.csv')

svm_featVector2 = {};
svm_label2 = [];
actualtest = {AFDB5, AFDB6, AFDB7};

[AFDetector_svm, svm_featVector2, svm_label2] = AFibDetector_SVM_feats(actualtest, window, svm_featVector2, svm_label2);
writetable(svm_featVector2, 'mat_test_feats_table.csv', 'WriteVariableNames', false) % used in separate code in python
writematrix(transpose(svm_label2), 'mat_test_labels.csv')

