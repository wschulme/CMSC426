function d = getFeatureDescriptors(p, H, I)
    d = [];
    
    [sz, ~] = size(p);
    [h, w] = size(I);
    
    for i = 1:sz
        column = p(i, 1);
        row = p(i, 2);
        
        %if ((column > 20 && column < w-20) && (row > 20 && row < h-20))
        subImage = I(row-19:row+20, column-19:column+20);
        blurred = imfilter(subImage, H, 'replicate');

        dCurr = imresize(blurred, [8 8]);
        dCurr = double(reshape(dCurr, [64,1]));

        dCurr = dCurr - mean(dCurr);
        dCurr = dCurr / std(dCurr);

        d = [d dCurr];
        %end
    end
end