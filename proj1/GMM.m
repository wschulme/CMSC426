function [cluster, d] = GMM(training)
    threshold = .0000004;
    K = 5;
    cluster = {};
    if training
        trainGMM(K);
    else
        %Cluster is the predicted test images
        cluster = testGMM(threshold);
        %d = measureDepth(cluster);
    end
    
    %loadFileName = 'GMMmodel.mat';
    %load(loadFileName, 'mu', 'sigma', 'pie' , 'K');
    %plotGMM(mu,sigma,pie,K);
    
end
