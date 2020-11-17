function [WarpedFrame, WarpedMask, WarpedMaskOutline, WarpedLocalWindows] = calculateGlobalAffine(IMG1,IMG2,Mask,Windows)
% CALCULATEGLOBALAFFINE: finds affine transform between two frames, and applies it to frame1, the mask, and local windows.
    % Getting the features for analyizing the general picture motion though
    % estimateGeometricTransform
    ptsOriginal  = detectSURFFeatures(IMG1);
    ptsS = detectSURFFeatures(IMG2);
    
    % returns extracted feature vectors, and their corresponding locations, from an image.
    [featuresOriginal,validPtsOriginal] = extractFeatures(IMG1,ptsOriginal);
    [featuresDistorted,validPtsDistorted] = extractFeatures(IMG2,ptsShifted);
    
    % matching the features and the points between the two images
    index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
    matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1));
    matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
    
    % getting the general geometric transformation of the image
    [tform,inlierIdx] = estimateGeometricTransform(matchedPtsDistorted, matchedPtsOriginal, 'similarity');
    
    %initial shape alignment usually captures and compensates for large rigid motions of the foreground object
    rebounded = imwarp(distorted,tform,'OutputView',outputView);

    % I have no idea if the bottom is right
    % Init opticalFlowHS
    opticFlow = opticalFlowHS
    
    % Going though all the windows and getting the gray scale
    for i = 1:length(Windows)
        frameGray = rgb2gray(Windows{i});  
        % Calculate the flow from the frame
        flow = estimateFlow(opticFlow,frameGray);
        % Need to apply the opticFlow shift to the mask and windows onto
        % the rebounded image
    end
    
end

