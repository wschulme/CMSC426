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
    
    e = 0.0001; % convergence criteria
    pie = rand(K,1);
    mu = rand(K,3);  
    sigma = zeros(K,3,3);
    for i=1:K
        m = 100*rand(3);
        sigma(i,:,:) = m*m.';
    end
    alpha = zeros(K,nO);
    maxIter = 10;
    iter = 1;
    
    while iter < maxIter
        %% Expectation
        for o = 1:nO
            for i = 1:K
                % Lmfao why in the fuck does this fix it????
                s = [sigma(i,:,1);sigma(i,:,2);sigma(i,:,3);];
                
                ex = [orange(1,o) orange(2,o) orange(3,o)];
                a = pie(i)*mvnpdf(ex, mu(i,:), s);
                
                sum_a = 0;
                for cluster = 1:K
                    % More voodoo
                    s_c = [sigma(cluster,:,1);sigma(cluster,:,2);sigma(cluster,:,3);];
                    sum_a = sum_a + pie(cluster)*mvnpdf(ex, mu(cluster,:), s_c);
                end

                alpha(i,o)= a/sum_a;
            end
        end

        %% Maximization 
        temp = zeros(1,K);
        temp = sum(alpha');
        
        % Calculate mu
        for i=1:K
            sum_mu = 0;
            for o = 1:nO
                sum_mu = sum_mu + (alpha(i,o)*orange(:,o));
            end
            mu(i,:) = sum_mu/temp(i);
        end
        
        % Calculate sigma
        for i=1:K
            sum_sig = 0;
            for o = 1:nO
                sum_sig = sum_sig + alpha(i,o)*(orange(:,o)-mu(i,:))*(orange(:,o)-mu(i,:))';
            end
            sigma(i,:,:) = sum_sig/temp(i);
        end
        pie(i) = temp(i)/nO;
        disp(mu);
        
        iter = iter+1;
    end
end