function plotGMM()   
    loadFileName = 'GMMmodel.mat';
    load(loadFileName, 'mu', 'sigma', 'pie' , 'K');
    figure; 
    
    hold on;
    for i=1:K
        plot_gaussian_ellipsoid(mu(i,:), sigma{i});
    end
    view(100,36); set(gca,'proj','perspective'); grid on; 
    grid on; axis equal; axis tight;
    xlabel('R value');
    ylabel('G value');
    zlabel('B value');
    title('GMM Plot');
    hold off;
end