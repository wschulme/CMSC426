% plot ANMS 
selector = strcat('./Images/Set1', '/*.jpg');
path = dir(selector);
imgN = length(path);

function p = plot_corners(I, NStrong)
    points = detectHarrisFeatures(I)
    
    strongest = points.selectStrongest(NStrong);
    imshow(I)
    hold on
    plot(strongest)

    r = zeros(NStrong)
    
    for i = 1:NStrong
        for j = 1:NStrong
           if C_img(y(j)), x(j)) > C_img(y(i), x(i))
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
end

