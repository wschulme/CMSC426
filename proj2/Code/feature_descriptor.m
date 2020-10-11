% Feature Descriptor
% Currently a working peice of code. Some of this code is suppose to be in
% MyPanorama but in here for ease of use. This should get the Feature
% Descriptor as mentioned in part 3 and be able to generate 40x40 blurred
% sections.

function f = features(path)
    imgN = length(path);
    plots = zeros(2)
    
    %run plot_ANMS
    for i = 1:2
        imgPath = fullfile(path(i).folder, path(i).name);
        I = rgb2gray(imread(imgPath));
        %plot_corners(I, 150);
        % Generating blurred section using fspecial and then applyin with
        % imfilter, IDK wtf this doing tho cuz its suppose to be in 40x40
        % sections, but i think its making a 40x40 area to read blur data
        % from (vs just applying to a 40x40 area)
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

   