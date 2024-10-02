function ms_plotEPs(ep_dir, chanlabels, ms_struct, eps2plot)
% Function
% --------
% Plots evoked potentials on the same axes with a vertical offset
% 
% Input arguments
% ---------------
% ep_dir (char or string)                   - path to 'EP' struct containing channel locations
% chanlabels (char, string, or cell array)  - if plotting ecog, chanlabels = field name in EP struct (char or string); if plotting lfp, chanlabels = cell array containing lfp labels
% ms_struct (struct)                        - struct containing:
%       ephys (char)                        : ephys code, e.g. 'ephys001'
%       timewindow (1x2 double)             : milliseconds before and after stimulus onset, e.g. [-20 200]
%       fs (double)                         : sampling rate of signals (samples per second)
% eps2plot (mxn double)                     - matrix of evoked potentials, e.g. from ecog or lfp; m = number of signals (channels), n = sample points
%
% Output
% ------
% Figure displaying evoked potentials and accompanying labels

%% Extract channel locations from 'EP' struct
load(ep_dir) 
ephys_num = str2double(ms_struct.ephys(6:end));

if ischar(chanlabels) || isstring(chanlabels)
    chan_annots = getfield(EP(ephys_num), chanlabels);
else 
    chan_annots = chanlabels;
end

%% Prepare region-specific colors for plotting
rois = unique(chan_annots); % roi/s = region/s of interest
colorpalette = {'#0072BD' '#D95319'	'#EDB120' '#7E2F8E' '#77AC30' '#4DBEEE' '#A2142F' ...
    '#0072BD' '#D95319'	'#EDB120' '#7E2F8E' '#77AC30' '#4DBEEE' '#A2142F' ...
    '#0072BD' '#D95319'	'#EDB120' '#7E2F8E' '#77AC30' '#4DBEEE' '#A2142F'};
roi_colors = {}; 

for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end

%% Prepare x-axis values in ms
start_time = ms_struct.timewindow(1); % start time in ms
end_time = ms_struct.timewindow(2); % end time in ms

samples_per_ms = ms_struct.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

%% Prepare figure container
n_chans = length(chan_annots);
n_rows = 1;
n_cols = 2;

fig = figure;

tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
title(tiles,ms_struct.ephys,'FontWeight','bold')
xlabel(tiles, "Time w.r.t. stimulus onset (ms)")

fig.Position([3 4]) = [560*1.5 420*2]; % adjust fig width & height
%% Plot the EPs
% Split channels into 2 sets, 1 for each of the 2 columns of the figure
chan_subsets = {1:n_chans/2 n_chans/2+1:n_chans};

for s = 1:length(chan_subsets)
    nexttile
    chan_subset = chan_subsets{s};
    
    counter = 0; % used together with vertical 'offset'
    offset = max(eps2plot,[],"all"); % to plot signals on top of each other in 1 tile

    ytick_vals = [];
    ytick_labels = {};

    for c = chan_subset  
        yvals = eps2plot(c,:)+offset*counter; % to plot signals on top of each other in 1 tile
        counter = counter+1;
      
        color_idx = find(contains(rois,chan_annots{c}));
        plot(xaxis_ms, yvals, 'Color', roi_colors{contains(rois,chan_annots{c})});
        plot(xaxis_ms, yvals);
        ytick_vals = [ytick_vals yvals(1)];
        ytick_labels = [ytick_labels chan_annots{c}];
     
        hold on
    end
    hold off
 
    xlim([start_time end_time])
    ylim([min(eps2plot(chan_subset(1),:)) offset*counter])
    yticks(round(ytick_vals))
    yticklabels(ytick_labels)
end
end