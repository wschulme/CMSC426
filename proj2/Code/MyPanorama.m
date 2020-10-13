function [pano] = MyPanorama()
    clear;
    
    %% Constants
    N_Best = 300;
    match_thresh = .85;
    RANSAC_thresh = 2;
    MAX_ITERS = 1000;
    FILTER = 'gaussian';
    IMGSET = 1;
    
    %% Variables
    selector = strcat('../Images/Set', num2str(IMGSET), '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    pano = getGrayImage(1, path);
    
    %for img = 2:imgN
    for img = 2:2
        %% Detect Corners and ANMS
        
        I1 = pano;
        I2 = getGrayImage(img, path);
        
        p1 = ANMS(I1, N_Best);
        p2 = ANMS(I2, N_Best);
    
        %% Feature Descriptor
        
        % Apply filter
        H = fspecial(FILTER, 40);
        blurred1 = imfilter(double(I1), H, 'replicate');
        blurred2 = imfilter(double(I2), H, 'replicate');
        
        % Sub-sample descriptors
        D1 = imresize(blurred1, [8 8]);
        D2 = imresize(blurred2, [8 8]);
        
        % Reshape
        D1 = reshape(D1, [64,1]);
        D2 = reshape(D2, [64,1]);
        
        % Standardize
        D1 = (D1 - mean(D1))/std(D1);
        D2 = (D2 - mean(D2))/std(D2);

        %% Feature Matching
        [matchedPoints1, matchedPoints2] = getMatchedPoints(I1, I2, p1, p2);
        hImage = showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2, 'montage')
        
        %% RANSAC step

        %% Projection (Optional)

        %% Blending
        pano = blend(I1, I2)
    end
end

function img = getGrayImage(i, path)
    img = rgb2gray(imread(fullfile(path(i).folder, path(i).name)));
end

function [match1,match2] = getMatchedPoints(I1, I2, p1, p2)
    match1 = zeros(1,2);
    match2 = zeros(1,2);
    match1(:) = [];
    match2(:) = [];
    [sz,sz2] = size(p1);
    % Pick 1 point in image 1
    for i = 1:sz
        M = 0;
        N = 0;
        % Compute sum of square difference between all points in image 2
        for j = 1:sz
            sumsq(j) = sum((I1(i,:)-I2(j,:)).^2);
        end
        % Get 2 lowest distance aka 2 BEST distance
        [M,N] = sort(sumsq,'descend');
        oneMatch = M(sz);
        twoMatch = M(sz-1);
        % Keep the matched pair if below ratio 0.5, else reject
        % TODO: fix coordinates
        if((oneMatch/twoMatch)<0.5)
            match1 = vertcat(match1, [p1(i,2) p1(i,1)]);
            match2 = vertcat(match2, [p2(N(1),2) p2(N(1),1)]);
        end
    end
end
