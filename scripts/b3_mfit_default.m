%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------- preprocess raw data -----------------------------------%
studyDir = '/Volumes/crisp/hinl/bandit/gems_vs_bomb';
addpath(genpath(studyDir));
addpath('~/matlab/mfit');
data = ppc_b3(studyDir);
b3.data = data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nstarts=25; % number of start points for model optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b3 models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b3, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
b3.results(1) = r;
b3.results(1).epr = mfit_priorfit(r.x,param);
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b3, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
b3.results(2) = r;
b3.results(2).epr = mfit_priorfit(r.x,param);
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b3, Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
b3.results(3) = r;
b3.results(3).epr = mfit_priorfit(r.x,param);
% 4. inverse temperature, stickiness, pos gems, neg gems, pos bomb, neg bomb
disp(['~~~~~~~~~~~~~~~~working on b3, Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(4);
r = mfit_optimize(@qlik4,param,data,nstarts);
b3.results(4) = r;
b3.results(4).epr = mfit_priorfit(r.x,param);
% bayesian model selection
b3.bms = mfit_bms(b3.results);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cabut cleanDataDir b3;
save b3_mfit_default.mat;