classdef AFibDetector
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold
        window
    end
    
    methods
        function obj = AFibDetector(DataVector, Window)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            
            %obj.features = FeatureSelection(DataVector, FeatNumber);
            
        end
        %% Feature Selection / Threshold
        function feats = FeatureSelection(obj, thresh, window)
            % Feature Selection.
            % 
            
            
            obj.threshold = thresh;
            obj.window = window;
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

