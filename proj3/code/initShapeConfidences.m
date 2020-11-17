function ShapeConfidences = initShapeConfidences(LocalWindows, ColorConfidences, WindowWidth, SigmaMin, A, fcutoff, R)
% INITSHAPECONFIDENCES Initialize shape confidences.  ShapeConfidences is a struct you should define yourself.
    
    for window = 1:length(LocalWindows)
        % Grab all ColorModels
        colorconf = ColorModels(window).Confidences;
        colordist = ColorModels(window).dist;
        y = LocalWindows(window, 1);
        x = LocalWindows(window, 2);
        
        % Grab all ColorModels
        confidence = colorconf(x,y);
        d = colordist(x,y);
        sigma = SigmaMin;
        
        if confidence > fcutoff
            sigma = sigma + (A * (confidence - fcutoff)^R);
        end
        
        fsx = 1 - exp(-(d.^2) ./ sigma.^2);
    end
    
    ShapeConfidences.Confidences = fsx;
    ShapeConfidences.Sigma = sigma;
    
end
