function [LandMarksComputed, AllPosesComputed] = SLAMusingGTSAM(DetAll, K, TagSize)
	% For Input and Output specifications refer to the project pdf

	import gtsam.*
	% Refer to Factor Graphs and GTSAM Introduction
	% https://research.cc.gatech.edu/borg/sites/edu.borg/files/downloads/gtsam.pdf
	% and the examples in the library in the GTSAM toolkit. See folder
	% gtsam_toolbox/gtsam_examples
    
    %% DetAll Init
    newDet = {};
    %This'll make debugging easier later TRUST ME
    for i=1:length(DetAll)
        NumDetections = size(DetAll{i});
        for j=1:NumDetections(1)
            newDet{i}(j) = getDetection(DetAll{i}(j,:));
            
            % Grab origin of tag 10
            if i == 1 && newDet{i}(j).TagID == 10
                origin = newDet{i}(j).p1;
            end
        end
    end
    
    DetAll = newDet;
    disp(origin);
end

function Detection = getDetection(det)
Detection.TagID = det(1);
Detection.p1 = [det(2), det(3)];
Detection.p2 = [det(4), det(5)];
Detection.p3 = [det(6), det(7)];
Detection.p4 = [det(8), det(9)];
end