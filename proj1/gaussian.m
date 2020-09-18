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

% Get Mask
BW = roipoly(I);
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);
BWmat = [r g b]; % Need help getting rgb matrix from BW :)
x = [206 264 262 202];
y = [324 324 388 387];
BW = roipoly(I,x,y);
imshow(BW)
% Get Mean, Covariance, Probability
ballmean = mean(BWmat);
%ballcov =
%ballprob =
%% Other Shit, Presumably