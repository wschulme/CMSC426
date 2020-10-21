function pano = MyPanorama()
    clear;
    
    %% Constants
    N_Best = 300;
    match_thresh = .5;
    RANSAC_thresh = 1;
    MAX_ITERS = 1000;
    FILTER = 'gaussian';
    IMGSET = 1;
    SHOW_OUTPUT = false;
    MODE = 'train';
    MANY = false;
    
    %% Variables
    if strcmp(MODE,'train')
        selector = strcat('../Images/train_images/Set', num2str(IMGSET), '/*.jpg');
    elseif strcmp(MODE,'test')
        %Test
        selector = strcat('../Images/test_images/TestSet', num2str(IMGSET), '/*.jpg');
    else
        selector = strcat('../Images/custom_images/Set', num2str(IMGSET), '/*.jpg'); 
    end
    path = dir(selector);
    imgN = length(path);
    warps = {};
    if imgN > 4 MANY = true; end
    
    
    for img = 2:imgN
        %% Detect Corners and ANMS
        
        I1 = getImage(img-1, path);
        I2 = getImage(img, path);
        imageSize(img,:) = size(I2);
        
        p1 = ANMS(rgb2gray(I1), N_Best, SHOW_OUTPUT);
        p2 = ANMS(rgb2gray(I2), N_Best, SHOW_OUTPUT);
    
        %% Feature Descriptor
        % Get filter
        H = fspecial(FILTER);
        
        D1 = getFeatureDescriptors(p1, H, I1);
        D2 = getFeatureDescriptors(p2, H, I2);
 
        %% Feature Matching
        [matchedPoints1, matchedPoints2] = getMatchedPoints(D1, D2, p1, p2, match_thresh);
        if SHOW_OUTPUT 
            figure
            showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2, 'montage');
        end
        if length(matchedPoints1) < 20
            error(strcat("Number of matched points is insufficient. Make sure image ", num2str(img), " connects with the ones before."));
        end
        %% RANSAC step
        [r1, r2] = ransac(matchedPoints1, matchedPoints2, RANSAC_thresh, MAX_ITERS);
        if SHOW_OUTPUT 
            figure
            showMatchedFeatures(I1, I2, r1, r2, 'montage');
        end

        %% Stitching and Blending
        % SOURCE: https://www.mathworks.com/help/vision/ug/feature-based-panoramic-image-stitching.html
        % Estimate the transformation between I(n) and I(n-1).
        H= est_homography(r2(:,1), r2(:,2), r1(:,1), r1(:,2));
        tform = invert(projective2d(H'));
        tforms(img) = tform;
        % Compute T(n) * T(n-1) * ... * T(1)
        tforms(img).T = tforms(img).T * tforms(img-1).T;     
    end
    disp("Warping...");
    % Blending continued outside for for loop, from SOURCE
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
    
    if(MANY)
        % Width and height of panorama.
        width  = round((xMax - xMin) * .1);
        height = round((yMax - yMin) * .1);
    else
        width  = round(xMax - xMin);
        height = round(yMax - yMin);
    end

    % Initialize the panorama.
    panorama = zeros(height, width, 3);

    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);

    % Create the panorama.
    for i = 1:imgN
        I = getImage(i, path);

        % Transform I into the panorama.
        warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
        warps{end + 1} = warpedImage;
    end
    
    panoSize = size(panorama);
    
    disp("Stitching and blending...");
    for i = 1 : panoSize(1)
        for j = 1 : panoSize(2)
            avg = double(zeros(1,3));
            count = 0;
            for layer = 1 : length(warps)
                % If this layer has a pixel
                if warps{layer}(i,j,:) ~= [0;0;0]
                    % Add to avg
                    avg(:,1) = avg(:,1) + double(warps{layer}(i,j,1));
                    avg(:,2) = avg(:,2) + double(warps{layer}(i,j,2));
                    avg(:,3) = avg(:,3) + double(warps{layer}(i,j,3));
                    count = count + 1;
                end
            end
            % Let's not divide by 0
            if count > 1
                avg = avg ./ count;
            end
            panorama(i,j,:) = avg;
        end
    end
    figure
    imshow(uint8(panorama));
    
    pano = panorama;
end

function img = getImage(i, path)
    img = imread(fullfile(path(i).folder, path(i).name));
end