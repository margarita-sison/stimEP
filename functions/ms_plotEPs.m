function ms_plotEPs(struct, eps2plot, sampling_rate, EPs2plot_labels)
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

time_window = struct.time_window;
chanlabels = EPs2plot_labels;
%% Prepare region-specific colors for plotting
rois = unique(chanlabels); % roi/s = region/s of interest
colorpalette = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840], ...
    [0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840], ...
    [0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};
roi_colors = {}; 

for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end

%% Prepare x-axis values in ms
start_time = time_window(1); % start time in ms
end_time = time_window(2); % end time in ms

samples_per_ms = sampling_rate/1000; % sampling rate in ms
xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

%% Prepare figure container
n_chans = length(chanlabels);
split_cols = input('Plot EPs in 2 columns? [Y/N]: ','s');
if split_cols == 'Y'
    n_cols = 2;
    chan_subsets = {1:n_chans/2 n_chans/2+1:n_chans};
elseif split_cols == 'N'
    n_cols = 1;
    chan_subsets = {chanlabels};
end

n_rows = 1;

fig = figure;
fig.WindowState = 'maximized';

tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
title(tiles,ephys_code,'FontWeight','bold')
xlabel(tiles, "Time w.r.t. stimulus onset (ms)")

%% Plot the EPs
% Split channels into 2 sets, 1 for each of the 2 columns of the figure

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
        
        if strcmp(ecog_or_lfp, 'LFP')
            color_idx = chanlabels(c);
        elseif strcmp(ecog_or_lfp,'ECoG')
            color_idx = find(contains(rois,chanlabels{c}));
        end
        plot(xaxis_ms, yvals, 'Color', [0 0 0]);
        
        ytick_vals = [ytick_vals yvals(1)];
        ytick_labels = [ytick_labels chanlabels(c)];

        hold on
    end
    hold off
 
    xlim([start_time end_time])
    ylim([min(eps2plot(chan_subset(1),:)) offset*counter])
    yticks(round(ytick_vals))
    yticklabels(ytick_labels), set(gca,'TickLabelInterpreter','none')
end
end