function [NewLocalWindows] = localFlowWarp(WarpedPrevFrame, CurrentFrame, LocalWindows, Mask, Width)
% LOCALFLOWWARP Calculate local window movement based on optical flow between frames.
    
    opticFlow = opticalFlowFarneback;
    disp(opticFlow);
    estimateFlow(opticFlow, rgb2gray(WarpedPrevFrame));
    flow = estimateFlow(opticFlow,rgb2gray(CurrentFrame));
    
    NewLocalWindows = zeros(length(LocalWindows),2);
    for window = 1:length(LocalWindows)
        x_w = LocalWindows(window, 1);
        y_w = LocalWindows(window, 2);
        
        radius = round(Width/2);
        mean_Vx = 0;
        mean_Vy = 0;
        count = 1;
        
        for x = x_w - radius: x_w + radius
            for y = y_w - radius: y_w + radius
                if Mask(x, y) == 1
                    mean_Vx = mean_Vx + flow.Vx(x,y);
                    mean_Vy = mean_Vy + flow.Vy(x,y);
                    count = count + 1;
                end
            end
        end
        
        mean_Vx = mean_Vx / count;
        mean_Vy = mean_Vy / count;
        
        NewLocalWindows(window,1) = x_w + mean_Vx;
        NewLocalWindows(window,2) = y_w + mean_Vy;
    end
end

