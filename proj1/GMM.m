function [cluster, d] = GMM(training)
    threshold = .0000001;
    K = 5;
    cluster = {};
    if training
        trainGMM(K);
    else
        %Cluster is the predicted test images
        cluster = testGMM(threshold);
        %d = measureDepth(cluster);
    end
    plotGMM();
    
end
