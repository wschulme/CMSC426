function plotGMM()   
    loadFileName = 'GMMmodel.mat';
    load(loadFileName, 'mu', 'sigma', 'pie' , 'K');
    figure; 
    
    hold on;
    for i=1:K
        plot_gaussian_ellipsoid(mu(i,:), sigma{i})
    end
    hold off;
end