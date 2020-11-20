function [mask, LocalWindows, ColorModels, ShapeConfidences] = ...
    updateModels(...
        NewLocalWindows, ...
        LocalWindows, ...
        CurrentFrame, ...
        warpedMask, ...
        warpedMaskOutline, ...
        WindowWidth, ...
        ColorModels, ...
        ShapeConfidences, ...
        ProbMaskThreshold, ...
        fcutoff, ...
        SigmaMin, ...
        R, ...
        A ...
    )
% UPDATEMODELS: update shape and color models, and apply the result to generate a new mask.
% Feel free to redefine this as several different functions if you prefer.
%% Variables
    SIGMA_C = WindowWidth/2;
    REG = .001;
    NUM_GAUSS = 3;
    IMG = rgb2lab(CurrentFrame);
    dx_init = bwdist(warpedMaskOutline);
    Boundary = bwperim(warpedMask, 1);
    
    %Just a visualization for the mask (fore/back).
    imshow(warpedMask);
    imshow(CurrentFrame);
    %new_shape_confidences = ...
        %initShapeConfidences(NewLocalWindows, warpedMaskOutline, WindowWidth, SigmaMin, A, fcutoff, R);

    for window = 1:length(NewLocalWindows)
        new_foreground = [];
        y_w = LocalWindows(window, 1);
        x_w = LocalWindows(window, 2);
        
        Win = (IMG((x_w - SIGMA_C):(x_w + SIGMA_C), ...
            (y_w - SIGMA_C):(y_w + SIGMA_C),:));
        
        Win_mask = warpedMask((x_w - SIGMA_C):(x_w + SIGMA_C), ...
            (y_w - SIGMA_C):(y_w + SIGMA_C),:);
        
        d_x = dx_init((x_w - SIGMA_C):(x_w + SIGMA_C), ...
            (y_w - SIGMA_C):(y_w + SIGMA_C));
       
        %Iterate over the window (Win).
        for x = 1:size(Win,1)
            for y = 1:size(Win,2)
                %Get the pixel values.
                pixel = impixel(Win, x, y);
                
                %Append the channel values to their appropriate
                %classification.
                if Win_mask(x, y) == 1 && Boundary(x, y) ~= 1
                    new_foreground = vertcat(new_foreground, pixel);
                end
            end
        end
        disp(length(new_foreground));
        disp('old')
        disp(ColorModels{window}.foreground);
        if length(new_foreground) <= ColorModels{window}.foreground
            ColorModels{window}.foreground = new_foreground;
            %% Compute GMM

            %NUM_GAUSS and REG is arbitrary. I copied REG from the slides and
            %took NUM_GAUSS to be 3 because the turtle picture has like no colors. 
            gmm_f = fitgmdist(foreground, NUM_GAUSS, 'RegularizationValue', REG);
            gmm_b = fitgmdist(background, NUM_GAUSS, 'RegularizationValue', REG);

            %% Apply Model

            %Gather all the channels in the window
            [r, c, ~] = size(Win);
            window_channels = reshape(double(Win),[r*c 3]);

            %Calculate the likelihoods that all the pixels are foreground or
            %background.
            likelihood_f = pdf(gmm_f,window_channels);
            likelihood_b = pdf(gmm_b,window_channels);
            prob = likelihood_f./(likelihood_f+likelihood_b);
            %Reshape prob matrix to use it in final equation as row x col
            %instead of n x 1
            prob = reshape(prob, [WindowWidth+1 WindowWidth+1]);

            %Add these to the struct in case that helps later.
        end
    end
    new_shape_confidences = ...
        initShapeConfidences(NewLocalWindows, warpedMaskOutline, WindowWidth, SigmaMin, A, fcutoff, R);
end