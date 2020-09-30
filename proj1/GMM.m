function [cluster, d] = GMM(training)
    threshold = .0000001;
    K = 5;
    cluster = {};
    if training
        trainGMM(K);
    else
        %Cluster is the predicted test images
        cluster = testGMM(threshold);
        d = measureDepth(cluster);
        for i = 1:length(d)
            disp(strcat('Test Image',{' '},num2str(i),{' '},'is an estimated',{' '},num2str(d(i)),{' '},'units away.'));
        end
    end
    plotGMM();
    
end
