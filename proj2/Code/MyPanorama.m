function [pano] = MyPanorama()
    clear;
    
    IMGSET = 1;
    
    selector = strcat('../Images/Set', num2str(IMGSET), '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    
    %% Constants
    N_Best = 300;
    match_thresh = .85;
    RANSAC_thresh = 2;
    maxIters = 1000;
    
    %% Detect Corners and ANMS
    %for img = 1:imgN
    for img = 2:2
        imgPath = fullfile(path(img).folder, path(img).name);
        I = rgb2gray(imread(imgPath));
        
        p = ANMS(I, N_Best);
    end
    
    %% Feature Descriptor
    
    %% Feature Matching
    
    %% RANSAC step
    
    %% Projection (Optional)
    
    %% Blending
end
