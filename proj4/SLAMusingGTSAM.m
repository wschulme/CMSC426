function [LandMarksComputed, AllPosesComputed] = SLAMusingGTSAM(DetAll, K, TagSize)
	% For Input and Output specifications refer to the project pdf
	import gtsam.*
    import Levenberg.*
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
    worldCoords = [[0,0,1];[TagSize,0,1];[TagSize,TagSize,1];[0,TagSize,1]];
    
    H = getHomography(worldCoords, imageCoords);
    
    % Map: tagID -> Location
    locations = containers.Map('KeyType','double','ValueType','any');
    % Map: frame -> Pose
    poses = containers.Map('KeyType','int32','ValueType','any');
    tagIds = [];
    
    %% Apply Homography to First Frame
    NumDetections = size(DetAllObj{1});
    for i=1:NumDetections(2)
        tag = DetAllObj{1}(i);
        locations(tag.TagID) = getLocationObject(H, tag, 1); 
    end
    poses(1) = getPoseParts(K, H);
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
            
            %If we've seen it, it's useful for calculating a homography if
            %its from the previous frame
            
            if isKey(locations,tag.TagID) && locations(tag.TagID).frame == i-1
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
            
            locations(tag.TagID) = getLocationObject(H, tag, i); 
            tagIds = [tagIds, tag.TagID];
            
        end
        
        %% Store Pose
        poses(i) = getPoseParts(K, H);
        pose = getPoseRow(poses(i).R, poses(i).T);
        AllPosesComputed = [AllPosesComputed; pose];
        LandMarksComputed = [LandMarksComputed; tag.TagID tag.p1 tag.p2 tag.p3 tag.p4];
    end
    
    LandMarksComputed = sortrows(LandMarksComputed, 1);
    %% 3D Plot
    figure
    hold on;
    
    tagIds = unique(tagIds);
    for i = 1:length(tagIds)
        l = locations(tagIds(i));
        
        plot3(l.p1(1),l.p1(2),0,'*','Color','y');
        plot3(l.p2(1),l.p2(2),0,'*','Color','m');
        plot3(l.p3(1),l.p3(2),0,'*','Color','b');
        plot3(l.p4(1),l.p4(2),0,'*','Color','g');
    end
    
    for i=1:length(DetAllObj)
        p = poses(i).T;
        plot3(p(1),p(2),p(3), 'o', 'Color', 'r');
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
    for i = 1:length(DetAll)
        % Tags
        LandMarksObserved = [LandMarksObserved, LandMarksComputed(i,1)];
    end
    LandMarksObserved = unique(LandMarksObserved);
    l = cell(length(LandMarksObserved),1);
    for i = 1:length(LandMarksObserved)
        l{i} = symbol('l', LandMarksObserved(i));
    end
    
    graph = NonlinearFactorGraph;

    Rot3(poses(1).R)
    Point3(poses(1).T)
    
    % Prior
    %prior_mean = Pose3(Rot3(H), Point3([pose(4:6)])); % At origin
    prior_mean = Pose3(Rot3(poses(1).R), Point3(poses(1).T));
    prior_noise = noiseModel.Diagonal.Sigmas(ones(6,1)*1e-2);
    graph.add(PriorFactorPose3(x{1}, prior_mean, prior_noise));
    
    % Odometry
    o = Pose3(Rot3(poses(1).R), Point3(poses(1).T));
    o_noise = noiseModel.Diagonal.Sigmas(ones(3,1)*1e-2);
    for i = 1:length(x)-1 
        graph.add(BetweenFactorPose3(x{i}, x{i+1}, o, o_noise));
    end
    
    % Camera Calibration
    cam = Cal3_S2(K(1, 1), K(2, 2), K(3, 3), K(1, 3), K(2, 3))
    
    % Optimizer
    parameters = LevenbergMarquardtParams;
    parameters.setLambdaInitial(1.0);
    parameters.setVerbosityLM('trylambda');
    
    optimizer = LevenbergMarquardtOptimizer(graph, z, parameters);
    
    for i = 1:10
        optimizer.iterate();
    end
    
    result = optimizer.values();
    result.print(sprintf('\nFinal result:\n  '));
    
    % Projection
    % Add bearing/range measurement factors
    degrees = pi/180;
    brNoise = noiseModel.Diagonal.Sigmas([0.2; deg2rad(10)]);
    for i = 1:length(LandMarksObserved)
        for j = 1:length(LandMarksObserved(i))
            LandMarkIdx = find(LandMarksObserved == LandMarksComputed(j,1));
            graph.add(BearingRangeFactor2D(x{i}, l{LandMarkIdx}, Rot2(45*degrees), 2, brNoise))
        end
    end
    
    %graph.print(sprintf('\nFull grObservedLandMarks{step}.Idxaph:\n'));
    
    %% Add factors for all measurements
    measurementNoiseSigma = 1.0;
    K1 = Cal3_S2(K(1, 1), K(2, 2), 0, K(1,3), K(2, 3));
    baseNoiseModel = noiseModel.Isotropic.Sigma(2, measurementNoiseSigma);
    for i=1:length(DetAll)
        mat = DetAll{i};
        for k=1:size(mat, 1)
            dat = mat(k, :);
            graph.add(GenericProjectionFactorCal3_S2(Point2(dat(2), dat(3)), baseNoiseModel, x{i}, symbol('l',dat(1)), K1));
            graph.add(GenericProjectionFactorCal3_S2(Point2(dat(4), dat(5)), baseNoiseModel, x{i}, symbol('m',dat(1)), K1));
            graph.add(GenericProjectionFactorCal3_S2(Point2(dat(6), dat(7)), baseNoiseModel, x{i}, symbol('n',dat(1)), K1));
            graph.add(GenericProjectionFactorCal3_S2(Point2(dat(8), dat(9)), baseNoiseModel, x{i}, symbol('o',dat(1)), K1));
        end
    end
    
    initialEstimate = Values;
    
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

