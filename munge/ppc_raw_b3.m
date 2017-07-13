function [data, demo] = ppc_raw_b3(studyDir)
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

% set up paths
rawDataDir = fullfile(studyDir,'raw_data','bandit_either_2','task');
cleanDataDir = fullfile(studyDir,'data_analysis','bandit_either_2');
stdColsPy = ['python /Users/wem3/Developer/zach/csv_ops/standardize_columns.py'];
baseFile = fullfile(cleanDataDir,'b2_trial_headers.csv');
tmpFile = fullfile(cleanDataDir,'tmp.csv');
b2_trialFile = fullfile(cleanDataDir,'b2_trials.csv');
b2_demoFile  = fullfile(cleanDataDir,'b2_demo.csv');
b2_doorFile  = fullfile(cleanDataDir,'b2_door.csv');
b2_idFile1 = fullfile(cleanDataDir,'b2_id1.csv');
b2_idFile2 = fullfile(cleanDataDir,'b2_id2.csv');
b2_idFile3 = fullfile(cleanDataDir,'b2_id3.csv');
b2_idFile4 = fullfile(cleanDataDir,'b2_id4.csv');
% get demographic data (cat raw data, write temp .csv & read in)
% system(['cat *.csv | grep "survey-text-sam" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,11,38,39,40 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b2_demo.csv')]);
% call Zach's python function to standardize desired columns
system([stdColsPy,' -i ',rawDataDir,' -o ',tmpFile,' -b ',baseFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 6,11,18,19,44,47 > ',b2_trialFile]);
system(['grep "0.0-402.0" ',tmpFile,' | cut -d'','' -f 6,10,37,38,39 > ',b2_demoFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 6,23,24,25,26 > ',b2_doorFile]);
system(['grep "0.0-9.0-0.0" ',tmpFile,' | cut -d'','' -f 6,15,16,17 > ',b2_idFile1]);
system(['grep "0.0-9.0-1.0" ',tmpFile,' | cut -d'','' -f 6,15,16,17 > ',b2_idFile2]);
system(['grep "0.0-401.0-0.0" ',tmpFile,' | cut -d'','' -f 6,15,16,17 > ',b2_idFile3]);
system(['grep "0.0-401.0-1.0" ',tmpFile,' | cut -d'','' -f 6,15,16,17 > ',b2_idFile4]);

b2_demo = readtable(b2_demoFile,'Format','%s%d%d%s%s');
b2_door = readtable(b2_doorFile,'Format','%s%f%f%f%f');
b2_demo.Properties.VariableNames = {'subID','drift','age','race','gender'};

tmp = csvread(b2_trialFile);
door = csvread(b2_doorFile);
id1 = csvread(b2_idFile1);
id2 = csvread(b2_idFile2);
id3 = csvread(b2_idFile3);
id4 = csvread(b2_idFile4);
subID = tmp(:,1);
tnum = tmp(:,6);
choice = tmp(:,5)+1;
reward = [tmp(:,3:4)];
rt = tmp(:,2);

% turn subID strings back into numbers
subList=str2num(char(b2_demo.subID));

% init nan fields in b2_demo
b2_demo.gems = nan(height(b2_demo),1);
b2_demo.bomb = nan(height(b2_demo),1);
b2_demo.payout = nan(height(b2_demo),1);
b2_demo.meanRT = nan(height(b2_demo),1);
b2_demo.totalRT = nan(height(b2_demo),1);
b2_demo.idZur1 = id1(:,[2:4]);
b2_demo.idNyx1 = id2(:,[2:4]);
b2_demo.idZur2 = id3(:,[2:4]);
b2_demo.idNyx2 = id4(:,[2:4]);


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
system(['rm ',b2_idFile1]);
system(['rm ',b2_idFile2]);
system(['rm ',b2_idFile3]);
system(['rm ',b2_idFile4]);

% write out new .csv files: subject based & trial based
% make new trial table
% tmat = [];
% for d=1:length(data)
%     subID = repmat(data(d).subID,360,1);
%     choice = nan(360,1);
%     gems = nan(360,1);
%     bomb = nan(360,1);
%     rt = nan(360,1);
%     for t=1:length(data(d).c)
%         choice(t) = data(d).c(t);
%         gems(t) = data(d).r(t,1);
%         bomb(t) = data(d).r(t,2);
%         rt(t) = data(d).rt(t);
%     end
%     tt = table(subID, choice, gems, bomb, rt);
%     tmat = [tmat; tt];
% end
% writetable(tmat,fullfile(cleanDataDir,'b3_trial_table.csv'));

% % make new subject table
% Zur1 = nan(height(demo),1);
% Zur2 = nan(height(demo),1);
% Nyx1 = nan(height(demo),1);
% Nyx2 = nan(height(demo),1);
% gem80 = nan(height(demo),1);
% gem60 = nan(height(demo),1);
% gem40 = nan(height(demo),1);
% gem20 = nan(height(demo),1);

% for s = 1:height(demo)
%     Zur1(s) = mean(demo.idZur1(s,:));
%     Zur2(s) = mean(demo.idZur2(s,:));
%     Nyx1(s) = mean(demo.idNyx1(s,:));
%     Nyx2(s) = mean(demo.idNyx2(s,:));
%     gem80(s) = demo.gDoor(s,1);
%     gem60(s) = demo.gDoor(s,2);
%     gem40(s) = demo.gDoor(s,3);
%     gem20(s) = demo.gDoor(s,4);
% end
% subID = demo.subID;
% drift = demo.drift;
% gems = demo.gems;
% bomb = demo.bomb;
% age = demo.age;
% gender = demo.gender;
% race = demo.race;
% smat = table(subID,gems,bomb,Zur1,Zur2,Nyx1,Nyx2,gem80,gem60,gem40,gem20,drift,age,gender,race);
% writetable(smat,fullfile(cleanDataDir,'b3_subs_table.csv'));
%cd(cleanDataDir);