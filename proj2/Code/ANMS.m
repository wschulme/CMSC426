function p = ANMS(I, NBest, quality)
    features = detectHarrisFeatures(I, 'MinQuality', quality);
    metric = features.Metric;
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

    [~, idx] = sort(radius, 'descend');

    x = x(idx(1:NBest));
    y = y(idx(1:NBest));
    
    p = [x(:), y(:)];
    
    imshow(I)
    hold on
    plot(p(:,1),p(:,2), 'Color', 'r', 'Marker','x', 'LineStyle','none', 'MarkerSize', 20);
    hold off
end