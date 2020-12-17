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
    
    %% DetAllObj Init
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
    
    DetAllObj = newDet;
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
    NumDetections = size(DetAllObj{1});
    for i=1:NumDetections(2)
        tag = DetAllObj{1}(i);
        locations(tag.TagID) = getLocationObject(H, tag); 
    end
    poses(1) = getPoseParts(H, K);
    pose = getPoseRow(poses(1).R, poses(1).T);
    AllPosesComputed = [AllPosesComputed; pose];
    LandMarksComputed = [LandMarksComputed; tag.TagID tag.p1 tag.p2 tag.p3 tag.p4];
        
    for i=2:length(DetAllObj)
        NumDetections = size(DetAllObj{i});
        
        %% Gather World Locations
        imageCoords = [];
        worldCoords = [];
        for j=1:NumDetections(2)
            tag = DetAllObj{i}(j);
            
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
            tag = DetAllObj{i}(j);
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
    
    %% Plotting side view
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
    
    %% Factor Graph (GTSAM)
    % References: https://gtsam.org/tutorials/intro.html#magicparlabel-65377
    % (Page 18) https://smartech.gatech.edu/bitstream/handle/1853/45226/Factor%20Graphs%20and%20GTSAM%20A%20Hands-on%20Introduction%20GT-RIM-CP%26R-2012-002.pdf?sequence=1&isAllowed=y
    % https://github.com/NitinJSanket/CMSC828THW1/blob/master/SLAMUsingGTSAM.m
    % =========== TODO: THISSSSSSSSSSSS All of it except Prior and Odometry and x ==========
    
    % Collect xs: 'x'
    x = cell(length(DetAll), 1);
    for i = 1:length(DetAll)
        x{i} = symbol('x', i);
    end
    
    % Collect Landmark Points: 'l'
    LandMarksObserved = [];
    for i = length(DetAll)
        % Tags
        curr_landmarks = sortrows(DetAll{i},1);
        LandMarksObserved = [LandMarksObserved, curr_landmarks(1)];
    end
    LandMarksObserved = unique(LandMarksObserved);
    l = cell(length(LandMarksObserved),1);
    for i = 1:length(LandMarksObserved)
        l{i} = symbol('l', LandMarksObserved(i));
    end
    
    graph = NonlinearFactorGraph;
    
    % Prior
    prior_mean = Pose2(0.0, 0.0, 0.0); % At origin
    prior_noise = noiseModel.Diagonal.Sigmas([0.3; 0.3; 0.1]);
    graph.add(PriorFactorPose2(x{1}, prior_mean, prior_noise));
    
    % Odometry
    o = Pose2(2.0, 0.0, 0.0);
    o_noise = noiseModel.Diagonal.Sigmas([0.2; 0.2; 0.1]);
    for i = 1:length(x)-1 
        graph.add(BetweenFactorPose2(x{i}, x{i+1}, o, o_noise));
    end
    
    graph.print(sprintf('\nFactor graph:\n'));
    
    
    % Starting here, everything is temporary and testing. Disregard this
    % code please. It's just me trying to figure out how to get the
    % optimizer to run.
    %% Initialize to noisy points
    initialEstimate = Values;
    for i = 1:length(LandMarksObserved)
        initialEstimate.insert(x{i}, Pose2(2.0, 0.0, 0.0));
    end
    initialEstimate.print(sprintf('\nInitial estimate:\n'));

    %% Optimize using Levenberg-Marquardt optimization with an ordering from colamd
    optimizer = LevenbergMarquardtOptimizer(graph, initialEstimate);
    result = optimizer.optimizeSafely();
    result.print(sprintf('\nFinal result:\n'));

    %% Plot Covariance Ellipses
    cla;
    hold on
    plot([result.at(5).x;result.at(2).x],[result.at(5).y;result.at(2).y],'r-');
    marginals = Marginals(graph, result);

    plot2DTrajectory(result, [], marginals);
    for i=1:5,marginals.marginalCovariance(i),end
    axis equal
    axis tight
    view(2)
    
%     % Projection
%     % Add bearing/range measurement factors
%     degrees = pi/180;
%     brNoise = noiseModel.Diagonal.Sigmas([0.2; deg2rad(10)]);
%     for i = 1:length(LandMarksObserved)
%         for j = 1:length(LandMarksObserved(i))
%             LandMarkIdx = find(LandMarksObserved == curr_landmarks(i));
%             graph.add(BearingRangeFactor2D(x{i}, l{LandMarkIdx}, Rot2(45*degrees), 2, brNoise))
%         end
%     end
%     
%     %graph.print(sprintf('\nFull grObservedLandMarks{step}.Idxaph:\n'));
%     
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

