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
 
    max_iters = 5000;
    prior = .5;
    
    e = 0.0001; % convergence criteria
    pie = rand(K,1);
    mu = rand(K,3);  
    sigma = 100*(reshape(repmat(diag(ones(3,1)),1,K),[3, 3, K]));
    alpha = zeros(K,nO);
    maxIter = 10;
    iter = 1;
    
    while iter < maxIter
        %% Expectation
        for i = 1:K
            for o = 1:nO
                ex = [orange(1,o) orange(2,o) orange(3,o)];
                a = pie(i)*mvnpdf(ex, mu(i), sigma(:,:,i));

                sum_a = 0;
                for cluster = 1:K
                    sum_a = sum_a + pie(cluster)*mvnpdf(ex, mu(cluster), sigma(:,:,cluster));
                end

                alpha(i,o)= a/sum_a;
            end
        end

        %% Maximization 
        for i=1:K
            mu(i,:) = sum((alpha(:,i).*orange))/sum(alpha(:,i));
            disp(mu(i,:));
        end
        iter = iter+1;
    end
end


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