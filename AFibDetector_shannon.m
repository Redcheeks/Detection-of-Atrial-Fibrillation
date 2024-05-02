classdef AFibDetector_shannon
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold;
        window
    end
    
    methods
        function [obj, SampEnVector] = AFibDetector_PCV(DataVector, window)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            obj.window = window;
            obj.threshold = 0;
            
            SampEn_true = [];
            SampEn_false = [];
            SampEnVector = cell(4);

            
            
            for data_set = 1:length(DataVector) %for each training data
%             figure
%             hold on;
            %sliding window/ for each window position
            N = DataVector{data_set}.qrs(end)/1000 % current data set length in seconds
                for window_start = 0 : N - (window) %end window before data ends
                
                    % for each window, look at contents
                    % pick which datapoints (index) in the window
                    indexes = find(DataVector{data_set}.qrs>window_start*1000 & DataVector{data_set}.qrs<(window_start+window)*1000);
        
                    local_rr = DataVector{data_set}.rr(indexes);
                    center_tag = DataVector{data_set}.targetsRR(int64(mean(indexes))); % true/neg value of center of window.
                    
                    S = std(local_rr); % hela signalen?
%                     m = mean(local_rr);
                    
                    SampEn = S/m;
                    SampEnVector{data_set}(end+1)= SampEn;


                    % Hämtat från nätet
                    r = 0.2*S
                    data_matrix = NaN(window+1,N);
                    for a = 1:window+1
                        data_matrix(a,1:N+1-a) = DataVector{data_set}.rr(a:end);
                    end
                    data_matrix = data_matrix';
                    % take pairwise distances across each window
                    matrix_B = pdist(data_matrix(:,1:window), 'chebychev');
                    matrix_A = pdist(data_matrix(:,1:window+1), 'chebychev');
                    % take sum of counts of distances that fall within tolerance range
                    B = sum(matrix_B <= r*std(data));
                    A = sum(matrix_A <= r*std(data));
                    % calculate ratio of natural logarithm, with normalization correction
                    result = -log((A/B))*((N-window+1)/(N-window-1));
                    % correct inf to a maximum value
                    if isinf(result)
                        result = -log(2 / ((N-window-1)*(N-window)));
                    end
                    

                    if(center_tag)
                        SampEn_true(end + 1) = SampEn;
                    else
                        SampEn_false(end + 1) = SampEn;
                    end
                    
                end
                
            end
           
            figure();
            histogram(SampEn_true);
            hold on
            histogram(SampEn_false);
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