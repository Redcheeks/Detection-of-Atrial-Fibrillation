classdef AFibDetector_Issamp
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold;
        window
    end
    
    methods
        function [obj, pcvVector] = AFibDetector_PCV(DataVector, window)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            obj.window = window;
            obj.threshold = 0;
            
            
            sum_bhat = 0;
            H_sum = 0;
            similarity = -1;
            bhat_actual = 0;
            bhat_tot = 0;
            Issampen_moment = 0;
            Issampen = 0;
            prior_b = 0;
            w_mean = 0;
            
            
            
            for data_set = 1:length(DataVector) %for each training data
                H_sum = 0;


            %sliding window/ for each window position
                for window_start = 0 : DataVector{data_set}.qrs(end)/1000 - (window) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(DataVector{data_set}.qrs>window_start*1000 & DataVector{data_set}.qrs<(window_start+window)*1000);
                    
                    local_rr = DataVector{data_set}.rr(indexes);
                    center_tag = DataVector{data_set}.targetsRR(int64(mean(indexes))); %true/neg value of center of window.
                    
                    S = std(local_rr);
                    m = mean(local_rr);
                    
                    r = w_std*0.4; % placeholder for now, to be replaced with adaptive deviation
                    
                    % --- MAX NORM ---
                    similarity = norm(local_rr,Inf); % returns the infinity norm of X. % TODO borde vara max-norm men osäker på vad det är + implementeringen
                    
                    
                    
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
        function [detectRRVector, pcvVector] = AFibTesting(obj,Data)
            %AFIBTESTING Tests the detector using input DataVector
            %input wants one testdata cell-array
            
            % -------- RUN DETECTOR --------
            
            detectRRVector = zeros(size(Data.targetsRR));
            pcvVector = [];
            
            %sliding window/ for each window position
                for window_start = 0 : Data.qrs(end)/1000 - (obj.window) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(Data.qrs>window_start*1000 & Data.qrs<(window_start+obj.window)*1000);
        
                    local_rr = Data.rr(indexes);
                    
                    S = std(local_rr);
                    m = mean(local_rr);
                    
                    Pcv = S/m;
                    pcvVector(end+1)= Pcv;
                    
                    
                    if(Pcv > obj.threshold)
                        detectRRVector(int64(mean(indexes))) = 1;
                    end
                      
                end
      
            
        end
       end

end

