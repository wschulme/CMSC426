function plotGMM(mu, sigma, K)   
    figure; 
    hold on;
    for i=1:K
        plot_gaussian_ellipsoid(mu(i,:), sigma{i})
    end
    hold off;
end