function evoked_potentials = ms_meanepochs(ep_dir, ms_struct)

% Function
% --------
% 
% 

%% Extract channel labels (annotations) from 'EP' struct
load(ep_dir) % where we get the channel labels (annotations)

ephys_num = str2double(ms_struct.ephys(6:end));
chan_annots = EP(ephys_num).channelLocsSimpleMonopolar; % make this customizable

%% Prepare region-specific colors for plotting
rois = unique(chan_annots); % roi/s = region/s of interest

colorpalette = {"#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"};
roi_colors = {}; 

for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end % if more colors are needed, prompt user to seelct more colors

%% Get the evoked potentials
evoked_potentials = squeeze(mean(ms_struct.epoch_tensor,2)); % average all the epochs (2nd dim of epoch_tensor)

%% Prepare variables for plotting
% Prepare x-axis values in ms
start_time = ms_struct.timewindow(1); % start time in ms
end_time = ms_struct.timewindow(2); % end time in ms

samples_per_ms = ms_struct.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

% Prepare figure container
n_chans = length(chan_annots);

n_rows = 1;
n_cols = 2;
n_tiles = n_rows*n_cols;

tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');

fig = figure;
fig.WindowState = 'maximized';

%% Plot the EPs
% Split channels into 2 sets, 1 for each of the 2 columns of the figure
chan_sets = {1:n_chans/2 n_chans/2+1:n_chans};
for s = 1:length(chan_sets)
    nexttile
    chan_set = chan_sets{s};
    
    counter = 0; % used together with 'offset'
    offset = max(evoked_potentials,[],"all"); % to plot signals on top of each other in 1 tile

    ytick_vals = [];
    ytick_labels = {};

    for c = chan_set
        chan = evoked_potentials(c,:);
        
        yvals = chan+offset*counter; % to plot signals on top of each other in 1 tile
        counter = counter+1;

        color_idx = find(contains(rois,chan_annots{c}));

        plot(xaxis_ms, yvals, 'Color', roi_colors{color_idx})

        ytick_vals = [ytick_vals yvals(1)];
        ytick_labels = [ytick_labels chan_annots{c}];
       
        hold on
    end
    hold off

    xlim([start_time end_time])
    ylim([min(evoked_potentials(chan_set(1),:)) offset*counter])
    yticks(round(ytick_vals))
    yticklabels(ytick_labels)
end
end
