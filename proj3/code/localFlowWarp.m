function [NewLocalWindows] = localFlowWarp(WarpedPrevFrame, CurrentFrame, LocalWindows, Mask, Width)
% LOCALFLOWWARP Calculate local window movement based on optical flow between frames.

% TODO
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

