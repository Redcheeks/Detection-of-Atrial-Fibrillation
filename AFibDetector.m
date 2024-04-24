classdef AFibDetector
    %AFIBDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        features
    end
    
    methods
        function obj = AFibDetector(DataVector, FeatNumber)
            %AFIBDETECTOR Creates and Trains a AFibDetector.
            %   
            
            %obj.features = FeatureSelection(DataVector, FeatNumber);
            
        end
        %% Feature Selection
        function feats = FeatureSelection(Data, FeatNumber)
            % Feature Selection.
            % FeatNumber amount of features
            
            
            feats = {};
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

