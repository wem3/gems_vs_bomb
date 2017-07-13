function [data, demo] = ppc_raw_b4(studyDir)
% PPC_RAW_b4V2.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preprocess b4_single data for model specification via mfit
%
% USAGE: [data, demo] = ppc_raw_b4(studyDir)
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
% edited:  ~#wem3#~ [20170323] Adapted for b4 | bandit_double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up paths
rawDataDir = fullfile(studyDir,'raw_data','bandit_double','task');
cleanDataDir = fullfile(studyDir,'data_analysis','bandit_double');
stdColsPy = ['python /Users/wem3/Developer/zach/csv_ops/standardize_columns.py'];
baseFile = fullfile(cleanDataDir,'b4_trial_headers.csv');
tmpFile = fullfile(cleanDataDir,'tmp.csv');
b4_trialFile = fullfile(cleanDataDir,'b4_trials.csv');
b4_demoFile  = fullfile(cleanDataDir,'b4_demo.csv');
%b4_doorFile  = fullfile(cleanDataDir,'b4_door.csv');
b4_idFile1 = fullfile(cleanDataDir,'b4_id1.csv');
b4_idFile2 = fullfile(cleanDataDir,'b4_id2.csv');
b4_idFile3 = fullfile(cleanDataDir,'b4_id3.csv');
b4_idFile4 = fullfile(cleanDataDir,'b4_id4.csv');
% get demographic data (cat raw data, write temp .csv & read in)
% system(['cat *.csv | grep "survey-text-sam" | sed ''s/{.*,.*}//g'' | cut -d'','' -f 7,11,38,39,40 | sed ''s/"//g'' > ', fullfile(cleanDataDir,'b4_demo.csv')]);
% call Zach's python function to standardize desired columns
system([stdColsPy,' -i ',rawDataDir,' -o ',tmpFile,' -b ',baseFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 6,12,19,20,45,48 > ',b4_trialFile]);
system(['grep "0.0-402.0" ',tmpFile,' | cut -d'','' -f 6,10,11,38,39,40 > ',b4_demoFile]);
%system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 6,24,25,26,27 > ',b4_doorFile]); Door probabilities aren't fixed now
system(['grep "0.0-8.0-0.0" ',tmpFile,' | cut -d'','' -f 6,16,17,18 > ',b4_idFile1]);
system(['grep "0.0-8.0-1.0" ',tmpFile,' | cut -d'','' -f 6,16,17,18 > ',b4_idFile2]);
system(['grep "0.0-401.0-0.0" ',tmpFile,' | cut -d'','' -f 6,16,17,18 > ',b4_idFile3]);
system(['grep "0.0-401.0-1.0" ',tmpFile,' | cut -d'','' -f 6,16,17,18 > ',b4_idFile4]);

b4_demo = readtable(b4_demoFile,'Format','%s%d%d%d%s%s');
%b4_door = readtable(b4_doorFile,'Format','%s%f%f%f%f');
b4_demo.Properties.VariableNames = {'subID','gemsDrift','bombDrift','age','race','gender'};

tmp = csvread(b4_trialFile);
%door = csvread(b4_doorFile);
id1 = csvread(b4_idFile1);
id2 = csvread(b4_idFile2);
id3 = csvread(b4_idFile3);
id4 = csvread(b4_idFile4);
subID = tmp(:,1);
tnum = tmp(:,6);
choice = tmp(:,5)+1;
reward = [tmp(:,3:4)];
rt = tmp(:,2);

% turn subID strings back into numbers
subList=str2num(char(b4_demo.subID));

% init nan fields in b4_demo
b4_demo.gems = nan(height(b4_demo),1);
b4_demo.bomb = nan(height(b4_demo),1);
b4_demo.payout = nan(height(b4_demo),1);
b4_demo.meanRT = nan(height(b4_demo),1);
b4_demo.totalRT = nan(height(b4_demo),1);
b4_demo.idZur1 = id1(:,[2:4]);
b4_demo.idNyx1 = id2(:,[2:4]);
b4_demo.idZur2 = id3(:,[2:4]);
b4_demo.idNyx2 = id4(:,[2:4]);

% loop over b4_trial
for s = 1:height(b4_demo)
    % for data structure to use w/ mfit
    d.subID = b4_demo.subID{s};
    d.N = length(choice(subID==subList(s)));
    d.C = length(unique(choice(subID==subList(s))));
    d.c = choice(subID==subList(s));
    d.r = reward(subID==subList(s),:);
    d.rt = rt(subID==subList(s));
    data(s) = d;
    % update b4_demo w/ payout, meanRT, totalRT
    b4_demo.gems(s) = sum(d.r(:,1));
    b4_demo.bomb(s) = sum(d.r(:,2));
    b4_demo.payout(s) = b4_demo.gems(s)+b4_demo.bomb(s);
    b4_demo.meanRT(s) = mean(d.rt);
    b4_demo.totalRT(s) = sum(d.rt);
end

% get info about drifting reward probabilities
driftDir = '/Volumes/crisp/hinl/bandit/task/b4/drifts';
drifts = get_drift_data(driftDir,8);
% compute preference for gems by calculating percentage of choices where 
% gems reward probability is higher than bomb reward probability
for s = 1:height(b4_demo)
    gD = drifts(:,:,b4_demo.gemsDrift(s));
    bD = drifts(:,:,b4_demo.bombDrift(s));
    pGems = 0;
    for t = 1:length(data(s).c)
        if gD(t,data(s).c(t)) > bD(t,data(s).c(t))
            pGems = pGems + 1;
        end
    end
    b4_demo.pGems(s) = pGems / length(data(s).c);
end

% return b4_demo as demo (note: this isn't really necessary, but is an artifact
% of earlier ppc scripts that collapsed across experiments)
demo = b4_demo;

% Unnecessary since pGems percentages aren't fixed in this experiment
% Compute percent of choices per door, and then match based on door's pGems
% gDoor = nan(length(data),4);
% for s = 1:length(data)
%   pChose = [sum(data(s).c==1),sum(data(s).c==2),sum(data(s).c==3),sum(data(s).c==4)]./360;
%   gDoor(s,1) = pChose(data(s).pGems==0.8);
%   gDoor(s,2) = pChose(data(s).pGems==0.6);
%   gDoor(s,3) = pChose(data(s).pGems==0.4);
%   gDoor(s,4) = pChose(data(s).pGems==0.2);
% end
% demo.gDoor = gDoor;

% clean up temporary .csv files
system(['rm ',tmpFile]);
system(['rm ',b4_demoFile]);
%system(['rm ',b4_doorFile]);
system(['rm ',b4_trialFile]);
system(['rm ',b4_idFile1]);
system(['rm ',b4_idFile2]);
system(['rm ',b4_idFile3]);
system(['rm ',b4_idFile4]);

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
% writetable(tmat,fullfile(cleanDataDir,'b4v2_trial_table.csv'));

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
% writetable(smat,fullfile(cleanDataDir,'b4v2_subs_table.csv'));
%cd(cleanDataDir);