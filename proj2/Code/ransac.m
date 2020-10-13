function i = ransac(matchedPoints1, matchedPoints2, thresh)
    i = 0;
    N = 10; % user set number
    while ( i < N)
        j = 1;
        x = zeros(4,1);
        y = zeros(4,1);
        X = zeros(4,1);
        Y = zeros(4,1);
        while (j < 5)
            rand1 = randi([1,63]); % bc matchedPoints1 is a matrix of 63 points
            rand2 = randi([1,63]);
            x(j) = matchedPoints1(rand1, 1);
            y(j) = matchedPoints1(rand1, 2);
            X(j) = matchedPoints2(rand2, 1);
            Y(j) = matchedPoints2(rand2, 2);
            j = j + 1;
        end
        H = est_homography(X, Y, x, y);
        [HpiX, HpiY] = apply_homography(H, x, y);
        difference = [X, Y] - [HpiX, HpiY];
        ssd = sum(difference(:).^2)
        % have to figure out how to count the number of inliers and then
        % keep track of the largest set of inliers
        i = i + 1;
    end
end