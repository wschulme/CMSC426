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

        % Masked image for visualization purposes
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
   
   %% Constants
   maxIter = 1000;
   e = .0000001;
   
   %% Random Init
   mu = rand(K,3);
   prevMu = zeros(size(mu));
   
   sigma = [];
   for j=1:K
       sigma{j} = cov(orange);
   end
   
   pie = rand(1,K);
   iter = 1;
   
   while iter < maxIter & abs(sum(mu - prevMu)) > e
       %% Expectation
       A = zeros(nO,K);
       for j = 1:K
           A(:,j) = pie(j)*mvnpdf(orange, mu(j,:), sigma{j});
       end
       A = A./sum(A,2);
       
       %% Maximization
       prevMu = mu;
       for j = 1:K
           pie(j) = mean(A(:,j),1);
           mu(j,:) = (A(:, j)' * orange)./sum(A(:,j),1);
           
           sigma_k = zeros(3, 3);
           
           inside = orange - mu(j, :);
           for i = 1 : nO
                sigma_k = sigma_k + (A(i, j) .* (inside(i, :)' * inside(i, :)));
           end
           sigma{j} = sigma_k ./ sum(A(:, j));
       end
        iter = iter + 1;
   end
   disp(mu);
   save(saveFileName, 'mu', 'sigma', 'pie');
end