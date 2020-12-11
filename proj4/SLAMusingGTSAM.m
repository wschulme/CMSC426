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
                Tag10 = newDet{i}(j);
            end
        end
    end
    
    DetAll = newDet;
    fprintf('Tag10 Origin: (%f, %f) \n', Tag10.p1(1), Tag10.p1(2));
    
    %% Pre-GTSAM
    %Calculate initial homography assuming a planar carpet of April Tags
    imageCoords = [Tag10.p1; Tag10.p2; Tag10.p3; Tag10.p4];
    worldCoords = [[0,0];[TagSize,0];[0,TagSize];[TagSize,TagSize]];
    
    H = est_homography(worldCoords(1,:), worldCoords(2,:), imageCoords(1,:), imageCoords(2,:));
    disp(H);
end

function Detection = getDetection(det)
Detection.TagID = det(1);
Detection.p1 = [det(2), det(3)];
Detection.p2 = [det(4), det(5)];
Detection.p3 = [det(6), det(7)];
Detection.p4 = [det(8), det(9)];
end