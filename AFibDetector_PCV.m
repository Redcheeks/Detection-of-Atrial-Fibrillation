classdef AFibDetector_PCV
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold = 0;
        window
    end
    
    methods
        function obj = AFibDetector_PCV(DataVector, window)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            obj.window = window;
            
            pcv_true = [];
            pcv_false = [];
            
            
            for data_set = 1:length(DataVector) %for each training data
%             figure
%             hold on;
            %sliding window/ for each window position
                for window_start = 0 : 9000/(window-1) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(DataVector{data_set}.qrs>window_start*1000 & DataVector{data_set}.qrs<(window_start+window)*1000);
        
                    local_rr = DataVector{data_set}.rr(indexes);
                    center_tag = DataVector{data_set}.targetsRR(int64(mean(indexes))); %true/neg value of center of window.
                    
                    S = std(local_rr);
                    m = mean(local_rr);
                    
                    Pcv = S/m;
                    %plot(int64(mean(indexes)), Pcv, '*')
                    
                    if(center_tag)
                        pcv_true(end + 1) = Pcv;
                    else
                        pcv_false(end + 1) = Pcv;
                    end
                    
                end
                
            end
           
            figure();
            histogram(pcv_true);
            hold on
            histogram(pcv_false);
            legend('Fib', 'no fib');
            
        end
        %% Feature Selection / Threshold
        function feats = FeatureSelection(obj, thresh)
            % Feature Selection.
            % 
            
            
            obj.threshold = thresh;
        end
        
        
        %% Detector Testing - returns detectedRR
        function detectRRVector = AFibTesting(obj,Data)
            %AFIBTESTING Tests the detector using input DataVector
            %   
            
            % -------- RUN DETECTOR --------
            detectRRVector = Data.targetsRR;
            
        end
            end

end

