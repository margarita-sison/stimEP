function ms_plotEPs(MS_STRUCT, eps2plot)
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
if ~exist('EP','var')
    disp('Select EP file.')
    [EP_file, EP_dir] = uigetfile;
    load(strcat(EP_dir,EP_file))
end

ephys_num = str2double(MS_STRUCT.ephys(6:end));

ecog_or_lfp = input('Are you plotting LFP or ECoG? ','s');

if strcmp(ecog_or_lfp, 'LFP')
    chanlabels = 1:size(eps2plot,1);
elseif strcmp(ecog_or_lfp, 'ECoG')
    ecog_labels = input(['Field name options:', ...
        '\n    channelLocsSimpleBipolar', ...
        '\n    channelLocsSimpleMonopolar', ...
        '\n    channelLocsBipolar', ...
        '\n    channelLocsMonopolar', ...
        '\n    channelLocs', ...
        '\n    channelLocsSimple', ...
        '\nEnter field name to use: '], 's');
    chanlabels = getfield(EP(ephys_num),ecog_labels);
end


%% Prepare region-specific colors for plotting
rois = unique(chanlabels); % roi/s = region/s of interest
colorpalette = {[0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], ...
    [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], ...
    [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0]};
% colorpalette = {"#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" ...
%     "#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" ...
%     "#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"};
roi_colors = {}; 

for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end

%% Prepare x-axis values in ms
start_time = MS_STRUCT.timewindow(1); % start time in ms
end_time = MS_STRUCT.timewindow(2); % end time in ms

samples_per_ms = MS_STRUCT.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

%% Prepare figure container
n_chans = length(chanlabels);
split_ans = input('Plot EPs in 2 columns? [Y/N]: ','s');
if split_ans == 'Y'
    n_cols = 2;
else
    n_cols = 1;
end

n_rows = 1;

fig = figure;

tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
title(tiles,MS_STRUCT.ephys,'FontWeight','bold')
xlabel(tiles, "Time w.r.t. stimulus onset (ms)")

fig.WindowState = 'maximized';

%% Plot the EPs
% Split channels into 2 sets, 1 for each of the 2 columns of the figure
if n_cols == 2
    chan_subsets = {1:n_chans/2 n_chans/2+1:n_chans};
else 
    chan_subsets = {chanlabels};
end

for s = 1:length(chan_subsets)
    nexttile
    chan_subset = chan_subsets{s};
    
    counter = 0; % used together with vertical 'offset'
    offset = max(eps2plot,[],"all"); % to plot signals on top of each other in 1 tile

    ytick_vals = [];
    ytick_labels = {};

    for c = chan_subset  
        yvals = eps2plot(c,:)+offset*counter*1.5; % to plot signals on top of each other in 1 tile
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
    ylim([min(eps2plot(chan_subset(1),:)) offset*counter*1.5])
    yticks(round(ytick_vals))
    yticklabels(ytick_labels), set(gca,'TickLabelInterpreter','none')
end
end