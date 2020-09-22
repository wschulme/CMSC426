clear
clc
close all

%% Train Constant

%Change to false to load from singleGaussModel.mat
TRAIN = false;

%% Initialize

%Note, this folder can be made into more images. This file is scalable.
selector = strcat('train_basic_image', '/*.jpg');
path = dir(selector);
imgN = length(path);
saveFileName = 'singleGaussModel.mat';

%% Grab All Orange Pixels from Training Data

if(TRAIN)
    orange = [];
    for i = 1:imgN
        disp(path)
        imgPath = fullfile(path(i).folder, path(i).name);
        I = imread(imgPath);
        imshow(I);

        % Get Dims
        sz = size(I);
        height = sz(2);
        width = sz(1);

        % Get Mask
        BW = uint8(roipoly(I));

        %Mask
        r = I(:,:,1);
        g = I(:,:,2);
        b = I(:,:,3);

        %Lowkey you don't NEED this masked image but it is good for
        %visualization.
        maskedI = uint8(zeros(size(I))); 
        maskedI(:,:,1) = r .* BW;
        maskedI(:,:,2) = g .* BW;
        maskedI(:,:,3) = b .* BW;

        imshow(maskedI);

        %Add all found oranges
        nO = 0;
        maskedI = double(maskedI);
        for x = 1:width
            for y = 1:height
                if BW(x,y) == 1
                    %Add to list of "oranges" pixels
                    orange = [orange reshape(maskedI(x,y,:),3,1)];
                    %Increment how many "orange" pixels counted
                    nO = nO+1
                end
            end
        end
    end

    %% Calculate Mean and Covariance

    % mu = [r, g, b]
    mu = double(zeros(3,1));

    for i=1:nO
       mu = mu + orange(:,i);
    end

    mu = mu/nO;
    disp("Empirical Mean");
    disp(mu);

    sigma = double(zeros(3,3));

    for i=1:nO
       a = orange(:,i)-mu;
       sigma = sigma + (a * a');
    end

    sigma = sigma/nO;
    disp("Empirical Covariance");
    disp(sigma);

    %% Save Data

    %Save mean and cov
    save(saveFileName, 'mu', 'sigma');
else
    load(saveFileName, 'mu', 'sigma');
end 

%% TODO: Predict! Literally just plug it in

%Bayes Rule etc etc