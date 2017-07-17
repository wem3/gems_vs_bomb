function [data, report] = exclude_b1_subs(data)
% exclude_b1_subs.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Exclude subs that will break mfit or don't meet data quality criteria
%
% USAGE: [data, excluded] = exclude_b1_subs(data)
%
% INPUT:
%       data = [1 x n] structure created by ppc_raw_b1 w/ subject data
%
%       demo = table object w/ per subject data
%
% OUTPUT:
%       data = [1 x (n ~=excluded) ] data structure
%
%       excluded = {n x 1} list of excluded subjects' subIDs
%
%       report = {n x 1} list of exclusion criteria
%
% written: ~#wem3#~ [20170203]
% edited:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: models converge seemingly regardless of exclusion criteria, exclude only mfit busting subs 
idx = ones(1,length(data));
report = {};
% loop over subjects
for s = 1:length(data)
    if data(s).C ~= 4 % if they failed to choose each arm once
        r = sprintf('Subject %s failed to choose all 4 arms',data(s).subject.subID{:})
        idx(s) = 0;
    % elseif length(find(data(s).rt > 5000)) > data(s).N/10 % if rt on more than 10% trials > 5 seconds
    %     r = sprintf('Subject %s exceeded 5000ms on 10 percent of trials',data(s).subID{:})
    %     idx(s) = 0;
    % elseif length(find(data(s).rt > 60000)) > 1 % if they stopped at any point for more than a minute
    %     r = sprintf('Subject %s stopped for more than a minute',data(s).subID{:})
    %     idx(s) = 0;
    % elseif demo.failMC(s) == 1 % if they failed the manipulation check
    %     r = sprintf('Subject %s failed manipulation check',data(s).subID{:})
    %     idx(s) = 0;
    else
        r = {};
    end
    report = [report; r];
end

data = data([idx==1]);
