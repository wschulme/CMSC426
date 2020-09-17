clear
clc
close all

%% Train
% SGTrain('train_basic_image');

%% Predict
% Grab basic image folder
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

% Get Dims
sz = size(I);
height = I(1);
width = I(2);

% Separate RGB Channels
I = medfilt3(I);

r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

% Get Mask
BW = roipoly(I);
rgbMat = [r(BW) g(BW) b(BW)]

% Get Mean, Covariance, Probability

%% Other Shit, Presumably