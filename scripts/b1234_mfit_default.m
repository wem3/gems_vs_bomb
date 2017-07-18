%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------- preprocess raw data -----------------------------------%
studyDir = '/Volumes/crisp/hinl/bandit/gems_vs_bomb';
addpath(genpath(studyDir));
addpath('~/matlab/mfit');
[all_data1] = ppc_b1(studyDir);
[d, excluded] = exclude_b1_subs(all_data1);
bandit(1).data = d;
[d] = ppc_b2(studyDir);
bandit(2).data = d;
[d] = ppc_b3(studyDir);
bandit(3).data = d;
[d] = ppc_b4(studyDir);
bandit(4).data = d;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nstarts=25; % number of start points for model optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b1 models, fit empirical params, do bayesian model selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = bandit(1).data;
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b1, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
bandit(1).results(1) = r;
bandit(1).results(1).epr = mfit_priorfit(r.x,param);
% 2. inverse temperature, positive learning rate, negative learning rate
disp(['~~~~~~~~~~~~~~~~working on b1, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
bandit(1).results(2) = r;
bandit(1).results(2).epr = mfit_priorfit(r.x,param);
bandit(1).bms = mfit_bms(bandit(1).results);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b2 models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = bandit(2).data;
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b2, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
bandit(2).results(1) = r;
bandit(2).results(1).epr = mfit_priorfit(r.x,param);
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b2, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
bandit(2).results(2) = r;
bandit(2).results(2).epr = mfit_priorfit(r.x,param);
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b2, Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
bandit(2).results(3) = r;
bandit(2).results(3).epr = mfit_priorfit(r.x,param);
% 4. inverse temperature, stickiness, pos gems, neg gems, pos bomb, neg bomb
disp(['~~~~~~~~~~~~~~~~working on b2, Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(4);
r = mfit_optimize(@qlik4,param,data,nstarts);
bandit(2).results(4) = r;
bandit(2).results(4).epr = mfit_priorfit(r.x,param);
% bayesian model selection
bandit(2).bms = mfit_bms(bandit(2).results);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b3 models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = bandit(3).data;
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b3, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
bandit(3).results(1) = r;
bandit(3).results(1).epr = mfit_priorfit(r.x,param);
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b3, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
bandit(3).results(2) = r;
bandit(3).results(2).epr = mfit_priorfit(r.x,param);
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b3, Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
bandit(3).results(3) = r;
bandit(3).results(3).epr = mfit_priorfit(r.x,param);
% 4. inverse temperature, stickiness, pos gems, neg gems, pos bomb, neg bomb
disp(['~~~~~~~~~~~~~~~~working on b3, Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(4);
r = mfit_optimize(@qlik4,param,data,nstarts);
bandit(3).results(4) = r;
bandit(3).results(4).epr = mfit_priorfit(r.x,param);
% bayesian model selection
bandit(3).bms = mfit_bms(bandit(3).results);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit b4 models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = bandit(4).data;
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b4, Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
bandit(4).results(1) = r;
bandit(4).results(1).epr = mfit_priorfit(r.x,param);
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b4, Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
bandit(4).results(2) = r;
bandit(4).results(2).epr = mfit_priorfit(r.x,param);
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b4, Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
bandit(4).results(3) = r;
bandit(4).results(3).epr = mfit_priorfit(r.x,param);
% 4. inverse temperature, stickiness, pos gems, neg gems, pos bomb, neg bomb
disp(['~~~~~~~~~~~~~~~~working on b4, Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik4,param,data,nstarts);
bandit(4).results(4) = r;
bandit(4).results(4).epr = mfit_priorfit(r.x,param);
% bayesian model selection
bandit(4).bms = mfit_bms(bandit(4).results);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cabut rawDataDir cleanDataDir bandit;
save b1234_mfit_default.mat;