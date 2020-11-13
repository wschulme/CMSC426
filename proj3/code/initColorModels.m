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
    fore_mask = bwdist(MaskOutline)>BoundaryWidth & Mask;
    back_mask = bwdist(MaskOutline)>BoundaryWidth & ~Mask;
    
    figure
    imshow(fore_mask | back_mask);
    
    for window = 1:length(LocalWindows)
        %% Gather Pixels
        x_w = LocalWindows(window, 1);
        y_w = LocalWindows(window, 2);
        
        foreground = [];
        background = [];
        
        for x = x_w - SIGMA_C: x_w + SIGMA_C
            for y = y_w - SIGMA_C: y_w + SIGMA_C
                pixel = impixel(IMG, x, y);
                
                %LMFAO I have no idea why I need to invert this but I do
                if fore_mask(y, x) == 1
                    foreground = vertcat(foreground, pixel);
                elseif back_mask(y, x) == 1
                    background = vertcat(background, pixel);
                end
            end
        end
        
        Win = (IMG((y_w - SIGMA_C):(y_w + SIGMA_C),(x_w - SIGMA_C):(x_w + SIGMA_C),:));
        
        
        disp(size(foreground));
        disp(size(background));
        
        %% Compute GMM

        gmm_f = fitgmdist(foreground, NUM_GAUSS, 'RegularizationValue', REG);
        gmm_b = fitgmdist(background, NUM_GAUSS, 'RegularizationValue', REG);

        %% Apply Model
        
        [r, c, ~] = size(Win);
        window_channels = reshape(double(Win),[r*c 3]);

        likelihood_f = pdf(gmm_f,window_channels);
        likelihood_b = pdf(gmm_b,window_channels);

        ColorModels(window).gmm_f = gmm_f;
        ColorModels(window).gmm_b = gmm_b;
        ColorModels(window).prob = likelihood_f./(likelihood_f+likelihood_b);

        %% Calculate Color Model Confidence

        L_t = foreground;
        
        %This shit doesn't work
        d = reshape(bwdist(MaskOutline(Win)),[], 1);

        w_c = exp(-d.^2/SIGMA_C^2);
        ColorModels(window).Confidences = 1 - sum( abs(L_t-ColorModels(win).prob).*w_c )/sum(w_c);
    end
end

