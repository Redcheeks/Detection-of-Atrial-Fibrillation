classdef AFibDetector_PCV
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
            
            pcv_true = [];
            pcv_false = [];
            pcvVector = cell(4);
            
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
                    
                    S = std(local_rr);
                    m = mean(local_rr);
                    
                    Pcv = S/m;
                    pcvVector{data_set}(end+1)= Pcv;
                    
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
            legend('AF', 'no AF');
            title('Pcv value for different data')
            ylabel('Frequency');
            xlabel('P_{CV}');

        end
        %% Feature Selection / Threshold
        function feats = FeatureSelection(obj, thresh)
            % Feature Selection.
            % 
            
            
            obj.threshold = thresh;
            feats = obj;
        end
        
        
        %% Detector Testing - returns detectedRR
        function [detectRRVector, pcvVector, trueAF] = AFibTesting(obj,Data)
            %AFIBTESTING Tests the detector using input DataVector
            %input wants one testdata cell-array
            
            % -------- RUN DETECTOR --------
            
            detectRRVector = zeros(size(Data.targetsRR));
            pcvVector = [];
            trueAF = [];
            
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
                    trueAF(end +1) = Data.targetsRR(int64(mean(indexes)));
                    
                    
                    if(Pcv > obj.threshold)
                        detectRRVector(int64(mean(indexes))) = 1;
                    end
                      
                end
      
            
        end
       end

end

