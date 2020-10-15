function H = ransac(matchedPoints1, matchedPoints2, thresh)
    i = 0;
    N = 10; % user set number
    sz = length(matchedPoints1);
    % these 4 arrays are my set of inliers
    x_I1 = [];
    y_I1 = [];
    x_I2 = [];
    y_I2 = [];
    while ( i < N)
        j = 1;
        x = zeros(4,1);
        y = zeros(4,1);
        X = zeros(4,1);
        Y = zeros(4,1);
        while (j < 5)
            rand1 = randi([1,sz]); % bc matchedPoints1 is a matrix of sz points
            rand2 = randi([1,sz]);
            x(j) = matchedPoints1(rand1, 1);
            y(j) = matchedPoints1(rand1, 2);
            X(j) = matchedPoints2(rand2, 1);
            Y(j) = matchedPoints2(rand2, 2);
            j = j + 1;
        end
        H = est_homography(X, Y, x, y);
        [Hpix, Hpiy] = apply_homography(H, x, y);
        difference = [X, Y] - [Hpix, Hpiy];
        ssd = sum(difference(:).^2);
        if (ssd < thresh) % still have to figure out what thresh should be
            x_I1 = cat(1,x_I1,x);
            y_I1 = cat(1,y_I1,y);
            x_I2 = cat(1,x_I2,x);
            y_I2 = cat(1,y_I2,y);
        end
        i = i + 1;
    end
    H = est_homography(x_I2, y_I2, x_I1, y_I1);
end