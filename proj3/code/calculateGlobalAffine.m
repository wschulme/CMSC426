function [WarpedFrame, WarpedMask, WarpedMaskOutline, WarpedLocalWindows] = calculateGlobalAffine(IMG1,IMG2,Mask,Windows)
% CALCULATEGLOBALAFFINE: finds affine transform between two frames, and applies it to frame1, the mask, and local windows.
    % Select object
	min_x = min(Windows(:,2));
	max_x = max(Windows(:,2));
	min_y = min(Windows(:,1));
	max_y = max(Windows(:,1));
    
    % We allow a small pixel room for error to account for difference in
    % frames.
    error = 0;
    disp("mask x: " + size(Windows(:,1)) + " --- mask y: " + size(Windows(:,2)));
    % Convert imgs to masks of imgs
    img1 = rgb2gray(IMG1);
    
    disp("max_x and error: " + max_x + " + " + error);
    img1 = img1(min_x-error:max_x+error, min_y-error:max_y+error);
    img2 = rgb2gray(IMG2);
    img2 = img2(min_x-error:max_x+error, min_y-error:max_y+error);
    
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
    
    figure 
    showMatchedFeatures(img1,img2,matchedPtsOriginal,matchedPtsDistorted)
    
    % getting the general geometric transformation of the image
    [tform, ~] = estimateGeometricTransform(matchedPtsOriginal, matchedPtsDistorted, 'affine');
    
    outputView = imref2d(size(IMG2));
    
    WarpedFrame = imwarp(IMG1, tform, 'OutputView', outputView);
    WarpedMask = imwarp(Mask, tform, 'OutputView', outputView);
    WarpedMaskOutline = bwperim(WarpedMask,4);

    WarpedLocalWindows = zeros(size(Windows));
    for window = 1:length(Windows)
        u = Windows(window,1);
		v = Windows(window,2);
        
		[x, y] = transformPointsForward(tform,u,v);
        
        WarpedLocalWindows(window,2) = round(x);
        WarpedLocalWindows(window,1) = round(y);
        
    end
end

