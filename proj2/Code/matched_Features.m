% Feature Descriptor
function main()
    selector = strcat('./Images/Set1', '/*.jpg');
    path = dir(selector);
    
    match(path)
end

function match(path)
    imgN = length(path);
    plots = zeros(2)
    
    %run plot_ANMS
    for i = 1:2
        imgPath = fullfile(path(i).folder, path(i).name);
        I = rgb2gray(imread(imgPath));
        %plot_corners(I, 150);
        H = fspecial('disk',40);
        blurred = imfilter(I,H,'replicate'); 
        imshow(blurred);
    end
end


%shows match
% [f1, vpts1] = extractFeatures(I1, points1);
% [f2, vpts2] = extractFeatures(I2, points2);
% indexPairs = matchFeatures(f1, f2) ;
% matchedPoints1 = vpts1(indexPairs(1:20, 1));
% matchedPoints2 = vpts2(indexPairs(1:20, 2));

   