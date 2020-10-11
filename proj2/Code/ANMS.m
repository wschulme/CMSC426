% The goal of using ANMS is so that we can get corners that are equally
% distanced from each other, rather than just getting the NStrongest
% features from the corner algo. This allows us to have more points across
% the image for processing rather than just the locations where there may
% be more corners.
function p = ANMS(I, NBest)
    
    % Detecting features by using corneremetric Algo
    processed = cornermetric(I);
    
    % Gets max of processed matrix
    features = imregionalmax(processed);
    
    % Getting size of image
    sz = size(I)
    count = 1;
    
    % Making x and y max length possible for the image and then deleting
    % extra later as theres no way of dynamically making arrays larger
    x = zeros(sz(1)*sz(2), 1);
    y = zeros(sz(1)*sz(2), 1);

    % Going through the array and getting all the coordinates for the 1's
    for j = 1:sz(2)
        for i = 1:sz(1)
            if(features(i,j) == 1)
                x(count) = i;
                y(count) = j;
                count = count + 1;
            end
        end
    end
    
    % Deleting extra space
    x = x(1:count-1, :);
    y = y(1:count-1, :);

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
        % Switched from metric(j) > metric(i) for Harris
        %j
        %y(j)
        
        if processed(x(j), y(j)) > processed(x(i), y(i))
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
    plot(p(:,1),p(:,2), 'Color', 'r', 'Marker','x', 'LineStyle','none', 'MarkerSize', 20);
    hold off
end