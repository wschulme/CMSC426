
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
function p = plot_corners(I, NBest)
    % default is 0.01
    quality = 0.0001
    features = detectHarrisFeatures(I, 'MinQuality', quality);
    metric = features.Metric
    points = features.Location;
    
    x = points(:,1);
    y = points(:,2);
    
    % strongest = features.selectStrongest(NStrong);
    imshow(I)
    hold on
    plot(features)
    hold off

    NStrong = size(x, 1);
    radius = Inf(NStrong, 1);

    for i = 1:NStrong
     for j = 1:NStrong
        if metric(j) > metric(i)
          ED = (y(j) - y(i))^2 + (x(j) - x(i))^2;
          if (ED < radius(i))
            radius(i) = ED;
          end
        end
     end
    end

    [RadiusValue, RadiusIdx] = sort(radius, 'descend')
    x = x(RadiusIdx(1:NBest))
    y = y(RadiusIdx(1:NBest))
    p = [x, y]

    imshow(I)
    hold on
    plot(p)
    hold off
end
