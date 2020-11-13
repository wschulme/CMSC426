function ColorModels = initializeColorModels(IMG, Mask, MaskOutline, LocalWindows, BoundaryWidth, WindowWidth)
% INITIALIZAECOLORMODELS Initialize color models.  ColorModels is a struct you should define yourself.
%
% Must define a field ColorModels.Confidences: a cell array of the color confidence map for each local window.
    %% Variables
    SIGMA_C = WindowWidth/2;
    REG = .001;
    NUM_GAUSS = 3;
    
    for window = 1:length(LocalWindows)
        x = LocalWindows(window, 1)
        y = LocalWindows(window, 2)
        
        IMG = rgb2lab(IMG((y - SIGMA_C):(y + SIGMA_C),(x - SIGMA_C):(x + SIGMA_C),:));
        %% Select Foreground and Background
        [f_r, f_c] = find(bwdist(Mask)>BoundaryWidth)
        [b_r, b_c] = find(bwdist(~Mask)>BoundaryWidth)

        %% Select RGB Values
        foreground = impixel(IMG, f_c, f_r);
        background = impixel(IMG, b_c, b_r);

        %% Compute GMM

        gmm_f = fitgmdist(foreground, NUM_GAUSS, 'RegularizationValue', REG);
        gmm_b = fitgmdist(background, NUM_GAUSS, 'RegularizationValue', REG);

        %% Apply Model
        
        [r, c, ~] = size(IMG);
        window_channels = reshape(double(IMG),[r*c 3]);

        likelihood_f = pdf(gmm_f,window_channels);
        likelihood_b = pdf(gmm_b,window_channels);

        ColorModels(window).gmm_f = gmm_f;
        ColorModels(window).gmm_b = gmm_b;
        ColorModels(window).prob = likelihood_f./(likelihood_f+likelihood_b);

        %% Calculate Color Model Confidence

        L_t = reshape(Mask(IMG),[],1)
        d = reshape(bwdist(MaskOutline(IMG)),[], 1)

        w_c = exp(-d.^2/SIGMA_C^2);
        ColorModels(window).Confidences = 1 - sum( abs(L_t-ColorModels(win).prob).*w_c )/sum(w_c);
    end
end

