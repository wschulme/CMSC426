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
    [x1,y1,z1] = size(IMG);
    
    %Just a visualization for the mask (fore/back).
    imshow(warpedMask);

    update_shape_confidences = ...
        initShapeConfidences(NewLocalWindows, ColorModels, WindowWidth, SigmaMin, A, fcutoff, R);

    for window = 1:length(NewLocalWindows)
        y_w = NewLocalWindows(window, 1);
        x_w = NewLocalWindows(window, 2);
        
        previous_gmm_f = fitgmdist(ColorModels{window}.foreground, NUM_GAUSS, 'RegularizationValue', REG);
        previous_gmm_b = fitgmdist(ColorModels{window}.background, NUM_GAUSS, 'RegularizationValue', REG);
        
        old_num_f = 0;
        new_num_f = 0;
        x_lower = NewLocalWindows(window,1) - WindowWidth/2;
        x_upper = NewLocalWindows(window,1) + WindowWidth/2;
        y_lower = NewLocalWindows(window,2) - WindowWidth/2;
        y_upper = NewLocalWindows(window,2) + WindowWidth/2;
        
        new_foreground = ColorModels{window}.foreground;
        new_background = ColorModels{window}.background;
        
        win_lower_x = x_w - SIGMA_C + 1;
        win_upper_x = x_w - SIGMA_C + WindowWidth;
        win_lower_y = y_w - SIGMA_C + 1;
        win_upper_y = y_w - SIGMA_C + WindowWidth;
        if win_upper_x > x1
            win_upper_x = x1;
        end
        if win_upper_y > y1
            win_upper_y = y1;
        end
        Win = (IMG(win_lower_x:win_upper_x, win_lower_y:win_upper_y,:));
        

        %Iterate over the window (Win).
        for x = 1:size(Win,1)
            for y = 1:size(Win,2)
                x_img = floor(x_w - SIGMA_C + x);
                y_img = floor(y_w - SIGMA_C + y);
                pixel = impixel(IMG, x_img, y_img);
                %[r, c, ~] = size(Win);
                %window_channels = reshape(double(Win),[r*c 3])
                %Calculate the likelihoods that all the pixels are foreground or
                %background.
                
                likelihood_f = previous_gmm_f.posterior(reshape(IMG(x_img, y_img,:), 1, 3));
                likelihood_b = previous_gmm_b.posterior(reshape(IMG(x_img, y_img,:), 1, 3));
                prob = likelihood_f./(likelihood_f+likelihood_b);
                if prob > .75 
                    vertcat(new_foreground, pixel);
                    old_num_f = old_num_f + 1;
                end
                if prob > .25
                    vertcat(new_background, pixel);
                end
            end
        end
        
        new_gmm_f = fitgmdist(new_foreground, NUM_GAUSS, 'RegularizationValue', REG);
        new_gmm_b = fitgmdist(new_background, NUM_GAUSS, 'RegularizationValue', REG);
        
        for x = x_lower:x_upper
            for y = y_lower:y_upper
                %[r, c, ~] = size(Win);
                %window_channels = reshape(double(Win),[r*c 3]);
                %pixel = impixel(IMG, x_img, y_img);
                likelihood_f = previous_gmm_f.posterior(reshape(IMG(x, y,:), 1, 3));
                likelihood_b = previous_gmm_b.posterior(reshape(IMG(x, y,:), 1, 3));
                prob = likelihood_f./(likelihood_f+likelihood_b);
                if prob > .75 
                    new_num_f = new_num_f + 1;
                end
            end
        end
        disp(new_num_f);
        disp('hello');
        disp(old_num_f);
        
    end
    
end