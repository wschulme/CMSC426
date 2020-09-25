function trainGMM(K)
    clear
    clc
    close all

    selector = strcat('train_images', '/*.jpg');
    path = dir(selector);
    imgN = length(path);
    saveFileName = 'GMMmodel.mat';
    
    % TODO: determine convergence criteria
    E = 0; % convergence criteria
 
    % TODO: initialize all variables below using train
    % Initialize Model; scaling factor, gaussian mean & covariance
    load(saveFileName, 'pie', 'mu', 'sigma'); % I put it as pie since matlab has preexisting pi
    max_iters = 5;
    weight = zeros();   % cluster weight, ??? dimensions
    
    while (it <= max_iters) && (abs(mu-prevMu) > E)
        expectation_step
        % TODO: E-step, j = data point idx and i = cluster idx
        
        maximization_step
        % TODO: M-step
        
        it++;
    end
    % Save Model
end