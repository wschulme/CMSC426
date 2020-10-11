function [pano] = MyPanorama()
    clear;
    
    IMGSET = 1;
    
    selector = strcat('../Images/Set', num2str(IMGSET), '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    
    %% Constants
    N_Best = 150;
    quality = 0.0001;
    
    %% Detect Corners and ANMS
    %for img = 1:imgN
    for img = 2:2
        imgPath = fullfile(path(img).folder, path(img).name);
        I = rgb2gray(imread(imgPath));
        
        p = ANMS(I, N_Best, quality);
    end
end
