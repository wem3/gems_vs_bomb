% summarize data, write out .csv files

%% INITIALIZE DIRECTORIES & SET PATHS for b2 (version 1)
studyDir = '/Volumes/crisp/hinl/bandit/gems_vs_bomb';
cleanDataDir = fullfile(studyDir,'clean');
scriptDir = fullfile(studyDir,'scripts');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b1: model 1 beats model 2 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
load b1_mfit_default.mat
%loop over subjects
for s = 1:length(b1.data)
    subID{s,1} = b1.data(s).subject.subID;
    condition{s,1} = b1.data(s).subject.cond;
    payout(s,1) = sum(sum(b1.data(s).r));
end
% get estimated parameters from results structure
it = b1.results(1).x(:,1);
lr = b1.results(1).x(:,3);
sticky = b1.results(1).x(:,2);
% make table, write it out
t = table(subID,condition,payout,it,lr,sticky);
writetable(t,[fullfile(cleanDataDir,'b1_default_table.csv')]);
cabut bandit studyDir cleanDataDir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b2: model 1 is the best according to bms, but only model 4 has wGems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
load b2_mfit_default.mat
% loop over subjects
for s = 1:length(b2.data)
    subID{s,1} = b2.data(s).subject.subID;
    drift(s,1) = b2.data(s).subject.drift;
    gems(s,1) = sum(b2.data(s).r(:,1));
    bomb(s,1) = sum(b2.data(s).r(:,2));
    % b2 ppc script doesn't compute pGems for some dumb reason
    pGems(s,1) = sum(b2.data(s).subject.cFreq.*[.8 .6 .4 .2]);
    chose80(s,1) = b2.data(s).subject.cFreq(1); 
    chose60(s,1) = b2.data(s).subject.cFreq(2); 
    chose40(s,1) = b2.data(s).subject.cFreq(3); 
    chose20(s,1) = b2.data(s).subject.cFreq(4); 
end
% get estimated parameters from results structure
it = b2.results(4).x(:,1);
lr = b2.results(4).x(:,3);
sticky = b2.results(4).x(:,2);
wGems = b2.results(4).x(:,4);
% make table, write data to .csv for easy python import
t = table(subID,gems,bomb,pGems,wGems,chose80,chose60,chose40,chose20,it,lr,sticky);
writetable(t,[fullfile(cleanDataDir,'b2_default_table.csv')]);
cabut studyDir cleanDataDir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b3: model 1 is the best according to bms, but only model 4 has wGems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
load b3_mfit_default.mat
% loop over subjects
for s = 1:length(b3.data)
    subID{s,1} = b3.data(s).subject.subID;
    gems(s,1) = sum(b3.data(s).r(:,1));
    bomb(s,1) = sum(b3.data(s).r(:,2));
    pGems(s,1) = b3.data(s).subject.pGems;
    igbias(s,1) = b3.data(s).subject.igbias;
    chose80(s,1) = b3.data(s).subject.cFreq(1); 
    chose60(s,1) = b3.data(s).subject.cFreq(2); 
    chose40(s,1) = b3.data(s).subject.cFreq(3); 
    chose20(s,1) = b3.data(s).subject.cFreq(4); 
end
% get estimated parameters from results structure
it = b3.results(4).x(:,1);
lr = b3.results(4).x(:,3);
sticky = b3.results(4).x(:,2);
wGems = b3.results(4).x(:,4);
% make table, write data to .csv for easy python import
t = table(subID,gems,bomb,igbias,pGems,wGems,chose80,chose60,chose40,chose20,it,lr,sticky);
writetable(t,[fullfile(cleanDataDir,'b3_default_table.csv')]);
cabut studyDir cleanDataDir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b4: model 4 is *clearly* the best according to bms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
load b4_mfit_default.mat
% loop over subjects
for s = 1:length(b4.data)
    subID{s,1} = b4.data(s).subject.subID;
    gems(s,1) = sum(b4.data(s).r(:,1));
    bomb(s,1) = sum(b4.data(s).r(:,2));
    igbias(s,1) = b4.data(s).subject.igbias;
end
% get estimated parameters from results structure
it = b4.results(4).x(:,1);
lr = b4.results(4).x(:,3);
sticky = b4.results(4).x(:,2);
wGems = b4.results(4).x(:,4);
% make table, write data to .csv for easy python import
t = table(subID,gems,bomb,igbias,wGems,it,lr,sticky);
writetable(t,[fullfile(cleanDataDir,'b4_default_table.csv')]);
cabut studyDir cleanDataDir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b5: model 1 is the best according to bms, but only model 4 has wGems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
load b5_mfit_default.mat
% make a vector to index subjects who passed the manipulation check
gs = [];
for s = 1:length(b5.data)
    if b5.data(s).subject.mc == 1
        gs = [gs;s];
    end
end
% loop over subjects
for s = 1:length(gs);
    subID{s,1} = b5.data(s).subject.subID;
    gems(s,1) = sum(b5.data(s).r(:,1));
    bomb(s,1) = sum(b5.data(s).r(:,2));
    pGems(s,1) = b5.data(s).subject.pGems;
    igbias(s,1) = b5.data(s).subject.igbias;
    chose80(s,1) = b5.data(s).subject.cFreq(1); 
    chose60(s,1) = b5.data(s).subject.cFreq(2); 
    chose40(s,1) = b5.data(s).subject.cFreq(3); 
    chose20(s,1) = b5.data(s).subject.cFreq(4); 
end
% get estimated parameters from results structure
it = b5.results(4).x(gs,1);
lr = b5.results(4).x(gs,3);
sticky = b5.results(4).x(gs,2);
wGems = b5.results(4).x(gs,4);
% make table, write data to .csv for easy python import
t = table(subID,gems,bomb,igbias,pGems,wGems,chose80,chose60,chose40,chose20,it,lr,sticky);
writetable(t,[fullfile(cleanDataDir,'b5_default_table.csv')]);
cabut studyDir cleanDataDir;

% example of computing reward prediction accuracy (dated stuff, brah)
% for t = 1:height(bandit(1).demo)
%     rpa(t,1) = mean(bandit(1).results(1).latents(t).rpe.^2);
%     x = bandit(1).results(1).latents(t).V;
%     y = sum(bandit(1).data(t).r,2);
%     rpm(t,1) = immse(x,y);
%     clear x y
% end