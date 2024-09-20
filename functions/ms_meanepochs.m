function ms_meanepochs(EP_dir, ephys_num, epoch_tensor)

load(EP_dir)
chan_annots = EP(ephys_num).channelLocsSimpleMonopolar; % customize
EPs = squeeze(mean(epoch_tensor,2));

n_chans = length(chan_annots);

n_rows = 1;
n_cols = 2;
n_tiles = n_rows*n_cols;
tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
figure.WindowState = 'maximized';
chan_sets = {1:n_chans/2 n_chans/2+1:n_chans};
for s = 1:length(chan_sets)
    nexttile
    chan_set = chan_sets{s};
    
    counter = 0;
    for c = chan_set
        chan = EPs(c,:);
        offset = max(chan,[],"all");
        counter = counter+1;
        xaxis_ms = start_time:1/samples_per_ms:end_time;
        plot(xaxis_ms, chan+offset*counter)
        hold on
    end
    hold off
end
end