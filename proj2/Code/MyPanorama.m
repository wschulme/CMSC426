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
    
    %% Variables
    pano = getGrayImage(1, path);
    
    %% Detect Corners and ANMS
    %for img = 1:imgN
    for img = 2:2
        I1 = pano;
        I2 = getGrayImage(img, path);
        
        p1 = ANMS(I1, N_Best);
        p2 = ANMS(I2, N_Best);
    
    
        %% Feature Descriptor

        f1 = features(I1);
        f2 = features(I2);

        %% Feature Matching

        %% RANSAC step

        %% Projection (Optional)

        %% Blending
        pano = blend(I1, I2)
    end
end

function img = getGrayImage(i, path)
    img = rgb2gray(imread(fullfile(path(i).folder, path(i).name)));
end
