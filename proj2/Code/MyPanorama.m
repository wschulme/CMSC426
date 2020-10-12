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
    MAX_ITERS = 1000;
    FILTER = 'gaussian';
    
    %% Variables
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

        %% RANSAC step

        %% Projection (Optional)

        %% Blending
        pano = blend(I1, I2)
    end
end

function img = getGrayImage(i, path)
    img = rgb2gray(imread(fullfile(path(i).folder, path(i).name)));
end
