function ColorModels = initializeColorModels(IMG, Mask, MaskOutline, LocalWindows, BoundaryWidth, WindowWidth)
% INITIALIZAECOLORMODELS Initialize color models.  ColorModels is a struct you should define yourself.
%
% Must define a field ColorModels.Confidences: a cell array of the color confidence map for each local window.
    %% Variables
    SIGMA_C = WindowWidth/2;
    REG = .001;
    NUM_GAUSS = 3;
    IMG = rgb2lab(IMG);
    
    dx_init = bwdist(MaskOutline);
    
    %Just a visualization for the mask (fore/back).
    figure
    imshow(Mask);
    for window = 1:length(LocalWindows)
        %% Gather Pixels
        %Get the x,y coordinate of this window
        x_w = LocalWindows(window, 1);
        y_w = LocalWindows(window, 2);
        
        foreground = [];
        background = [];
        middle = [(y_w + SIGMA_C) (x_w + SIGMA_C)];
        
        %We draw this window with the x and y coordinates as the center.
        %NOTE: SIGMA_C is equal to WindowWidth/2. I just used this to save
        %space.
        Win = (IMG((middle(1) - SIGMA_C):(middle(1) + SIGMA_C), ...
            (middle(2) - SIGMA_C):(middle(2) + SIGMA_C),:));
        
        Win_mask = Mask((middle(1) - SIGMA_C):(middle(1) + SIGMA_C), ...
            (middle(2) - SIGMA_C):(middle(2) + SIGMA_C),:);
        
        d_x = dx_init((middle(1) - SIGMA_C):(middle(1) + SIGMA_C), ...
            (middle(2) - SIGMA_C):(middle(2) + SIGMA_C));
       
        %Iterate over the window (Win).
        disp(Win_mask);
        for x = 1:size(Win,1)
            for y = 1:size(Win,2)
                %Get the pixel values.
                pixel = impixel(Win, x, y);
                disp(pixel);
                
                %Append the channel values to their appropriate
                %classification.
                if Win_mask(x, y) == 1 && d_x(x, y) > BoundaryWidth
                    foreground = vertcat(foreground, pixel);
                elseif Win_mask(x, y) == 0 && d_x(x, y) > BoundaryWidth
                    background = vertcat(background, pixel);
                end
            end
        end
        
        %Should be a reasonable value given the window
        disp("foreground size: " + size(foreground));
        disp("background size: " + size(background));
        
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
        ColorModels(window).gmm_f = gmm_f;
        ColorModels(window).gmm_b = gmm_b;
        ColorModels(window).prob = prob;
        ColorModels(window).dist = d_x;
        disp("Prob size (reshaped): " + size(ColorModels(window).prob));

        %% Calculate Color Model Confidence
        
        %No clue what I did from here on
        top = 0;
        bot = 0;
        
        for row = 1:size(Win, 1)
            for col = 1:size(Win, 2)
                d = exp(-d_x(row,col)^2 / (SIGMA_C^2));
                top = top + (abs(Win(row,col) - ColorModels(window).prob(row,col)) * d);
                bot = bot + d;
            end
        end
        confidence = 1 - (top/bot);
        
        ColorModels(window).Confidences = confidence;
    end
end

