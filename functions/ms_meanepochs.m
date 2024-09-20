function ms_meanepochs(EP_dir, ephys_num, epoch_tensor)

load(EP_dir)
chan_annots = EP(ephys_num).channelLocsSimpleMonopolar;
EPs = squeeze(mean(epoch_tensor,2));

n_chans = length(chan_annots);

n_rows = 1;
n_cols = 2;
n_tiles = n_rows*n_cols;

chan_sets = {1:n_chans/2 n_chans/2+1:n_chans};
for s = 1:length(chan_sets)
    chan_set = chan_sets{s};
    for c = 1: