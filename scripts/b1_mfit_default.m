%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------- preprocess raw data -----------------------------------%
studyDir = '/Volumes/crisp/hinl/bandit/gems_vs_bomb';
addpath(genpath(studyDir));
addpath('~/matlab/mfit');
[all_data] = ppc_b1(studyDir);
[data, excluded] = exclude_b1_subs(all_data);
b1.data = data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nstarts=25; % number of start points for model optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b1 models, fit empirical params, do bayesian model selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b1, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b1.results(1) = r;

% 2. inverse temperature, stickiness, positive learning rate, negative learning rate
disp(['~~~~~~~~~~~~~~~~working on b1, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b1.results(2) = r;

% Bayesian model selection, save output
b1.bms = mfit_bms(b1.results);
cabut b1 studyDir
save b1_mfit_default.mat;