function trainGMM(K)
    e = 0; % convergence criteria
    % Initialize Model; scaling factor, gaussian mean & covariance
    while (i <= max_iters) && (abs(Mean-prevMean) > e)
        expectation_step
        maximization_step
        i++;
    end
    % Save Model
end
