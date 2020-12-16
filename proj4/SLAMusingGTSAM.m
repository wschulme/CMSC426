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
    
    %LandMarksComputed = sortrows(LandMarksComputed, 1);
    
    %% Factor Graph/Plotting
    hold on;
    % Plot Pose (From the Side)
    for i = 1:size(AllPosesComputed, 1)
        p = AllPosesComputed(i, :);
        x = p(1);
        z = p(3);
        
        plot(x, z, 'bo', 'LineWidth', 1);
    end
    
    % Plot Landmarks (From the Side)
    for i = 1:size(LandMarksComputed, 1)
       t = LandMarksComputed(i,:);
       xs = [t(2) t(4) t(6) t(8) t(2)];
       zs = [0 0 0 0 0];
       plot(xs, zs, 'r-', 'LineWidth', 1);
    end
    hold off;
    
    % Factor Graph (GTSAM)
    % References: https://gtsam.org/tutorials/intro.html#magicparlabel-65377
    % (Page 18) https://smartech.gatech.edu/bitstream/handle/1853/45226/Factor%20Graphs%20and%20GTSAM%20A%20Hands-on%20Introduction%20GT-RIM-CP%26R-2012-002.pdf?sequence=1&isAllowed=y
    
    % Collect xs
    x = cell(length(newDet), 1);
    for i = 1:length(newDet)
        x{i} = symbol('x', i);
    end
    
    % Collect Landmark Points
    all_landmarks = cell(length(LandMarksComputed), 1);
    disp(size(newDet));
    for i = length(newDet)
        curr_landmarks = newDet{1,i};
        points = cell(length(curr_landmarks), 1);
        count = 0;
        for k = 1:length(curr_landmarks(:,1))
            for j = 1:length(curr_landmarks(k, 2))
                count = count + 1;
                points{count} = symbol('lp', curr_landmarks(count, 1));
            end
        end
        all_landmarks{i} = points;
    end
    
    graph = NonlinearFactorGraph;
    
    % Prior
    prior_mean = Pose2(0.0, 0.0, 0.0); % At origin
    prior_noise = noiseModel.Diagonal.Sigmas([0.3; 0.3; 0.1]);
    graph.add(PriorFactorPose2(x{1}, prior_mean, prior_noise));
    
    % Odometry
    o_noise = noiseModel.Diagonal.Sigmas([0.2; 0.2; 0.1]);
    for i = 1:length(x)-1 
        graph.add(BetweenFactorPose2(x{i}, x{i+1}, eye(3), o_noise));
    end
    
    % Projection
    for i = 1:length(all_landmarks)
        for j = 1:length(all_landmarks{i})
            graph.add(Point2)
        end
    end
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
