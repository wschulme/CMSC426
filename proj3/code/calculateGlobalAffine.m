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
    
    %[x y width height]
    ROI = [min_y-error min_x-error max_y-min_y+2*error max_x-min_x+2*error];
    
    % Getting the features for analyizing the general picture motion though
    % estimateGeometricTransform
    ptsOriginal  = detectSURFFeatures(rgb2gray(IMG1), 'ROI', ROI);
    ptsShifted = detectSURFFeatures(rgb2gray(IMG2), 'ROI', ROI);
    
    % returns extracted feature vectors, and their corresponding locations, from an image.
    [featuresOriginal,validPtsOriginal] = extractFeatures(IMG1,ptsOriginal);
    [featuresDistorted,validPtsDistorted] = extractFeatures(IMG2,ptsShifted);
    
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
    
    WarpedLocalWindows = zeroes(len(Windows),2);
    for window = 1:len(Windows)
        u = Windows(window,1);
		v = Windows(window,2);
		[x, y] = transformPointsForward(tform,u,v);
		WarpedLocalWindows(window,1) = x;
		WarpedLocalWindows(window,2) = y;
    end
end

