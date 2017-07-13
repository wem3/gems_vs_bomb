function [data, demo] = ppc_raw_b2(studyDir)
% PPC_RAW_b3.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocess b2_single data for model specification via mfit
%
% USAGE: [data, demo] = ppc_raw_b2(studyDir)
%
% INPUT:
%       studyDir = path to top level of git repo [string]
%
% OUTPUT:
%       data = data structure w/ correct fields for mfit
%       demo = table object w/ per subject data
%
%
% written: ~#wem3#~ [20170203]
% edited:  ~#wem3#~ [20170323] Adapted for b2 | bandit_either
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rawDataDir = fullfile(studyDir,'raw_data','bandit_either','task');
cleanDataDir = fullfile(studyDir,'data_analysis','bandit_either');
stdColsPy = ['python /Users/wem3/Developer/zach/csv_ops/standardize_columns.py'];
baseFile = fullfile(cleanDataDir,'b2_trial_headers.csv');
tmpFile = fullfile(cleanDataDir,'tmp.csv');
b2_trialFile = fullfile(cleanDataDir,'b2_trials.csv');
b2_demoFile  = fullfile(cleanDataDir,'b2_demo.csv');
b2_doorFile  = fullfile(cleanDataDir,'b2_door.csv');
% get demographic data (cat raw data, write temp .csv & read in)
% system(['cat *.csv | grep "survey-text-sam" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,11,38,39,40 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b2_demo.csv')]);
% call Zach's python function to standardize desired columns
system([stdColsPy,' -i ',rawDataDir,' -o ',tmpFile,' -b ',baseFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,3,5,6,7,8 > ',b2_trialFile]);
system(['grep "0.0-401.0" ',tmpFile,' | cut -d'','' -f 1,2,13,14,15 > ',b2_demoFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,9,10,11,12 > ',b2_doorFile]);

b2_demo = readtable(b2_demoFile,'Format','%s%d%s%d%s');
b2_door = readtable(b2_doorFile,'Format','%s%f%f%f%f');
b2_demo.Properties.VariableNames = {'subID','drift','gender','age','race'};

tmp = csvread(b2_trialFile);
door = csvread(b2_doorFile);
subID = tmp(:,1);
tnum = tmp(:,2);
choice = tmp(:,3)+1;
reward = [tmp(:,4:5)];
rt = tmp(:,6);

% turn subID strings back into numbers
subList=str2num(char(b2_demo.subID));

% init nan fields in b2_demo
b2_demo.gems = nan(height(b2_demo),1);
b2_demo.bomb = nan(height(b2_demo),1);
b2_demo.payout = nan(height(b2_demo),1);
b2_demo.meanRT = nan(height(b2_demo),1);
b2_demo.totalRT = nan(height(b2_demo),1);


% loop over b2_trial
for s = 1:height(b2_demo)
    % for data structure to use w/ mfit
    d.subID = b2_demo.subID{s};
    d.drift = b2_demo.drift(s);
    d.N = length(choice(subID==subList(s)));
    d.C = length(unique(choice(subID==subList(s))));
    d.c = choice(subID==subList(s));
    d.r = reward(subID==subList(s),:);
    d.rt = rt(subID==subList(s));
    d.pGems = door( (1 + 360*(s-1)) ,2:5);
    data(s) = d;
    % update b2_demo w/ payout, meanRT, totalRT
    b2_demo.gems(s) = sum(d.r(:,1));
    b2_demo.bomb(s) = sum(d.r(:,2));
    b2_demo.payout(s) = b2_demo.gems(s)+b2_demo.bomb(s);
    b2_demo.meanRT(s) = mean(d.rt);
    b2_demo.totalRT(s) = sum(d.rt);
end
demo = b2_demo;

% Compute percent of choices per door, and then match based on door's pGems
gDoor = nan(length(data),4);
for s = 1:length(data)
  pChose = [sum(data(s).c==1),sum(data(s).c==2),sum(data(s).c==3),sum(data(s).c==4)]./360;
  gDoor(s,1) = pChose(data(s).pGems==0.8);
  gDoor(s,2) = pChose(data(s).pGems==0.6);
  gDoor(s,3) = pChose(data(s).pGems==0.4);
  gDoor(s,4) = pChose(data(s).pGems==0.2);
end
demo.gDoor = gDoor;

% clean up temporary .csv files
system(['rm ',tmpFile]);
system(['rm ',b2_demoFile]);
system(['rm ',b2_doorFile]);
system(['rm ',b2_trialFile]);

%cd(cleanDataDir);