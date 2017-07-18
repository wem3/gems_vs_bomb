function param = set_opts(model)
% SET_OPTS.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function to create parameter structure for mfit
%
% USAGE: param = set_opts(model)
%
% INPUTS: model number
%
%          all models have inverse temperature [x(1)] and stickiness [x(2)]
%           1 - single learning rate
%           2 - gems learning rate, bomb learning rate
%           3 - positive learning rate, negative learning rate
%           4 - positive gems learning rate, positive bomb learning rate
%               negative gems learning rate, negative bomb learning rate
%
% OUTPUTS: param - structure to use as input to mfit_optimize
%
% ~wem3~ [20170717]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% params 1 - 3 are the same for all models
param(1).name = 'inverse temperature'; % inverse temperature
param(1).hp = [3 2];    % hyperparameters of the gamma prior
param(1).lopGdf = @(x) sum(log(gampdf(x,param(1).hp(1),param(1).hp(2))));  % log density function for prior
param(1).lb = 1e-8; % lower bound
param(1).ub = 50;   % upper bound
param(1).fit = @(x) gamfit(x);

param(2).name = 'choice stickiness'; % perseveration parameter
param(2).hp = [0 10]; % hyperparameters of the normal prior
param(2).lopGdf = @(x) sum(log(normpdf(x,param(2).hp(1),param(2).hp(2))));  % log density function for prior
param(2).lb = -5;    % lower bound
param(2).ub = 5;     % upper bound
param(2).fit = @(x) [mean(x) std(x)];

param(3).name = 'learning rate'; % learning rate
param(3).hp = [1.2 1.2];    % hyperparameters of beta prior
param(3).lopGdf = @(x) sum(log(betapdf(x,param(3).hp(1),param(3).hp(2))));
param(3).lb = 0;
param(3).ub = 1;
param(3).fit = @(x) betafit(x);

switch model
    case 2
        param(4) = param(3);
        param(3).name = 'gems learning rate';
        param(4).name = 'bomb learning rate';
    case 3
        param(4) = param(3);
        param(3).name = 'positive learning rate';
        param(4).name = 'negative learning rate';
    case 4
        param(4) = param(3);
        param(5) = param(3);
        param(6) = param(3);
        param(3).name = 'positive gems learning rate';
        param(4).name = 'positive bomb learning rate';
        param(5).name = 'negative gems learning rate';
        param(6).name = 'negative bomb learning rate';
    case 5
        param(4) = param(3);
        param(4).name = 'gems preference weight';
    case 6
        param(4) = param(3);
        param(5) = param(3);
        param(3).name = 'positive learning rate';
        param(4).name = 'negative learning rate';
        param(5).name = 'gems preference weight';
end