function [data] = ppc_bandit(studyDir, expt)
% PPC_B7.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocess b7 data for model specification via mfit
%
% Raw data must first be cleaned by munge_raw_b7.Rmd
%
% USAGE: [data] = ppc_b7(studyDir)
%
% INPUT:
%       studyDir = path to top level of git repo [string]
%
%       expt = experiment(s) to preprocess [scalar]
%
% OUTPUT:
%       data = data structure w/ correct fields for mfit
%
%
% written: ~#wem3#~ [20171006]
% edited:  ~#wem3#~ [20171006]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up paths
cleanDataDir = fullfile(studyDir,'clean');

% read R-munged data (created by munge_raw_bandit.Rmd)
demo = readtable(fullfile(cleanDataDir,['b',num2str(expt),'_demo.csv']));
trial = readtable(fullfile(cleanDataDir,'b',num2str(expt),'_trial_data_R.csv'));

% loop over subjects
for s = 1:height(demo)
    % for data structure to use w/ mfit
    d.subID = demo.subjID(s);
    c = trial.respChoiceNum(trial.subjID==demo.subjID(s));
    d.N = length(c);
    d.c = c + 1;
    d.C = length(unique(d.c));
    gems = trial.gems(trial.subjID==demo.subjID(s));
    bombs = trial.bombs(trial.subjID==demo.subjID(s));
    d.r = [gems,bombs];
    d.rt = trial.rt(trial.subjID==demo.subjID(s));
    d.D = [demo.GainOverPainPr_0(s), demo.GainOverPainPr_1(s), demo.GainOverPainPr_2(s), demo.GainOverPainPr_3(s)];
    if find([2 3 5 6 7]==expt)
        pChose = [sum(d.c==1),sum(d.c==2),sum(d.c==3),sum(d.c==4)]./360;
        subject.cFreq = [pChose(d.D==0.8), pChose(d.D==0.6), pChose(d.D==0.4), pChose(d.D==0.2)];
        subject.pBurn = sum(subject.cFreq.*[.2 .4 .6 .8]);
    end
    if find([3:7]==expt)
        subject.igbias = mean([demo.identification_pre_ingroup(s),demo.identification_post_ingroup(s)]) ...
                       - mean([demo.identification_pre_outgroup(s),demo.identification_post_outgroup(s)]);
    end
    d.subject = subject;
    data(s) = d;
    clear d
end