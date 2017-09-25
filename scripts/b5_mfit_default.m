%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------- preprocess raw data -----------------------------------%
studyDir = '/Volumes/crisp/hinl/bandit/gems_vs_bomb';
addpath(genpath(studyDir));
addpath('~/matlab/mfit');
data = ppc_b5(studyDir);
b5.data = data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nstarts=25; % number of start points for model optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b5 models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b5, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b5.results(1) = r;
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b5, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b5.results(2) = r;
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b5, Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b5.results(3) = r;
% 4. inverse temperature, stickiness, learning rate, weighting parameter
disp(['~~~~~~~~~~~~~~~~working on b5, Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(5);
r = mfit_optimize(@qlik5,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b5.results(4) = r;
% bayesian model selection
b5.bms = mfit_bms(b5.results);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cabut cleanDataDir b5;
save b5_mfit_default.mat;