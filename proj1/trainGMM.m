function trainGMM(K)
    clc;
    close all;

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
    max_iters = 5;
    prior = .5;
    K = 3;
    
    e = 0.00001; % convergence criteria
    pie = zeros(K, 1);
    mu = [];  
    sigma = [];
    
    % Initialize each gaussian with their own pie,mu,sigma in list form
    for g = 1:K
        % For each gaussian, we initially start with a random init of
        % mu, pie and sigma ie. scaling factor, mean and co-variance
        pie(g) = rand(1,1); 
        mu(:,:,g) = (255)*rand(3,1); 
        sigma(:,:,g) = 1000 + (1000*rand(3,3));
    end

    prevMu = [-999; -999; -999];
    iter = 1;
    while (iter <= max_iters) & (abs(avgDiff(mu(i,:),prevMu)) > e)
        %% Expectation
        alpha = [];
        for i = 1:K
            for o = 1:nO
                 ex = [double(orange(1,o)) ; double(orange(2,o)) ; double(orange(3,o))];
                 l = likelihood(ex,sigma(:,:,i),mu(i,:),3);
                 a = activation(l, pie, i, K, ex, sigma, mu);
                 alpha = [alpha a];
            end
        end
            prevMu = mu;

        %% Maximization

        for i = 1:K
            sumAlpha = 0;
            for o = 1:nO
               sumAlpha = sumAlpha + alpha(o);
            end

            % Find mu
            mu_i = double(zeros(3,1));
            top = 0;
            for o = 1:nO
                top = top + alpha(o)*orange(:,o);
            end
            mu_i = top/sumAlpha;
            mu(:,:,i) = mu_i;

            % Find sigma
            sigma_i = double(zeros(3,3));
            top = 0;
            for o = 1:nO
                a = orange(:,o)-mu_i;
                top = top + alpha(o)*(a*a');
            end

            sigma_i = top/sumAlpha;
            sigma(:,:,i) = sigma_i;

            % Find pi
            pi_i = sumAlpha/nO;
            iter = iter+1;
            pie(i) = pi_i;
        end

        mu
    end
end

% Helper Functions

% Bayes Rule (aka Posterior)
function p = prob(likelihood, prior)
    p = likelihood * prior;
end

% Calculate Likelihood
function l = likelihood(x,sigma,mu,N)
    a = 1/(sqrt((2*pi)^N*det(sigma)));
    b = exp(-.5*(x-mu)'*(sigma\(x-mu)));
    l = a*b;
end

function a = activation(l, pie, i, K, ex, sigma, mu)
    top = pie(i) * l;
    bottom = 0;
    for cluster = 1:K
        bottom = bottom + (pie(cluster)*likelihood(ex,sigma(:,:,cluster),mu(:,:,cluster),3));
    end
    a = top/bottom;
end

function cc = avgDiff(mu, prevMu)
    cc = mean(mu-prevMu);
end