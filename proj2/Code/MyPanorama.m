function [pano] = MyPanorama()
    clear;
    
    %% Constants
    N_Best = 300;
    match_thresh = .5;
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
        % Get filter
        H = fspecial(FILTER, 40);
        
        D1 = getFeatureDescriptors(p1, H, I1);
        D2 = getFeatureDescriptors(p2, H, I2);
 
        %% Feature Matching
        [matchedPoints1, matchedPoints2] = getMatchedPoints(D1, D2, p1, p2, match_thresh);
        hImage = showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2, 'montage');
        
        %% RANSAC step
        ransac(matchedPoints1, matchedPoints2, match_thresh);
        
        %% Projection (Optional)

        %% Blending
        pano = blend(I1, I2)
    end
end

function img = getGrayImage(i, path)
    img = rgb2gray(imread(fullfile(path(i).folder, path(i).name)));
end