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
    imageCoords = [Tag10.p1; Tag10.p2; Tag10.p3; Tag10.p4; Tag10.p1];
    worldCoords = [[0,0,1];[TagSize,0,1];[0,TagSize,1];[TagSize,TagSize,1];[0,0,1]];
    
    H = getHomography(worldCoords, imageCoords);
    [R,T] = getPoseParts(K,H);
    pose = getPoseRow(R,T);
    
    %Sanity check
%     disp(imageCoords);
%     results = H*worldCoords';
%     disp(results(:,1)./results(3,1));
%     disp(results(:,2)./results(3,2));
%     disp(results(:,3)./results(3,3));
%     disp(results(:,4)./results(3,4));
    
    
end

function Detection = getDetection(det)
Detection.TagID = det(1);
Detection.p1 = [det(2), det(3)];
Detection.p2 = [det(4), det(5)];
Detection.p3 = [det(6), det(7)];
Detection.p4 = [det(8), det(9)];
end

function [R,T] = getPoseParts(K,H)
    KH = inv(K)*H;
    temp = [KH(:,1) KH(:,2) cross(KH(:,1),KH(:,2))];
    [U,~,V] = svd(temp);
    R = U*[1 0 0; 0 1 0; 0 0 det(U*V.')]*V.';
    T = KH(:,3)/norm(KH(:,1),2);
    %Note: Dan has this as -T. We will need to see if it works like this or
    %+T
    T = R'*(-T);
end

function H = getHomography(X,x)
    % X: World n x 3
	% x: Image n x 4
    X = X';
    x = x';
    sizeX = size(X);
    
    A = [];
    for i = 1:sizeX(2)
        A = [A; X(:,i).' 0 0 0 -X(:,i).'*x(1,i);
            0 0 0 X(:,i).' -X(:,i).'*x(2,i)];
    end
    
    [~, ~, V] = svd(A.'*A);
    rawH = reshape(V(:,9),3,3)';
    H = rawH/(rawH(3,3));
end

function pose = getPoseRow(R,T)
    %TODO: how tf get quaternions????

    %Each quaternion, one per row, is of the form q = [w x y z]
    quat = rotm2quat(R);
    %pose = [PosX, PosY, PosZ, Quaternion, QuaternionX, QuaternionY, QuaternionZ]
    pose = [transpose(T), quat]
end