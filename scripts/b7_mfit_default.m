%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------- preprocess raw data -----------------------------------%
studyDir = '/Volumes/crisp/hinl/bandit/gems_vs_bomb';
addpath(genpath(studyDir));
addpath('~/matlab/mfit');
data = ppc_b7(studyDir);
b7.data = data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nstarts=25; % number of start points for model optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b7 models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b7, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b7.results(1) = r;
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b7, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b7.results(2) = r;
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b7, Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b7.results(3) = r;
% 4. inverse temperature, stickiness, learning rate, weighting parameter
disp(['~~~~~~~~~~~~~~~~working on b7, Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(5);
r = mfit_optimize(@qlik5,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
b7.results(4) = r;
% bayesian model selection
b7.bms = mfit_bms(b7.results);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cabut cleanDataDir b7;
save b7_mfit_default.mat;