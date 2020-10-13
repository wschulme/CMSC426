function [match1,match2] = getMatchedPoints(d1, d2, p1, p2, thresh)
    match1 = zeros(1,2);
    match2 = zeros(1,2);
    [sz,sz2] = size(d1);
    
    % Pick 1 point in image 1
    for i = 1:sz
        % Compute sum of square difference between all points in image 2
        for j = 1:64
            sumsq(j) = sum((d1(i,:)-d2(j,:)).^2);    
        end
        % Get 2 lowest distance aka 2 BEST distance
        [M,N] = sort(sumsq);
        oneMatch = M(1);
        twoMatch = M(2);
        % Keep the matched pair if below ratio thresh, else reject
        % TODO: fix coordinates
        if((oneMatch/twoMatch) < thresh)
            match1 = vertcat(match1, [p1(i,1) p1(i,2)]);
            match2 = vertcat(match2, [p2(N(1),1) p2(N(1),2)]);
        end
    end
end
