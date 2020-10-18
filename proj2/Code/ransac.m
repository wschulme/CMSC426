function [mP1, mP2, H] = ransac(matchedPoints1, matchedPoints2, thresh, I1, I2)
    i = 0;
    N = 200; % user set number
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
            rand = randi([1,sz]); % bc matchedPoints1 is a matrix of sz points
            x(j) = matchedPoints1(rand, 1);
            y(j) = matchedPoints1(rand, 2);
            X(j) = matchedPoints2(rand, 1);
            Y(j) = matchedPoints2(rand, 2);
            j = j + 1;
        end
        H = est_homography(X, Y, x, y);
        [Hpix, Hpiy] = apply_homography(H, x, y);
        difference = [X, Y] - [Hpix, Hpiy];
        ssd = sum(difference(:).^2)
        if (ssd < thresh) % still have to figure out what thresh should be
            x_I1 = cat(1,x_I1,x);
            y_I1 = cat(1,y_I1,y);
            x_I2 = cat(1,x_I2,X);
            y_I2 = cat(1,y_I2,Y);
        end
        i = i + 1;
    end
    mP1 = [x_I1, y_I1];
    mP2 = [x_I2, y_I2];
    hImage = showMatchedFeatures(I1, I2, mP1, mP2, 'montage');
    H = est_homography(x_I2, y_I2, x_I1, y_I1);
end