%run plot_ANMS
%shows match
[f1, vpts1] = extractFeatures(I1, points1);
[f2, vpts2] = extractFeatures(I2, points2);
indexPairs = matchFeatures(f1, f2) ;
matchedPoints1 = vpts1(indexPairs(1:20, 1));
matchedPoints2 = vpts2(indexPairs(1:20, 2));

    features = detectHarrisFeatures(I);
    points = features.Location
    
    Irm = imregionalmax(points)
    x = points(:,1)
    y = points(:,2)
    
    %strongest = features.selectStrongest(NStrong);
    imshow(I)
    hold on
    plot(features)
    %plot(strongest)
    hold off

    radius = Inf(NStrong);

    for i = 1:NStrong
     for j = 1:NStrong
         
        if C_img((y(j)), x(j)) > C_img(y(i), x(i))
          ED = (y(j) - y(i))^2 + (x(j) - x(i))^2
          if (ED < radius(i))
            radius(i) = ED;
          end
        end
     end
    end

    [RadiusValue, RadiusIdx] = sort(radius, 'descend')
    x = x(RadiusIdx(1:NBest))
    y = y(RadiusIdx(1:NBest))
    p = [y,x]
    
    imshow(I)
    hold on
    plot(p)
    hold off