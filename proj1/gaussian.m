clear
clc
close all

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
    
    % Get Dims
    sz = size(I);
    height = I(1);
    width = I(2);

    % Get Mask
    BW = uint8(roipoly(I));

    %Mask
    r = I(:,:,1);
    g = I(:,:,2);
    b = I(:,:,3);

    maskedI = uint8(zeros(size(I))); % Initialize
    maskedI(:,:,1) = r .* BW;
    maskedI(:,:,2) = g .* BW;
    maskedI(:,:,3) = b .* BW;

    imshow(maskedI);

    % Get Mean, Covariance, Probability
    r = maskedI(:,:,1);
    g = maskedI(:,:,2);
    b = maskedI(:,:,3);
    
end