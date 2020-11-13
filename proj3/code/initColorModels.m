function ColorModels = initializeColorModels(IMG, Mask, MaskOutline, LocalWindows, BoundaryWidth, WindowWidth)
% INITIALIZAECOLORMODELS Initialize color models.  ColorModels is a struct you should define yourself.
%
% Must define a field ColorModels.Confidences: a cell array of the color confidence map for each local window.
    %% Variables
    SIGMA_C = WindowWidth/2;
    REG = .001;
    NUM_GAUSS = 3;
    IMG = rgb2lab(IMG);
    
    %% Select Foreground and Background
    
    % We select the parts of the foreground and background who are greater
    % than BoundaryWidth in distance from the outline to avoid sampling
    % error.
    fore_mask = bwdist(MaskOutline)>BoundaryWidth & Mask;
    back_mask = bwdist(MaskOutline)>BoundaryWidth & ~Mask;
    
    %Just a visualization for the above.
    figure
    imshow(fore_mask | back_mask);
    
    for window = 1:length(LocalWindows)
        %% Gather Pixels
        %Get the x,y coordinate of this window
        x_w = LocalWindows(window, 1);
        y_w = LocalWindows(window, 2);
        
        foreground = [];
        background = [];
        
        %We draw this window with the x and y coordinates as the center.
        %NOTE: SIGMA_C is equal to WindowWidth/2. I just used this to save
        %space.
        Win = (IMG((y_w - SIGMA_C):(y_w + SIGMA_C),(x_w - SIGMA_C):(x_w + SIGMA_C),:));
        
        %Iterate over the window.
        for x = x_w - SIGMA_C: x_w + SIGMA_C
            for y = y_w - SIGMA_C: y_w + SIGMA_C
                %Get the pixel values.
                pixel = impixel(IMG, x, y);
                
                %LMFAO I have no idea why I need to invert these values but
                %I do.
                
                %Append the channel values to their appropriate
                %classification.
                if fore_mask(y, x) == 1
                    foreground = vertcat(foreground, pixel);
                elseif back_mask(y, x) == 1
                    background = vertcat(background, pixel);
                end
            end
        end
        
        %Should be a reasonable value given the window
        disp(size(foreground));
        disp(size(background));
        
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
        
        %Add these to the struct in case that helps later.
        ColorModels(window).gmm_f = gmm_f;
        ColorModels(window).gmm_b = gmm_b;
        ColorModels(window).prob = likelihood_f./(likelihood_f+likelihood_b);

        %% Calculate Color Model Confidence
        
        %No clue what I did from here on
        L_t = foreground;
        
        %This shit doesn't work
        d = reshape(bwdist(MaskOutline(Win)),[], 1);
        
        %These formulae are right though I think
        w_c = exp(-d.^2/SIGMA_C^2);
        ColorModels(window).Confidences = 1 - sum( abs(L_t-ColorModels(win).prob).*w_c )/sum(w_c);
    end
end

