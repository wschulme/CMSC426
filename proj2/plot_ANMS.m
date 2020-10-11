
function main()
    selector = strcat('./Images/Set1', '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    
    for i = 2:2
        imgPath = fullfile(path(i).folder, path(i).name);
        I = rgb2gray(imread(imgPath));
        plot_corners(I, 50);
    end
end

% plot ANMS 
function p = plot_corners(I, NStrong)
    points = cornermetric(I);
    Irm = imregionalmax(points)
    plot(I)
    hold on
    plot(Irm)
    hold off
end
