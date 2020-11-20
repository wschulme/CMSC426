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
  
    %Just a visualization for the mask (fore/back).
    imshow(warpedMask);

    %new_shape_confidences = ...
        %initShapeConfidences(NewLocalWindows, warpedMaskOutline, WindowWidth, SigmaMin, A, fcutoff, R);

    for window = 1:length(NewLocalWindows)
        y_w = LocalWindows(window, 1);
        x_w = LocalWindows(window, 2);
        
        Win = (IMG((x_w - SIGMA_C):(x_w + SIGMA_C), ...
            (y_w - SIGMA_C):(y_w + SIGMA_C),:));
        
        previous_gmm_f = fitgmdist(ColorModels{window}.foreground, NUM_GAUSS, 'RegularizationValue', REG);
        previous_gmm_b = fitgmdist(ColorModels{window}.background, NUM_GAUSS, 'RegularizationValue', REG);
        
        %Iterate over the window (Win).
        for x = 1:size(Win,1)
            for y = 1:size(Win,2)
                
                [r, c, ~] = size(Win);
                window_channels = reshape(double(Win),[r*c 3]);
                %Calculate the likelihoods that all the pixels are foreground or
                %background.
                
                likelihood_f = pdf(previous_gmm_f,window_channels);
                likelihood_b = pdf(previous_gmm_b,window_channels);
                prob = likelihood_f./(likelihood_f+likelihood_b);
                disp('prob is:');
                disp(prob);
                if prob > .75
                end
                if prob < .25
                end
            end
        end
       
    end
    %new_shape_confidences = ...
        %initShapeConfidences(NewLocalWindows, warpedMaskOutline, WindowWidth, SigmaMin, A, fcutoff, R);
end