function [mask, LocalWindows, ColorModels, ShapeConfidences] = ...
    updateModels(...
        NewLocalWindows, ...
        LocalWindows, ...
        CurrentFrame, ...
        warpedMask, ...      %L^t+1
        warpedMaskOutline, ... 
        WindowWidth, ...
        ColorModels, ...
        ShapeConfidences, ...
        ProbMaskThreshold, ...
        fcutoff, ...
        SigmaMin, ...
        R, ...
        A, ...
        BoundaryWidth ...
    )
% UPDATEMODELS: update shape and color models, and apply the result to generate a new mask.
% Feel free to redefine this as several different functions if you prefer.
%% Variables
    SIGMA_C = WindowWidth/2;
    REG = .001;
    NUM_GAUSS = 3;
    IMG = rgb2lab(CurrentFrame);
    [x1,y1,z1] = size(IMG); %dimensions of the image
    dx_init = bwdist(warpedMaskOutline);
    upper_thresh = .75;
    lower_thresh = .25;
    %confidence_arr = {};
    
    % Just a visualization for the mask (fore/back).
    imshow(warpedMask);

    %% Previous + New Frames
    for window = 1:length(NewLocalWindows)
        disp("Updating Window: ");
        disp(window);
        x_w = NewLocalWindows(window, 1);
        y_w = NewLocalWindows(window, 2);
        
        previous_gmm_f = ColorModels.gmm_f{window};
        previous_gmm_b = ColorModels.gmm_b{window};
        
        old_num_f = 0;
        new_num_f = 0;
        
        %get the center of the window +/- WindowWidth/2 to get the upper
        %and lower bound of the window
        %x_lower = ceil(NewLocalWindows(window,1) - WindowWidth/2);
        %x_upper = ceil(NewLocalWindows(window,1) + WindowWidth/2);
        %y_lower = ceil(NewLocalWindows(window,2) - WindowWidth/2);
        %y_upper = ceil(NewLocalWindows(window,2) + WindowWidth/2);
        %if x_lower < 1
        %    x_lower = 1;
        %end
        %if x_upper > x1
        %    x_upper = x1;
        %end
        %if y_lower < 1
        %    y_lower = 1;
        %end
        %if y_upper > y1
        %    y_upper = y1;
        %end
        
        new_foreground = [];
        new_background = [];
        
        %get the center of the window +/- WindowWidth/2 to get the upper
        %and lower bound of the window so we can iterate over each pixel in
        %window to get the number of foreground pixels
        win_lower_x = ceil(x_w - SIGMA_C);
        win_upper_x = ceil(x_w + SIGMA_C);
        win_lower_y = ceil(y_w - SIGMA_C);
        win_upper_y = ceil(y_w + SIGMA_C);
        if win_lower_x < 1
            win_lower_x = 1;
        end
        if win_upper_x > x1
            win_upper_x = x1;
        end
        if win_lower_y < 1
            win_lower_y = 1;
        end
        if win_upper_y > y1
            win_upper_y = y1;
        end
        
        %WindowWidthX = win_upper_x - win_lower_x
        %WindowWidthY = win_upper_y - win_lower_y
        
        Win = (IMG(win_lower_x:win_upper_x, win_lower_y:win_upper_y,:));
        %Win_mask = (warpedMask(win_lower_x:win_upper_x, win_lower_y:win_upper_y,:));
        d_x = (dx_init(win_lower_x:win_upper_x, win_lower_y:win_upper_y,:));
        
        
        %Iterate over the window (Win). and finding foreground pixels using
        %old gmm
        
        [r, c, ~] = size(Win);
        window_channels = reshape(double(Win),[r*c 3]);
        
        %Calculate the likelihoods that all the pixels are foreground or
        %background.
        likelihood_f = pdf(previous_gmm_f,window_channels);
        likelihood_b = pdf(previous_gmm_b,window_channels);
        prob = likelihood_f./(likelihood_f+likelihood_b);
        
        %Reshape prob matrix to use it in final equation as row x col
        %instead of n x 1
        prob = reshape(prob, [WindowWidth+1 WindowWidth+1]);
        
        for x = 1:size(Win,1)
            for y = 1:size(Win,2)
                x_img = floor(x_w - SIGMA_C + x);
                y_img = floor(y_w - SIGMA_C + y);
                pixel = impixel(IMG, x_img, y_img);
                if prob(x,y) > upper_thresh 
                    % && Win_mask(x_img, y_img) == 0 && d_x(x_img, y_img) > BoundaryWidth
                    vertcat(new_foreground, pixel);
                    old_num_f = old_num_f + 1;
                elseif prob(x,y) > lower_thresh
                    % && Win_mask(x_img, y_img) == 0 && d_x(x_img, y_img) > BoundaryWidth
                    vertcat(new_background, pixel);
                end
            end
        end
        
       
        
        % can't find gmm when there are less rows than columns
        [f_r, f_c] = size(new_foreground);
        [b_r, b_c] = size(new_background);
        
        if (f_r > f_c)
            new_gmm_f = fitgmdist(new_foreground, NUM_GAUSS, 'RegularizationValue', REG);
        else
            new_gmm_f = previous_gmm_f;
        end
        
        if (b_r > b_c)
            new_gmm_b = fitgmdist(new_background, NUM_GAUSS, 'RegularizationValue', REG);
        else
            new_gmm_b = previous_gmm_b;
        end
        
        likelihood_f = pdf(previous_gmm_f,window_channels);
        likelihood_b = pdf(previous_gmm_b,window_channels);
        prob = likelihood_f./(likelihood_f+likelihood_b);
        
        %Reshape prob matrix to use it in final equation as row x col
        %instead of n x 1
        prob = reshape(prob, [WindowWidth+1 WindowWidth+1]);
        
        %so we can find the foreground pixels using the new gmm
        for x = 1:WindowWidth+1
            for y = WindowWidth+1
                if prob(x,y) > upper_thresh
                    % && Win_mask(x_img, y_img) == 1 && d_x(x, y) > BoundaryWidth
                    new_num_f = new_num_f + 1;
                end
            end
        end
        
        %% Updating Color Model
        % Update ColorModel if more foreground pixels
        if (new_num_f <= old_num_f)
            % Update ColorModel gmm + fore/background
            ColorModels.gmm_f{window} = new_gmm_f;
            ColorModels.gmm_b{window} = new_gmm_b;
            ColorModels.foreground{window} = new_foreground;
            ColorModels.background{window} = new_background;
            
            [r, c, ~] = size(Win);
            window_channels = reshape(double(Win),[r*c 3]);
            
            % Update ColorModel probability
            likelihood_f = pdf(new_gmm_f,window_channels);
            likelihood_b = pdf(new_gmm_b,window_channels);
            prob = likelihood_f./(likelihood_f+likelihood_b);
            prob = reshape(prob, [WindowWidth+1 WindowWidth+1]);
            ColorModels.prob{window} = prob;
            
            % Update ColorModel distance
            ColorModels.dist{window} = d_x;
            top = 0;
            bot = 0;
            for row = 1:size(Win, 1)
                for col = 1:size(Win, 2)
                    d = exp(-d_x(row,col)^2 / (SIGMA_C^2));
                    top = top + (abs(Win(row,col) - ColorModels.prob{window}(row,col)) * d);
                    bot = bot + d;
                end
            end
            confidence = 1 - (top/bot);
            ColorModels.Confidences{window} = confidence;
        end
    end
    
    %% Updating Shape Model
    ShapeConfidences = ...
        initShapeConfidences(NewLocalWindows, ColorModels, WindowWidth, SigmaMin, A, fcutoff, R);
    
    colorconf = ColorModels.Confidences;
    
    %update shape confidence, almost exactly like initShapeConfidences
    %except I have a newSigma that I use if the color confidence is
    %reliable.
    for window = 1:length(NewLocalWindows)
        colordist = ColorModels.dist{window};
        
        % c, d, sigma
        d = colordist;
        
        NewSigma = SigmaMin + (A * (colorconf{window} - fcutoff)^R);
        
        %if colormodel is less than fcutoff confident move onto using the shape
        %model, otherwise just continue to use sigmaMin
        if (colorconf{window} < fcutoff)
            fsx = 1 - exp(-(d.^2) ./ SigmaMin.^2);
            ShapeConfidences.Sigma{window} = SigmaMin;
        else
            fsx = 1 - exp(-(d.^2) ./ NewSigma.^2);
            ShapeConfidences.Sigma{window} = NewSigma;
        end
        
        ShapeConfidences.Confidences{window} = fsx;
    end
    
    %% Merging
    numer_sum = zeros([x1 y1]);
    denom_sum = zeros([x1 y1]);
    % merging the windows
    for window = 1:length(NewLocalWindows)
        y_w = NewLocalWindows(window, 1);
        x_w = NewLocalWindows(window, 2);
        
        maskCut = (warpedMask(win_lower_x:win_upper_x, win_lower_y:win_upper_y,:));
        
        % basically just the given formula
        fsx = ShapeConfidences.Confidences{window};
        pkfx = fsx .* (maskCut) + (1 - fsx).* ColorModels.prob{window};
        epsilon = .1;
        
        Win = (IMG(win_lower_x:win_upper_x, win_lower_y:win_upper_y,:));

        % calculate numer and denom for merging formula
        for x = 1:size(Win,1)
            for y = 1:size(Win,2)
                x_img = ceil(x_w - SIGMA_C + x);
                y_img = ceil(y_w - SIGMA_C + y);
                distance_to_center = sqrt((x_img - y_w)^2 + (y_img - x_w)^2);
                numer_sum(x_img, y_img) = numer_sum(x_img, y_img) + pkfx * (distance_to_center + epsilon)^-1;
                denom_sum(x_img, y_img) = denom_sum(x_img, y_img) + (distance_to_center + epsilon)^-1;
            end
        end
    end
    
    pfx = numer_sum./denom_sum;
    LocalWindows = NewLocalWindows;
    % https://www.mathworks.com/help/images/create-binary-mask-from-grayscale-image.html
    mask = (pfx > ProbMaskThreshold);
end