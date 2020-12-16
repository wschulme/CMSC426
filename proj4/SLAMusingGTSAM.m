function [LandMarksComputed, AllPosesComputed] = SLAMusingGTSAM(DetAll, K, TagSize)
	% For Input and Output specifications refer to the project pdf
	import gtsam.*
	% Refer to Factor Graphs and GTSAM Introduction
	% https://research.cc.gatech.edu/borg/sites/edu.borg/files/downloads/gtsam.pdf
	% and the examples in the library in the GTSAM toolkit. See folder
	% gtsam_toolbox/gtsam_examples
    
    % Return vars Init
    LandMarksComputed  = [];
    AllPosesComputed = [];
    
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
    
    %% Initialization
    %Calculate initial homography assuming a planar carpet of April Tags
    imageCoords = [Tag10.p1; Tag10.p2; Tag10.p3; Tag10.p4];
    worldCoords = [[0,0,1];[TagSize,0,1];[0,TagSize,1];[TagSize,TagSize,1]];
    
    H = getHomography(worldCoords, imageCoords);
    
    % Map: tagID -> Location
    locations = containers.Map('KeyType','double','ValueType','any');
    % Map: frame -> Pose
    poses = containers.Map('KeyType','int32','ValueType','any');
    
    %% Apply Homography to First Frame
    NumDetections = size(DetAll{1});
    for i=1:NumDetections(2)
        tag = DetAll{1}(i);
        locations(tag.TagID) = getLocationObject(H, tag); 
    end
    poses(1) = getPoseParts(H, K);
    pose = getPoseRow(poses(1).R, poses(1).T);
    AllPosesComputed = [AllPosesComputed; pose];
    LandMarksComputed = [LandMarksComputed; tag.TagID tag.p1 tag.p2 tag.p3 tag.p4];
        
    for i=2:length(DetAll)
        NumDetections = size(DetAll{i});
        
        %% Gather World Locations
        imageCoords = [];
        worldCoords = [];
        for j=1:NumDetections(2)
            tag = DetAll{i}(j);
            
            %If we've seen it, it's useful for calculating a homography
            if isKey(locations,tag.TagID)
                world = locations(tag.TagID);
                imageCoords = [imageCoords; tag.p1; tag.p2; tag.p3; tag.p4];
                worldCoords = [worldCoords; world.p1; world.p2; world.p3; world.p4];
            end
        end
        
        %% Calculate New Homography
        H = getHomography(worldCoords, imageCoords);
        
        %% Apply New Homography and Store Locations
        for j=1:NumDetections(2)
            tag = DetAll{i}(j);
            %I'm skipping locations we've already found to save time
            if ~isKey(locations,tag.TagID)
                locations(tag.TagID) = getLocationObject(H, tag); 
                %disp(locations(tag.TagID).p1);
            end
        end
        
        %% Store Pose
        poses(i) = getPoseParts(H, K);
        pose = getPoseRow(poses(i).R, poses(i).T);
        AllPosesComputed = [AllPosesComputed; pose];
        LandMarksComputed = [LandMarksComputed; tag.TagID tag.p1 tag.p2 tag.p3 tag.p4];
    end
    
    %% Factor Graph/Plotting
    
end

function Detection = getDetection(det)
    Detection.TagID = det(1);
    Detection.p1 = [det(2), det(3)];
    Detection.p2 = [det(4), det(5)];
    Detection.p3 = [det(6), det(7)];
    Detection.p4 = [det(8), det(9)];
end

function pose = getPoseRow(R,T)
    %Each quaternion, one per row, is of the form q = [w x y z]
    quat = rotm2quat(R);
    %pose = [PosX, PosY, PosZ, Quaternion, QuaternionX, QuaternionY, QuaternionZ]
    pose = [quat, transpose(T)];
end

