function [pano] = MyPanorama()
    clear;
    
    IMGSET = 1;
    
    selector = strcat('../Images/Set', IMGSET, '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    
    %% Constants
    N_Best = 150;
    quality = 0.0001;
    
    %% ANMS
    %for img = 1:imgN
    for img = 2:2
        imgPath = fullfile(path(i).folder, path(i).name);
        I = rgb2gray(imread(imgPath));
        
        p = AMNS(I, N_Best, quality);
    end
end
