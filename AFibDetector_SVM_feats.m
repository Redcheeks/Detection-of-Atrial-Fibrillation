classdef AFibDetector_SVM_feats
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold;
        window
    end
    
    methods
        function [obj, svmVector, label] = AFibDetector_SVM_feats(DataVector, window, svmVector, label)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            obj.window = window;
            obj.threshold = 0;
            
            
            
            
            for data_set = 1:length(DataVector) %for each training data
                %sliding window/ for each window position
                for window_start = 0 : DataVector{data_set}.qrs(end)/1000 - (window) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(DataVector{data_set}.qrs>window_start*1000 & DataVector{data_set}.qrs<(window_start+window)*1000);
        
                    local_rr = DataVector{data_set}.rr(indexes);
                    center_tag = DataVector{data_set}.targetsRR(int64(mean(indexes))); %true/neg value of center of window.
                    
                    minima = min(local_rr); %feat 1
                    maxima = max(local_rr); %feat 2
                    m = mean(local_rr); %feat 3
                    med = median(local_rr); %feat 4
                    S = std(local_rr); %feat 5

                    delta_rrsqrd = diff(local_rr).^2; % help for rmssd
                    rmssd = sqrt(mean(delta_rrsqrd)); %feat 6
                    
                    Pcv = S/m; %feat 7

%                     feats =  num2cell([minima, maxima, m, med, S, rmssd, Pcv]);
%                     svmVector = vertcat(svmVector, feats);

                    feats =  [minima, maxima, m, med, S, rmssd, Pcv];
                    svmVector{end+1} = feats;



                    if(center_tag == 0 )
                        label(end + 1) = 0;
                    else
                        label(end + 1) = 1;
                    end
                    
                end
                
            end
           svmVector = cell2table((transpose(svmVector)));
          
        end
        %% Feature Selection / Threshold
        function feats = FeatureSelection(obj, thresh)
            % Feature Selection.
            % 
            
            
            obj.threshold = thresh;
        end
        
        
        %% Detector Testing - returns detectedRR
        function [detectRRVector, svmVector] = AFibTesting(obj,Data)
            %AFIBTESTING Tests the detector using input DataVector
            %input wants one testdata cell-array
            
            % -------- RUN DETECTOR --------
            
            detectRRVector = zeros(size(Data.targetsRR));
            svmVector = [];
            
            %sliding window/ for each window position
                for window_start = 0 : Data.qrs(end)/1000 - (obj.window) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(Data.qrs>window_start*1000 & Data.qrs<(window_start+obj.window)*1000);
        
                    local_rr = Data.rr(indexes);
                    
                    S = std(local_rr);
                    m = mean(local_rr);
                    
                    Pcv = S/m;
                    svmVector(end+1)= Pcv;
                    
                    
                    if(Pcv > obj.threshold)
                        detectRRVector(int64(mean(indexes))) = 1;
                    end
                      
                end
      
            
        end
       end

end

