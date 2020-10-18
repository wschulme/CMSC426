function [pano] = MyPanorama()
    clear;
    
    %% Constants
    N_Best = 300;
    match_thresh = .2;
    RANSAC_thresh = 6;
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
        imgSize(img,:) = size(I2);
        
        p1 = ANMS(I1, N_Best);
        p2 = ANMS(I2, N_Best);
    
        %% Feature Descriptor
        % Get filter
        H = fspecial(FILTER, 40);
        
        D1 = getFeatureDescriptors(p1, H, I1);
        D2 = getFeatureDescriptors(p2, H, I2);
 
        %% Feature Matching
        [matchedPoints1, matchedPoints2] = getMatchedPoints(D1, D2, p1, p2, match_thresh);
        %hImage = showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2, 'montage');
        
        %% RANSAC step
        ransac(matchedPoints1, matchedPoints2, RANSAC_thresh, I1, I2, MAX_ITERS);
        %% Projection (Optional)

        %% Blending
        % SOURCE: https://www.mathworks.com/help/vision/ug/feature-based-panoramic-image-stitching.html
        % Get tforms between 2 images
        % TODO: CHANGE matchedPoints to r_matchedPoints from RANSAC
        tforms(img) = estimateGeometricTransform(matchedPoints2, matchedPoints1, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
        tforms(img).T = tforms(img).T * tforms(img-1).T;
    end
    % Blending continued outside for for loop
    % Compute the output limits  for each transform
    for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end

    % Compute avg X limits for each transforms and find image that is used
    avgXLim = mean(xlim, 2);

    [~, idx] = sort(avgXLim);

    centerIdx = floor((numel(tforms)+1)/2);

    centerImageIdx = idx(centerIdx);

    % Apply center image's inverse transform to all the others
    Tinv = invert(tforms(centerImageIdx));

    for i = 1:numel(tforms)
        tforms(i).T = tforms(i).T * Tinv.T;
    end

    % Initialize Panorama
    for i = 1:numel(tforms)
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end

    maxImageSize = max(imageSize);
    
    % Find the minimum and maximum output limits 
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);

    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);

    % Width and height of panorama.
    width  = round(xMax - xMin);
    height = round(yMax - yMin);

    % Initialize the "empty" panorama.
    panorama = zeros([height width 3], 'like', I);
    
    % Use imwarp to map images into pano and use vision.AlphaBlender to
    % overlay images
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);

    % Create the panorama.
    for i = 1:numImages

        I = readimage(buildingScene, i);   

        % Transform I into the panorama.
        warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);

        % Generate a binary mask.    
        mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);

        % Overlay the warpedImage onto the panorama.
        panorama = step(blender, panorama, warpedImage, mask);
    end

    figure
    imshow(panorama)
end

function img = getGrayImage(i, path)
    img = rgb2gray(imread(fullfile(path(i).folder, path(i).name)));
end