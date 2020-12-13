function H = getHomography(X,x)
    % X: World n x 3
	% x: Image n x 4
    X = X';
    x = x';
    sizeX = size(X);
    
    A = [];
    for i = 1:sizeX(2)
        A = [A; X(:,i).' 0 0 0 -X(:,i).'*x(1,i);
            0 0 0 X(:,i).' -X(:,i).'*x(2,i)];
    end
    
    [~, ~, V] = svd(A.'*A);
    rawH = reshape(V(:,9),3,3)';
    H = rawH/(rawH(3,3));
end