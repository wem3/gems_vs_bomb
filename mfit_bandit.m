function [bandit] = mfit_bandit(studyDir, expt)
% MFIT_BANDIT.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% use mfit toolkit to fit models to 4-armed bandit data 
%
% Raw data must first be cleaned by munge_raw_bandit.Rmd (forthcoming)
%
% USAGE: [data] = mfit_bandit(studyDir, expt)
%
% INPUT:
%       studyDir = path to top level of git repo [string]
%
%       expt = experiment to model [scalar] ### 2 - 7 only!!! ###
%
% OUTPUT:
%       bandit = structure w/ data & results
%
%
% written: ~#wem3#~ [20171006]
% edited:  ~#wem3#~ [20171006]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------- set paths, add mfit to path ---------------------------%
addpath(genpath(studyDir));
addpath('~/matlab/mfit');

%----------- preprocess raw data -----------------------------------%
data = ppc_bandit(studyDir);
bandit.data = data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nstarts=25; % number of start points for model optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit bandit models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. inverse temperature, stickiness, learning rate
disp(['~~~~~~~~~~~~~~~~working on b', num2str(expt), ', Model 1~~~~~~~~~~~~~~~~~~~'])
param = set_opts(1);
r = mfit_optimize(@qlik1,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
bandit.results(1) = r;
% 2. inverse temperature, stickiness, gems learning rate, bomb learning rate
disp(['~~~~~~~~~~~~~~~~working on b', num2str(expt), ', Model 2~~~~~~~~~~~~~~~~~~~'])
param = set_opts(2);
r = mfit_optimize(@qlik2,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
bandit.results(2) = r;
% 3. inverse temperature, stickiness, separate learning rates for pos/neg prediction errors
disp(['~~~~~~~~~~~~~~~~working on b', num2str(expt), ', Model 3~~~~~~~~~~~~~~~~~~~'])
param = set_opts(3);
r = mfit_optimize(@qlik3,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
bandit.results(3) = r;
% 4. inverse temperature, stickiness, learning rate, weighting parameter
disp(['~~~~~~~~~~~~~~~~working on b', num2str(expt), ', Model 4~~~~~~~~~~~~~~~~~~~'])
param = set_opts(5);
r = mfit_optimize(@qlik5,param,data,nstarts);
r.epr = mfit_priorfit(r.x,param);
bandit.results(4) = r;
% bayesian model selection
bandit.bms = mfit_bms(bandit.results);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%