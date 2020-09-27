function [cluster, d] = gmm(training)
    theta = 0.01; % Arbitrary
    K = 10; % Arbitrary
    clusters = {};
    if training
        %load somehow
        trainGMM(K);
    else
        % load the testing images somehow
        cluster = testGMM(Model, theta);
    end
    d = measureDepth(cluster);
    plotGMM(Model);
    cluster = cluster;
    
end
