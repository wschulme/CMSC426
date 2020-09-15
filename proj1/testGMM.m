function testGMM(Model,t)
    load Model % loads scaling factor, gaussian mean and covariance
    computePosterior(Model)
    getCluster(t) % use thresholding to get the orange ball
end
