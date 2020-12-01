function [WarpedFrame, WarpedMask, WarpedMaskOutline, WarpedLocalWindows] = calculateGlobalAffine(IMG1,IMG2,Mask,Windows)
% CALCULATEGLOBALAFFINE: finds affine transform between two frames, and applies it to frame1, the mask, and local windows.
    
    % Convert imgs to masks of imgs
    img1 = rgb2gray(IMG1);
    
    img2 = rgb2gray(IMG2);
    
    
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
    
    %figure 
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
        
		[x, y] = transformPointsForward(invert(tform),u,v);
        
        WarpedLocalWindows(window,1) = floor(x);
        WarpedLocalWindows(window,2) = floor(y);
    end
end

