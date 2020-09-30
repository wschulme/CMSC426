function d = measureDepth(cluster)
    %The params are THAT small
    format long
    %THAT SMALL
    warning("off");
    disp("Measuring Depth");
    f = trainDistance();
    
    sz = size(cluster);
    d = [];
    for img = 1:sz(2)
        I = cluster{img};
        I2 = bwmorph(I, 'majority');
        
        stats = regionprops('table',I2,'Centroid','MajorAxisLength','MinorAxisLength');
        
        %Find the largest circle
        [~, i] = max(stats.MajorAxisLength);
        
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        radii = diameters/2;
        
        radius = radii(1);
            
        area = pi*(radius^2);
        
        d = [d; area];
    end
    fun = @(area) f(1)*area^4 + f(2)*area^3 + f(3)*area^2 + f(4)*area + f(5);
    d = arrayfun (fun, d);
end

function f = trainDistance()
    %Import the binary images from the training set that were found with
    %GMM, K=5, threshold=.0000001
    load('distanceCluster.mat','cluster');
    
    selector = strcat('train_images', '/*.jpg');
    path = dir(selector);
    
    areas = [];
    distances = [];
    
    for item = 1:length(path)
        p = fullfile(path(item).folder, path(item).name);
        [~,name,~] = fileparts(p);
        distances = [distances str2double(name)];
    end
    
    sz = size(cluster);
    for img = 1:(sz(2))
        I = cluster{img};
        I2 = bwmorph(I, 'majority');
        
        stats = regionprops('table',I2,'Centroid','MajorAxisLength','MinorAxisLength');
        
        %Find the largest circle
        [~, i] = max(stats.MajorAxisLength);
        
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        radii = diameters/2;
        
        radius = radii(1);
            
        area = pi*(radius^2);
        
        %Add this area
        areas = [areas area];
    end
    
    f=polyfit(areas, distances,4);
end