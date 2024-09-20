function ms_meanepochs(EP_dir, ephys_num, epoch_tensor, start_time, end_time, fs)

load(EP_dir)
chan_annots = EP(ephys_num).channelLocsSimpleMonopolar; % customize
EPs = squeeze(mean(epoch_tensor,2));

samples_per_ms = fs/1000;
n_chans = length(chan_annots);

n_rows = 1;
n_cols = 2;
n_tiles = n_rows*n_cols;

tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
fig = figure;
fig.WindowState = 'maximized';

chan_sets = {1:n_chans/2 n_chans/2+1:n_chans};
for s = 1:length(chan_sets)
    nexttile
    chan_set = chan_sets{s};
    
    counter = 0;
    offset = max(EPs,[],"all")-min(EPs,[],"all");

    ytick_vals = [];
    ytick_labels = {};

    for c = chan_set
        chan = EPs(c,:);
        
        counter = counter+1;
        xaxis_ms = start_time:1/samples_per_ms:end_time;
        
        yvals = chan+offset*counter;
        plot(xaxis_ms, yvals)
        ytick_vals = [ytick_vals yvals(1)];
        ytick_labels = [ytick_labels chan_annots{c}];
        hold on
    end
    hold off
    xlim([start_time end_time]), ylim([min(EPs(chan_set(1),:)) offset*counter])
    yticks(round(ytick_vals))
    yticklabels(ytick_labels)
end
end

% 6-7
% 20-21