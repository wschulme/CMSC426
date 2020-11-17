function ShapeConfidences = initShapeConfidences(LocalWindows, ColorModels, WindowWidth, SigmaMin, A, fcutoff, R)
% INITSHAPECONFIDENCES Initialize shape confidences.  ShapeConfidences is a struct you should define yourself.
    colorconf = ColorModels(length(LocalWindows)+1).Confidences;
    for window = 1:length(LocalWindows)
  
        colordist = ColorModels(window).dist;
        y = LocalWindows(window, 1);
        x = LocalWindows(window, 2);
        
        % c, d, sigma
        confidence = colorconf{window};
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
