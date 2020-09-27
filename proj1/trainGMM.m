function trainGMM(K)
    clear
    clc
    close all

    selector = strcat('train_images', '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    saveFileName = 'GMMmodel.mat';
    
    % TODO: determine convergence criteria
    %E = 0; % convergence criteria
 
    % TODO: initialize all variables below using train
    % Initialize Model; scaling factor, gaussian mean & covariance
    %load(saveFileName, 'pie', 'mu', 'sigma'); % I put it as pie since matlab has preexisting pi
    max_iters = 7;
    prior = .5;
    %weight = zeros();   % cluster weight, ??? dimensions
    
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
    
    %a_ij is weight for data point j and gaussian model i
    while (i <= max_iters) && (abs(mu-prevMu) > e) % these are still wrong
    
        % E step
        % Go through for each image
        for img = 1:imgN

            %For each image we are going to create a (x, y) matrix for each
            %pixel, where each pixel will have an array of items of length K
            %for the number of gaussians
            imgPath = fullfile(path(img).folder, path(img).name);
            I = imread(imgPath);

            % Get Dims
            sz = size(I);
            width = sz(1);
            height = sz(2);

            % Gaussian array
            gaus = zeros(width, height, K);

            % We go through each pixel to get the different gaussians
            for x=1:width
                for y=1:height
                    % Total gaussian is the bottom part of the 
                    total_gaussian = 0 %what shape??? Is this just an int?

                    % For each different gaussian
                    for g = 1:K

                        %Form RGB value
                        ex = [double(I(x,y,1)); double(I(x,y,2)); double(I(x,y,3))];
                        l = likelihood(ex, sigma, mu, 3);
                        %p = prob(l,prior);
                        %Does our model consider it orange?
                        %if p >= threshold
                            %If so, color it white in the prediction
                            %prediction(x,y) = 1;
                        %end

                        % We save the numerator of a_ij first so we can
                        % divide later
                        gaus(x,y,g) = pie{K}*l;
                        total_gaussian = total_gaussian + pie{K}*l;

                    end

                    % We finally divide the pixel's individual gaussian by
                    % the total
                    a_ij = I(x,y,:)./total_gaussian;

                end

            end

        end
        
        % M step
        
    
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