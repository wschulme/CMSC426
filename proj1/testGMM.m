function cluster = testGMM(t)
    loadFileName = 'GMMmodel.mat';
    load(loadFileName, 'mu', 'sigma', 'pie' , 'K');
    
    threshold = t;
    prior = .5;
    
    selector = strcat('test_images', '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    
    cluster = {};
    for img = 1:imgN
        disp("Image")
        disp(img);
        imgPath = fullfile(path(img).folder, path(img).name);
        I = imread(imgPath);

        % Get Dims
        sz = size(I);
        height = sz(2);
        width = sz(1);
       
        prediction = zeros(width,height);
        
        %For each pixel in the test image
        for x=1:width
            for y=1:height
                %Form RGB value
                ex = [double(I(x,y,1)) double(I(x,y,2)) double(I(x,y,3))];
                clusterSum = 0;
                for i = 1:K
                    clusterSum = clusterSum + (pie(i)*mvnpdf(ex, mu(i,:), sigma{i}));
                end
                p = prior * clusterSum;
                if p >= threshold
                    prediction(x,y) = 1;
                end
            end
        end
        cluster{end + 1} = prediction;
        imshow(prediction,[]);
    end
end
