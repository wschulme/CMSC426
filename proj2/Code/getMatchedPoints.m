function [match1,match2] = getMatchedPoints(d1, d2, p1, p2, thresh)
    numFeatures = length(d1(1,:));
    disp(numFeatures);
    match1 = [];
    match2 = [];
    for i= 1:numFeatures
        feature = d1(:, i);
        
        sqrDiff = (feature - d2).^2;
        sumSqr = sum(sqrDiff, 2);
        [sortedDist, Idx] = sort(sumSqr);
        
        ratio = sortedDist(1)/sortedDist(2);
        if (ratio < thresh)
            match1 = [match1 ; p1(i,:)];
            match2 = [match2 ; p2(Idx(1),:)];
        end
    end
end
