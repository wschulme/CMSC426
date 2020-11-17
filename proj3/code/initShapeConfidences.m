function ShapeConfidences = initShapeConfidences(LocalWindows, ColorModels, WindowWidth, SigmaMin, A, fcutoff, R)
% INITSHAPECONFIDENCES Initialize shape confidences.  ShapeConfidences is a struct you should define yourself.
    for window = 1:length(LocalWindows)
        % Grab all ColorModels
        colorconf = ColorModels(window).Confidences;
        disp(size(colorconf));
        colordist = ColorModels(window).dist;
        y = LocalWindows(window, 1);
        x = LocalWindows(window, 2);
        
        % c, d, sigma
        confidence = colorconf;
        d = colordist;
        sigma = SigmaMin;
        
        if confidence > fcutoff
            sigma = sigma + (A * (confidence - fcutoff)^R);
        end
        
        fsx = 1 - exp(-(d.^2) ./ sigma.^2);
        
        ShapeConfidences(window).Confidences = fsx;
        ShapeConfidences(window).Sigma = sigma;
    end
    
end
