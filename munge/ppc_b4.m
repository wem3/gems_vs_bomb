function [data] = ppc_b4(studyDir)
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
%
%
% written: ~#wem3#~ [20170203]
% edited:  ~#wem3#~ [20170323] Adapted for b4 | bandit_double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up paths
rawDataDir = fullfile(studyDir,'raw','b4');
cleanDataDir = fullfile(studyDir,'clean');
stdColsPy = ['python /Users/wem3/Developer/zach/csv_ops/standardize_columns.py'];
baseFile = fullfile(studyDir,'munge','b4_trial_headers.csv');
tmpFile = fullfile(cleanDataDir,'tmp.csv');
b4_trialFile = fullfile(cleanDataDir,'b4_trial_data.csv');
b4_demoFile  = fullfile(cleanDataDir,'b4_demo.csv');
b4_idFile1 = fullfile(cleanDataDir,'b4_id1.csv');
b4_idFile2 = fullfile(cleanDataDir,'b4_id2.csv');
b4_idFile3 = fullfile(cleanDataDir,'b4_id3.csv');
b4_idFile4 = fullfile(cleanDataDir,'b4_id4.csv');

% call Zach's python function to standardize desired columns
system([stdColsPy,' -i ',rawDataDir,' -o ',tmpFile,' -b ',baseFile]);
system(['grep "main_expt" ',tmpFile,' | cut -d'','' -f 1,2,4,5,6,7,12,13,14,15,16,17,18,19 > ',b4_trialFile]);
system(['grep "0.0-402.0" ',tmpFile,' | cut -d'','' -f 1,8,9,10 > ',b4_demoFile]);
system(['grep "0.0-8.0-0.0" ',tmpFile,' | cut -d'','' -f 1,20,21,22 > ',b4_idFile1]);
system(['grep "0.0-8.0-1.0" ',tmpFile,' | cut -d'','' -f 1,20,21,22 > ',b4_idFile2]);
system(['grep "0.0-401.0-0.0" ',tmpFile,' | cut -d'','' -f 1,20,21,22 > ',b4_idFile3]);
system(['grep "0.0-401.0-1.0" ',tmpFile,' | cut -d'','' -f 1,20,21,22 > ',b4_idFile4]);

b4_demo = readtable(b4_demoFile,'Format','%s%s%d%s');
%b4_door = readtable(b4_doorFile,'Format','%s%f%f%f%f');
b4_demo.Properties.VariableNames = {'subID','gender','age','race'};

tmp = csvread(b4_trialFile);
id1 = csvread(b4_idFile1);
id2 = csvread(b4_idFile2);
id3 = csvread(b4_idFile3);
id4 = csvread(b4_idFile4);
subID = tmp(:,1);
tnum = tmp(:,2);
choice = tmp(:,3)+1;
reward = [tmp(:,4:5)];
pG = tmp(:,[7,9,11,13]);
pB = tmp(:,[8,10,12,14]);
rt = tmp(:,6);

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
    % for data structure to use w/ mfit
    subject.subID = b4_demo.subID{s};
    subject.age = b4_demo.age(s);
    subject.sex = b4_demo.gender{s};
    subject.race = b4_demo.race{s};
    d.N = length(choice(subID==subList(s)));
    d.C = length(unique(choice(subID==subList(s))));
    d.c = choice(subID==subList(s));
    d.r = reward(subID==subList(s),:);
    d.rt = rt(subID==subList(s));
    d.pG = pG(subID==subList(s),:);
    d.pB = pB(subID==subList(s),:);
    d.subject = subject;
    data(s) = d;
end

% clean up temporary .csv files
system(['rm ',tmpFile]);
system(['rm ',b4_demoFile]);
%system(['rm ',b4_trialFile]);
system(['rm ',b4_idFile1]);
system(['rm ',b4_idFile2]);
system(['rm ',b4_idFile3]);
system(['rm ',b4_idFile4]);