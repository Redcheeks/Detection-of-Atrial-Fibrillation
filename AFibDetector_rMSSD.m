classdef AFibDetector_rMSSD
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold;
        window;
    end
    
    methods
        function [obj, rmssdVector] = AFibDetector_rMSSD(DataVector, window)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            obj.window = window;
            obj.threshold = 0;
            
            rmssd_true = [];
            rmssd_false = [];
            rmssdVector = cell(4);
            
            for data_set = 1:length(DataVector) %for each training data
%             figure
%             hold on;
            %sliding window/ for each window position
                for window_start = 0 : DataVector{data_set}.qrs(end)/1000 - (window) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(DataVector{data_set}.qrs>window_start*1000 & DataVector{data_set}.qrs<(window_start+window)*1000);
        
                    local_rr = DataVector{data_set}.rr(indexes);
                    center_tag = DataVector{data_set}.targetsRR(int64(mean(indexes))); %true/neg value of center of window.
                    
                    delta_rrsqrd = diff(local_rr).^2;
                    rmssd = sqrt(mean(delta_rrsqrd));
                    
                    rmssdVector{data_set}(end+1)= rmssd;
                    
                    %plot(int64(mean(indexes)), Pcv, '*')
                    
                    if(center_tag)
                        rmssd_true(end + 1) = rmssd;
                    else
                        rmssd_false(end + 1) = rmssd;
                    end
                    
                end
                
            end
           
            figure();
            histogram(rmssd_true);
            hold on
            histogram(rmssd_false);
            legend('AF', 'no AF');
            title('rMSSD value for different data')
            ylabel('Frequency');
            xlabel('rMSSD');
        end
        %% Feature Selection / Threshold
        function feats = FeatureSelection(obj, thresh)
            % Feature Selection.
            % 
            
            
            obj.threshold = thresh;
        end
        
        
        %% Detector Testing - returns detectedRR
        function [detectRRVector, rmssdVector] = AFibTesting(obj,Data)
            %AFIBTESTING Tests the detector using input DataVector
            %input wants one testdata cell-array
            
            % -------- RUN DETECTOR --------
            
            detectRRVector = zeros(size(Data.targetsRR));
            rmssdVector = [];
            
            %sliding window/ for each window position
                for window_start = 0 : Data.qrs(end)/1000 - (obj.window) %end window before data ends
                
                    %for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(Data.qrs>window_start*1000 & Data.qrs<(window_start+obj.window)*1000);
        
                    local_rr = Data.rr(indexes);
                    
                    delta_rrsqrd = diff(local_rr).^2;
                    rmssd = sqrt(mean(delta_rrsqrd));

                    rmssdVector(end+1)= rmssd;
                    
                    
                    if(rmssd > obj.threshold)
                        detectRRVector(int64(mean(indexes))) = 1;
                    end
                      
                end
      
            
        end
       end

end

