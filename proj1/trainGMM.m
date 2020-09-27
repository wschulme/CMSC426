function trainGMM(K)
    clear
    clc
    close all

    selector = strcat('train_images', '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    saveFileName = 'GMMmodel.mat';
    
    orange = [];
    % For each image
    for i = 1:imgN
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

        imshow(maskedI);

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
 
    max_iters = 100;
    prior = .5;
    
    e = 0.0001; % convergence criteria
    pie = zeros(1,K);
    mu = zeros(1,K);  
    sigma = zeros(1,K);  

    
    % Initialize each gaussian with their own pie,mu,sigma in list form
    for g = 1:K
        % For each gaussian, we initially start with a random init of
        % mu, pie and sigma ie. scaling factor, mean and co-variance
        pie{g} = rand(3,1); 
        mu{g} = 1 + (K-1)*rand(1,1); 
        sigma{g} = rand(3);
    end
    
    alpha = zeroes(size(orange));
    i = 0;
    
    while (i <= max_iters) && (abs(mu-prevMu) > e) % these are still wrong
    %% Expectation
        for pixel = 1:n0
                
        end 
    end  
end

% Helper Functions

% Bayes Rule (aka Posterior)
function p = prob(likelihood, prior)
    %top = likelihood * prior;
    %bottom = (likelihood * prior) + (likelihood * (1-prior));
    %p = top / bottom;
    p = likelihood * prior;
end

% Calculate Likelihood
function l = likelihood(x,sigma,mu,N)
    a = 1/(sqrt((2*pi)^N*det(sigma)));
    b = exp(-.5*(x-mu)'*(sigma\(x-mu)));
    l = a*b;
end