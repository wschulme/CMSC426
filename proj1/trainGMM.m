function trainGMM(K)
    clc
    close all

    selector = strcat('train_images', '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    saveFileName = 'GMMmodel.mat';
    
    orange = [];
    % For each image
    for i = 1:1
        disp(path)
        imgPath = fullfile(path(i).folder, path(i).name);
        I = imread(imgPath);
        imshow(I);

        % Get Dims
        sz = size(I);
        width = sz(1);
        height = sz(2);

        % Form Mask
        BW = uint8(roipoly(I));

        % Get RGB values for image
        r = I(:,:,1);
        g = I(:,:,2);
        b = I(:,:,3);

        %Lowkey you don't NEED this masked image but it is good for
        %visualization. Just applying the mask to the image.
        maskedI = uint8(zeros(size(I))); 
        maskedI(:,:,1) = r .* BW;
        maskedI(:,:,2) = g .* BW;
        maskedI(:,:,3) = b .* BW;

        %imshow(maskedI);

        % Look at every pixel. If it's 1 in the roipoly image, it's orange.
        % Add it to the running list of orange pixels.
        nO = 0;
        maskedI = double(maskedI);
        for x = 1:width
            for y = 1:height
                if BW(x,y) == 1
                    %Add to list of oranges pixels
                    orange = [orange reshape(maskedI(x,y,:),3,1)];
                    %Increment how many orange pixels counted
                    nO = nO+1;
                end
            end
        end
    end
    
   orange = orange.';
   
   m = size(orange,2);
   
   idx = randperm(m);
   mu = orange(idx(1:K),:);
   
   sigma = []
   for j=1:K
       sigma{j} = cov(orange);
   end
   
   pie = ones(1,K) * (1/K);
   W = zeros(m,K);
   
   maxIter = 1000;
   for (iter = 1:maxIter)
       %E
       A = zeros(m,K);
       for j = 1:K
           A(:,j) = likelihood(orange, mu(j,:), sigma{j});
       end
       A_w = bsxfun(@times, A, pie);
       W = bsxfun(@rdivide, A_w, sum(A_w,2));
       
       %M
       prevMu = mu;
       for j = 1:K
           pie(j) = mean(W(:,j),1);
           mu(j,:) = weightedAverage(W(:, j), orange);
           
           sigma_k = zeros(3, 3);
           Xm = bsxfun(@minus, orange, mu(j, :));
           
           for i = 1 : m
                sigma_k = sigma_k + (W(i, j) .* (Xm(i, :)' * Xm(i, :)));
           end
           sigma{j} = sigma_k ./ sum(W(:, j));
       end
       if (mu == prevMu)
        break
       end
   end
   disp(mu);
end

function [ pdf ] = likelihood(X, mu, Sigma)
    meanDiff = bsxfun(@minus, X, mu);
    pdf = 1 / sqrt((2*pi)^3 * det(Sigma)) * exp(-1/2 * sum((meanDiff * inv(Sigma) .* meanDiff), 2));
end

function [ val ] = weightedAverage(weights, values)
    val = weights' * values;
    val = val ./ sum(weights, 1);   
end