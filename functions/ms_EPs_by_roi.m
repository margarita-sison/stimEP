function [EPs_by_roi, rois] = ms_EPs_by_roi(ep_dir, chanlabels, ms_struct, eps2average)

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
load(ep_dir) 
ephys_num = str2double(ms_struct.ephys(6:end));

if ischar(chanlabels) || isstring(chanlabels)
    chan_annots = getfield(EP(ephys_num), chanlabels);
else 
    chan_annots = chanlabels;
end

%% Average evoked potentials from the same brain region
rois = unique(chan_annots); % roi/s = region/s of interest
EPs_by_roi = zeros(length(rois),size(eps2average,2));

for r = 1:length(rois)
    EPs_by_roi(r,:) = mean(eps2average(strcmp(chan_annots,rois{r}),:),1);
end