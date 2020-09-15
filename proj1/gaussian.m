clear
clc
close all

%% Train
% SGTrain('train_basic_image');

%% Predict
% Grab basic image
selector = strcat('train_basic_image', '/*.jpg');
path = dir(selector);
imgN = length(path);
saveFileName = 'singleGaussModel.mat';

for i = 1:imgN
    disp(path)
    imgPath = fullfile(path(i).folder, path(i).name);
    I = imread(imgPath);
    imshow(I);
end

% Separate RGB Channels
I = medfilt3(I);

r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

% Mask
% This example is only for color Red.
Oranges = r > 80 & r < 255 & g > 0 & g < 70 & b > 0 & b < 120;
Oranges = bwmorph(Oranges, 'dilate');
figure();
imshow(Oranges),title('Single Gaussian');

%% Other Shit, Presumably