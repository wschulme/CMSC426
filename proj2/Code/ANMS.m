% The goal of using ANMS is so that we can get corners that are equally
% distanced from each other, rather than just getting the NStrongest
% features from the corner algo. This allows us to have more points across
% the image for processing rather than just the locations where there may
% be more corners.
function p = ANMS(I, NBest)
    
    % Detecting features by using corneremetric Algo
    cornerScoreImg = cornermetric(I);
    
    % Gets max of processed matrix
    features = imregionalmax(cornerScoreImg);
    
    % Getting size of image
    sz = size(I);
    
    x = [];
    y = [];

    % Going through the array and getting all the coordinates for the 1's
    for i = 20:sz(1)-20
        for j = 20:sz(2)-20
            if(features(i,j) == 1)
                % We need to invert the local maxima, so we add this
                % pixel's y value to x and x value to y.
                x = [x; j];
                y = [y; i];
            end
        end
    end

    % Plot features
    imshow(I)
    hold on
    plot(features)
    hold off

    % Init variables
    NStrong = size(x, 1);
    radius = Inf(NStrong, 1);

    for i = 1:NStrong
     for j = 1:NStrong
        % We check if the metric scores are bigger between the current
        % point and the previous, if it is we then get the distances. We
        % then iteratively get smaller distances.
        
        % We have to 'undo' the inversion here as to not go out of bounds
        % in the original image.
        if cornerScoreImg(y(j), x(j)) > cornerScoreImg(y(i), x(i))
          % Calculate distance
          ED = (y(j) - y(i))^2 + (x(j) - x(i))^2;
          if (ED < radius(i))
            radius(i) = ED;
          end
        end
     end
    end

    % Sort radius in descending order
    [~, idx] = sort(radius, 'descend');

    % Get specified amount
    x = x(idx(1:NBest));
    y = y(idx(1:NBest));
    
    p = [x(:), y(:)];
    
    % Plot new spaced features
    imshow(I)
    hold on
    plot(p(:,1),p(:,2), 'Color', 'r', 'Marker','.', 'LineStyle','none', 'MarkerSize', 10);
    hold off
end