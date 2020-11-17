function [WarpedFrame, WarpedMask, WarpedMaskOutline, WarpedLocalWindows] = calculateGlobalAffine(IMG1,IMG2,Mask,Windows)
% CALCULATEGLOBALAFFINE: finds affine transform between two frames, and applies it to frame1, the mask, and local windows.
    % Select object
    [mask_coordinates(:,1), mask_coordinates(:,2)] = find(Mask);
    
	min_x = min(mask_coordinates(:,1));
	max_x = max(mask_coordinates(:,1));
	min_y = min(mask_coordinates(:,2));
	max_y = max(mask_coordinates(:,2));
    
    % We allow a small pixel room for error to account for difference in
    % frames.
    error = 30;
    
    % Convert imgs to masks of imgs
    img1 = rgb2gray(IMG1);
    img1 = img1(min_x-error:max_x+error, min_y-error:max_y+error);
    img2 = rgb2gray(IMG2);
    img2 = img2(min_x-error:max_x+error, min_y-error:max_y+error);
    
    %[x y width height]
    %ROI = [1 1 max_x-min_x max_y-min_y];
    
    % Getting the features for analyizing the general picture motion though
    % estimateGeometricTransform
    ptsOriginal  = detectHarrisFeatures(img1); %detectSURFFeatures(img1, 'ROI', ROI);
    ptsShifted = detectHarrisFeatures(img2); %detectSURFFeatures(img2, 'ROI', ROI);
    
    % returns extracted feature vectors, and their corresponding locations, from an image.
    [featuresOriginal,validPtsOriginal] = extractFeatures(img1,ptsOriginal);
    [featuresDistorted,validPtsDistorted] = extractFeatures(img2,ptsShifted);
    
    % matching the features and the points between the two images
    index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
    matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1));
    matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
    
    % getting the general geometric transformation of the image
    [tform, ~] = estimateGeometricTransform(matchedPtsDistorted, matchedPtsOriginal, 'affine');
    
    outputView = imref2d(size(IMG1));
    
    WarpedFrame = imwarp(IMG2, tform, 'OutputView', outputView);
    WarpedMask = imwarp(Mask, tform, 'OutputView', outputView);
    WarpedMaskOutline = bwperim(WarpedMask,4);

    WarpedLocalWindows = zeros(size(Windows));
    for window = 1:length(Windows)
        u = Windows(window,2);
		v = Windows(window,1);
        
		[x, y] = transformPointsForward(tform,u,v);
        
        WarpedLocalWindows(window,1) = round(x);
        WarpedLocalWindows(window,2) = round(y);
        
    end
end

