function [data] = ppc_b1(studyDir)
% ppc_b1.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocess b1_single data for model specification via mfit
%
% USAGE: [data] = ppc_raw_b1(studyDir)
%
% INPUT:
%       studyDir = path to top level of git repo [string]
%
% OUTPUT:
%       data = data structure w/ correct fields for mfit
%
% written: ~#wem3#~ [20170203]
% edited:  ~#wem3#~ [20170713]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up paths
rawDataDir = fullfile(studyDir,'raw','b1');
cleanDataDir = fullfile(studyDir,'clean');
codeDir = fullfile(cleanDataDir,'scripts');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% munge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get demographic data (cat raw data, write temp .csv & read in)
cd(rawDataDir);
system(['cat *.csv | grep "survey-text-sam" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,10,33,36,38 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b1_subject_data.csv')]);
b1_demo = readtable(fullfile(cleanDataDir,'b1_subject_data.csv'),'Format','%s%s%d%s%s');
b1_demo.Properties.VariableNames = {'subID','cond','age','gender','race'};
b1_demo.cond(strcmp(b1_demo.cond,'pain'))={'bomb'};
b1_demo.cond(strcmp(b1_demo.cond,'gain'))={'gems'};
% system(['rm ',fullfile(cleanDataDir,'b1_subject_data.csv')]);

% get manipulation check data (cat raw data, write temp .csv & read in)
system(['cat *.csv | grep "0.0-20.0-0.0" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,15 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'mCheck.csv')]);
mCheck = csvread(fullfile(cleanDataDir,'mCheck.csv'));
b1_demo.failMC = mCheck(:,2);
system (['rm ',(fullfile(cleanDataDir,'mCheck.csv'))]);
system (['rm ',(fullfile(cleanDataDir,'b1_subject_data.csv'))]);
% get per trial data
system(['cat *.csv | grep main_expt | cut -d'','' -f 1,7,11,15,17,18,20,21,23,24,25,27,28,29,30,31,32 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b1_trial_data.csv')]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocess for mfit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp = csvread(fullfile(cleanDataDir,'b1_trial_data.csv'));
subID = tmp(:,2);
drift = tmp(:,3);
tnum = tmp(:,9);
choice = tmp(:,4)+1;
reward = [tmp(:,5)+tmp(:,6)];
rt = tmp(:,1);
pChoice = tmp(:,7)+tmp(:,8);
pArms = [tmp(:,10)+tmp(:,11),tmp(:,12)+tmp(:,13),tmp(:,14)+tmp(:,15),tmp(:,16)+tmp(:,17)];
%system(['rm ',fullfile(cleanDataDir,'b1_trial_data.csv')]);
subList=str2num(char(b1_demo.subID));

% loop over b1_trial
for s = 1:length(subList)
    % for data structure to use w/ mfit
    subject.subID = b1_demo.subID(s);
    subject.cond = b1_demo.cond(s);
    subject.age = b1_demo.age(s);
    subject.sex = b1_demo.gender(s);
    subject.race = b1_demo.race(s);
    subject.drift = unique(drift(subID==subList(s)));
    d.N = length(choice(subID==subList(s)));
    d.C = length(unique(choice(subID==subList(s))));
    d.c = choice(subID==subList(s));
    d.r = zeros(d.N,2); % placeholder so we can make structures identical
    d.rt = rt(subID==subList(s));
    % only needed for b1
    if strcmp(subject.cond,'gems')
        d.r(:,1) = reward(subID==subList(s));
        d.pG = pArms(subID==subList(s),:);
        d.pB = zeros(size(pArms));
    elseif strcmp(subject.cond,'bomb')
        d.r(:,2) = reward(subID==subList(s));
        d.pG = pArms(subID==subList(s),:);
        d.pB = zeros(size(pArms));
    end
    d.subject = subject;
    data(s) = d;
end
cd(studyDir);