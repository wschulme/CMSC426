function [H] = estHOld(X, x)
	% X is source / world coordinates 3x4 (homogeneous)
	% x is dest / image coordinates 2x4
    A = [X(:,1).' 0 0 0 -X(:,1).'*x(1,1);
         0 0 0 X(:,1).' -X(:,1).'*x(2,1);
         X(:,2).' 0 0 0 -X(:,2).'*x(1,2);
         0 0 0 X(:,2).' -X(:,2).'*x(2,2);
         X(:,3).' 0 0 0 -X(:,3).'*x(1,3);
         0 0 0 X(:,3).' -X(:,3).'*x(2,3);
         X(:,4).' 0 0 0 -X(:,4).'*x(1,4);
         0 0 0 X(:,4).' -X(:,4).'*x(2,4)];
    [~, ~, v] = svd(A.'*A);
    val = reshape(v(:,9),3,3)';
    H = val/(val(3,3));
end