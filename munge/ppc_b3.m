function [data] = ppc_b3(studyDir)
% PPC_B3.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocess b3 data for model specification via mfit
%
% USAGE: [data, demo] = ppc_raw_b3(studyDir)
%
% INPUT:
%       studyDir = path to top level of git repo [string]
%
% OUTPUT:
%       data = data structure w/ correct fields for mfit
%
%
% written: ~#wem3#~ [20170203]
% edited:  ~#wem3#~ [20170717] Adapted for b3 | bandit_either_2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up paths
rawDataDir = fullfile(studyDir,'raw','b3');
cleanDataDir = fullfile(studyDir,'clean');
stdColsPy = ['python /Users/wem3/Developer/zach/csv_ops/standardize_columns.py'];
baseFile = fullfile(studyDir,'munge','b3_trial_headers.csv');
tmpFile = fullfile(cleanDataDir,'tmp.csv');
b3_trialFile = fullfile(cleanDataDir,'b3_trial_data.csv');
b3_demoFile  = fullfile(cleanDataDir,'b3_demo.csv');
b3_doorFile  = fullfile(cleanDataDir,'b3_door.csv');
b3_rewardFile = fullfile(cleanDataDir,'b3_reward_probs.csv');
b3_idFile1 = fullfile(cleanDataDir,'b3_id1.csv');
b3_idFile2 = fullfile(cleanDataDir,'b3_id2.csv');
b3_idFile3 = fullfile(cleanDataDir,'b3_id3.csv');
b3_idFile4 = fullfile(cleanDataDir,'b3_id4.csv');
% get demographic data (cat raw data, write temp .csv & read in)
% system(['cat *.csv | grep "survey-text-sam" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,11,38,39,40 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b3_demo.csv')]);
% call Zach's python function to standardize desired columns
system([stdColsPy,' -i ',rawDataDir,' -o ',tmpFile,' -b ',baseFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,3,5,6,7,8  > ',b3_trialFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,17,18,19,20,21,22,23,24  > ',b3_rewardFile]);
system(['grep "0.0-402.0" ',tmpFile,' | cut -d'','' -f 1,13,14,15 > ',b3_demoFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,9,10,11,12 > ',b3_doorFile]);
system(['grep "0.0-9.0-0.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b3_idFile1]);
system(['grep "0.0-9.0-1.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b3_idFile2]);
system(['grep "0.0-401.0-0.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b3_idFile3]);
system(['grep "0.0-401.0-1.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b3_idFile4]);

b3_demo = readtable(b3_demoFile,'Format','%s%s%f%s');
b3_door = readtable(b3_doorFile,'Format','%s%f%f%f%f');
b3_demo.Properties.VariableNames = {'subID','gender','age','race'};
b3_door.Properties.VariableNames = {'subID','door1','door2','door3','door4'};
door(:,1)=b3_door.door1;
door(:,2)=b3_door.door2;
door(:,3)=b3_door.door3;
door(:,4)=b3_door.door4;
tmp = csvread(b3_trialFile);
rew = csvread(b3_rewardFile);
id1 = csvread(b3_idFile1);
id2 = csvread(b3_idFile2);
id3 = csvread(b3_idFile3);
id4 = csvread(b3_idFile4);
subID = tmp(:,1);
tnum = tmp(:,2);
choice = tmp(:,3)+1;
reward = [tmp(:,4:5)];
rt = tmp(:,6);
%pG = temp(:,[7,9,11,13]);
%pB = rew(:,[8,10,12,14]);
pB = rew(:,[3,5,7,9]);
pG = rew(:,[2,4,6,8]);
pR = pG + pB;
% turn subID strings back into numbers
subList=str2num(char(b3_demo.subID));

% init nan fields in b3_demo
b3_demo.gems = nan(height(b3_demo),1);
b3_demo.bomb = nan(height(b3_demo),1);
b3_demo.payout = nan(height(b3_demo),1);
b3_demo.meanRT = nan(height(b3_demo),1);
b3_demo.totalRT = nan(height(b3_demo),1);
b3_demo.idZur1 = id1(:,[2:4]);
b3_demo.idNyx1 = id2(:,[2:4]);
b3_demo.idZur2 = id3(:,[2:4]);
b3_demo.idNyx2 = id4(:,[2:4]);


% loop over b3_trial
for s = 1:height(b3_demo)
    % for data structure to use w/ mfit
    subject.subID = b3_demo.subID{s};
    subject.age = b3_demo.age(s);
    subject.sex = b3_demo.gender{s};
    subject.race = b3_demo.race{s};
    d.N = length(choice(subID==subList(s)));
    d.C = length(unique(choice(subID==subList(s))));
    d.c = choice(subID==subList(s));
    d.r = reward(subID==subList(s),:);
    d.rt = rt(subID==subList(s));
    D = door(subID==subList(s));
    d.D = door(1,:);
    d.pG = pR(subID==subList(s),:);
    d.pB = pR(subID==subList(s),:);
    d.subject = subject;
    data(s) = d;
end

% Compute percent of choices per door, and then match based on door's pGems
gDoor = nan(length(data),4);
for s = 1:length(data)
  pChose = [sum(data(s).c==1),sum(data(s).c==2),sum(data(s).c==3),sum(data(s).c==4)]./360;
  gDoor(s,1) = pChose(data(s).D==0.8);
  gDoor(s,2) = pChose(data(s).D==0.6);
  gDoor(s,3) = pChose(data(s).D==0.4);
  gDoor(s,4) = pChose(data(s).D==0.2);
  data(s).subject.cFreq = gDoor(s,:);
  data(s).subject.igbias = mean([b3_demo.idZur1(s,:),b3_demo.idZur2(s,:)]) - mean([b3_demo.idNyx1(s,:),b3_demo.idNyx2(s,:)]);
  data(s).subject.Zur1 = mean(b3_demo.idZur1(s,:));
  data(s).subject.Zur2 = mean(b3_demo.idZur2(s,:));
  data(s).subject.Nyx1 = mean(b3_demo.idNyx1(s,:));
  data(s).subject.Nyx2 = mean(b3_demo.idNyx2(s,:));
  data(s).subject.pGems = sum(data(s).subject.cFreq.*[.8 .6 .4 .2]);
end


% clean up temporary .csv files
system(['rm ',tmpFile]);
system(['rm ',b3_demoFile]);
system(['rm ',b3_doorFile]);
%system(['rm ',b3_trialFile]);
system(['rm ',b3_idFile1]);
system(['rm ',b3_idFile2]);
system(['rm ',b3_idFile3]);
system(['rm ',b3_idFile4]);