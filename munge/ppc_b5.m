function [data] = ppc_b5(studyDir)
% PPC_B5.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocess b5 data for model specification via mfit
%
% USAGE: [data] = ppc_b5(studyDir)
%
% INPUT:
%       studyDir = path to top level of git repo [string]
%
% OUTPUT:
%       data = data structure w/ correct fields for mfit
%
%
% written: ~#wem3#~ [20170203]
% edited:  ~#wem3#~ [20170915] Adapted for b5 | bandit_either_3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up paths
rawDataDir = fullfile(studyDir,'raw','b5');
cleanDataDir = fullfile(studyDir,'clean');
stdColsPy = ['python /Users/wem3/Developer/zach/csv_ops/standardize_columns.py'];
baseFile = fullfile(studyDir,'munge','b5_trial_headers.csv');
tmpFile = fullfile(cleanDataDir,'tmp.csv');
b5_trialFile = fullfile(cleanDataDir,'b5_trial_data.csv');
b5_demoFile  = fullfile(cleanDataDir,'b5_demo.csv');
b5_doorFile  = fullfile(cleanDataDir,'b5_door.csv');
b5_rewardFile = fullfile(cleanDataDir,'b5_reward_probs.csv');
b5_idFile1 = fullfile(cleanDataDir,'b5_id1.csv');
b5_idFile2 = fullfile(cleanDataDir,'b5_id2.csv');
b5_idFile3 = fullfile(cleanDataDir,'b5_id3.csv');
b5_idFile4 = fullfile(cleanDataDir,'b5_id4.csv');
b5_mcFile = fullfile(cleanDataDir,'b5_mc.csv');
% get demographic data (cat raw data, write temp .csv & read in)
% system(['cat *.csv | grep "survey-text-sam" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,11,38,39,40 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b5_demo.csv')]);
% call Zach's python function to standardize desired columns
system([stdColsPy,' -i ',rawDataDir,' -o ',tmpFile,' -b ',baseFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,3,5,6,7,8  > ',b5_trialFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,17,18,19,20,21,22,23,24  > ',b5_rewardFile]);
system(['grep "0.0-402.0" ',tmpFile,' | cut -d'','' -f 1,13,14,15 > ',b5_demoFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,9,10,11,12 > ',b5_doorFile]);
system(['grep "0.0-9.0-0.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b5_idFile1]);
system(['grep "0.0-9.0-1.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b5_idFile2]);
system(['grep "0.0-401.0-0.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b5_idFile3]);
system(['grep "0.0-401.0-1.0" ',tmpFile,' | cut -d'','' -f 1,25,26,27 > ',b5_idFile4]);
system(['grep "0.0-403.0" ',tmpFile,' | cut -d'','' -f 1,28 > ',b5_mcFile]);

b5_demo = readtable(b5_demoFile,'Format','%s%s%f%s');
b5_door = readtable(b5_doorFile,'Format','%s%f%f%f%f');
b5_demo.Properties.VariableNames = {'subID','gender','age','race'};
b5_door.Properties.VariableNames = {'subID','door1','door2','door3','door4'};
door(:,1)=b5_door.door1;
door(:,2)=b5_door.door2;
door(:,3)=b5_door.door3;
door(:,4)=b5_door.door4;
tmp = csvread(b5_trialFile);
rew = csvread(b5_rewardFile);
id1 = csvread(b5_idFile1);
id2 = csvread(b5_idFile2);
id3 = csvread(b5_idFile3);
id4 = csvread(b5_idFile4);
mc = csvread(b5_mcFile);
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
subList=str2num(char(b5_demo.subID));

% init nan fields in b5_demo
b5_demo.gems = nan(height(b5_demo),1);
b5_demo.bomb = nan(height(b5_demo),1);
b5_demo.payout = nan(height(b5_demo),1);
b5_demo.meanRT = nan(height(b5_demo),1);
b5_demo.totalRT = nan(height(b5_demo),1);
b5_demo.idZur1 = id1(:,[2:4]);
b5_demo.idNyx1 = id2(:,[2:4]);
b5_demo.idZur2 = id3(:,[2:4]);
b5_demo.idNyx2 = id4(:,[2:4]);


% loop over b5_trial
for s = 1:height(b5_demo)
    % for data structure to use w/ mfit
    subject.subID = b5_demo.subID{s};
    subject.age = b5_demo.age(s);
    subject.sex = b5_demo.gender{s};
    subject.race = b5_demo.race{s};
    subject.mc = mc(s,2);
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
  data(s).subject.igbias = mean([b5_demo.idZur1(s,:),b5_demo.idZur2(s,:)]) - mean([b5_demo.idNyx1(s,:),b5_demo.idNyx2(s,:)]);
  data(s).subject.Zur1 = mean(b5_demo.idZur1(s,:));
  data(s).subject.Zur2 = mean(b5_demo.idZur2(s,:));
  data(s).subject.Nyx1 = mean(b5_demo.idNyx1(s,:));
  data(s).subject.Nyx2 = mean(b5_demo.idNyx2(s,:));
  data(s).subject.pGems = sum(data(s).subject.cFreq.*[.8 .6 .4 .2]);
end


% clean up temporary .csv files
system(['rm ',tmpFile]);
system(['rm ',b5_demoFile]);
system(['rm ',b5_doorFile]);
system(['rm ',b5_rewardFile]);
%system(['rm ',b5_trialFile]);
system(['rm ',b5_idFile1]);
system(['rm ',b5_idFile2]);
system(['rm ',b5_idFile3]);
system(['rm ',b5_idFile4]);
system(['rm ',b5_mcFile]);
