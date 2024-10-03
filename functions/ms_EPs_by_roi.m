function [EPs_by_roi, rois] = ms_EPs_by_roi(MS_STRUCT, eps2average)

% Function
% --------
% Averages evoked potentials from the same brain region (e.g, primary motor cortex)
%
% Input arguments
% ---------------
% ep_dir (char or string)   - path to 'EP' struct containing channel locations
% chanlabels (char, string, or cell array)  - if plotting ecog, chanlabels = field name in EP struct (char or string); if plotting lfp, chanlabels = cell array containing lfp labels
% ms_struct (struct)        - struct containing:
%       ephys (char)        : ephys code, e.g. 'ephys001'
% eps2average (mxn double)  - matrix of evoked potentials, e.g. from ecog or lfp; m = number of signals (channels), n = sample points
%
% Output argument
% ---------------
% EPs_by_roi (rxn double)   - matrix of evoked potentials averaged by brain region; r = number of unique brain regions, n = sample points
% rois (1xr cell)           - brain regions of interest
%% Extract channel locations from 'EP' struct
if ~exist('EP','var')
    disp('Select EP file.')
    [EP_file, EP_dir] = uigetfile;
    load(strcat(EP_dir,EP_file))
end
ephys_num = str2double(MS_STRUCT.ephys(6:end));

ecog_labels = input(['Field name options:', ...
    '\n    channelLocsSimpleBipolar', ...
    '\n    channelLocsSimpleMonopolar', ...
    '\n    channelLocsBipolar', ...
    '\n    channelLocsMonopolar', ...
    '\n    channelLocs', ...
    '\n    channelLocsSimple', ...
    '\nEnter field name to use: '], 's');
chanlabels = getfield(EP(ephys_num),ecog_labels);

%% Average evoked potentials from the same brain region
rois = unique(chanlabels); % roi/s = region/s of interest
EPs_by_roi = zeros(length(rois),size(eps2average,2));

for r = 1:length(rois)
    EPs_by_roi(r,:) = mean(eps2average(strcmp(chanlabels,rois{r}),:),1);
end