function Pose = getPoseParts(K,H)
    KH = K\H;
    temp = [KH(:,1) KH(:,2) cross(KH(:,1),KH(:,2))];
    [U,~,V] = svd(temp);
    R = U*[1 0 0; 0 1 0; 0 0 det(U*V.')]*V.';
    T = KH(:,3)/norm(KH(:,1),2);
    T = R'*(-T);
    
    Pose.R = R;
    Pose.T = T;
end