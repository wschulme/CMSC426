function [match1,match2] = getMatchedPoints(d1, d2, p1, p2, thresh)
    sz1 = length(d1(1,:));
    sz2 = length(d2(2,:));
    match1 = [];
    match2 = [];
    for i = 1:sz1
        for j = 1:sz2
            sumSqr(j) = sum((d1(:,i) - d2(:,j)).^2);
        end
        [sortedDist, Idx] = sort(sumSqr);
        ratio = sortedDist(1)/sortedDist(2);
        if (ratio < thresh)
            match1 = [match1 ; p1(i,:)];
            match2 = [match2 ; p2(Idx(1),:)];
        end
    end
end
