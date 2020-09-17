function SGTrain(folder) 

    % Constants
    
    selector = strcat(folder, '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    saveFileName = 'singleGaussModel.mat';
    
    % Training
    
    for i = 1:imgN
        disp(path)
        imgPath = fullfile(path(i).folder, path(i).name);
        img = imread(imgPath);
        imshow(img);
    end
end
