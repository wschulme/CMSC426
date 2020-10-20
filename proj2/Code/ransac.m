function [result1, result2] = ransac(m1, m2, thresh, maxIters)
    %Number of samples
    N = length(m1);
    idealInliers = N * .9;
    currInliers = [];
    bestInliers = [];
    iter = 0;
    
    disp("Running Ransac...");
    while (iter < maxIters) && (length(bestInliers) < idealInliers)
        pRand = randperm(N, 4);
        
        % 4 random features from I1
        x_source = [m1(pRand(1),1); m1(pRand(2),1); m1(pRand(3),1); m1(pRand(4),1)];
        y_source = [m1(pRand(1),2); m1(pRand(2),2); m1(pRand(3),2); m1(pRand(4),2)];
        
        % And their corresponding pair in I2
        x_dest = [m2(pRand(1),1); m2(pRand(2),1); m2(pRand(3),1); m2(pRand(4),1)];
        y_dest = [m2(pRand(1),2); m2(pRand(2),2); m2(pRand(3),2); m2(pRand(4),2)];
        
        H = est_homography(x_dest, y_dest, x_source, y_source);
        
        for j = 1:N
            %Apply homography to each feature pair
            [Hpix, Hpiy] = apply_homography(H, m1(j,1), m1(j,2));
            difference = [m2(j,1), m2(j,2)] - [Hpix, Hpiy];
            ssd = sum(difference(:).^2);
            
            %If SSD is less than the thresh?
            if ssd < thresh
                %This index is an inlier
                currInliers(end + 1) = j;
            end
        end
        
        % Does this homography result in more inliers than the most we've
        % seen?
        if length(currInliers) > length(bestInliers)
            % This set of indeces is the best
            bestInliers = currInliers;
        end
        
        currInliers = [];
        iter = iter + 1;
    end
    disp(strcat("Finished on iter: ", num2str(iter)));
    
    result1 = m1(bestInliers, :);
    result2 = m2(bestInliers, :);
end