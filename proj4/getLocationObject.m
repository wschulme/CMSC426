function Location = getLocationObject(H, tag, frame)
    %Gather World Points
    p1 = H\[tag.p1,1]';
    p2 = H\[tag.p2,1]';
    p3 = H\[tag.p3,1]';
    p4 = H\[tag.p4,1]';

    %Normalize
    Location.p1 = (p1./p1(3))';
    Location.p2 = (p2./p2(3))';
    Location.p3 = (p3./p3(3))';
    Location.p4 = (p4./p4(3))';
    
    Location.H = H;
    
    Location.frame = double(frame);
end