%% Prepare workspace 

% Add path to folder containing the functions used in this pipeline
disp('Select functions folder: ')
fxn_dir = uigetdir; 
addpath(append(fxn_dir, '/'))

% Load EP struct
disp('Load EP struct: ')
[EP_file, EP_fileloc] = uigetfile;
load(append(EP_fileloc, EP_file))

% Load SSEP file
disp('Load SSEP file: ')
[ssep_file, ssep_fileloc] = uigetfile;
load(append(ssep_fileloc, ssep_file))

% -------------------------------------------------------------------------

% Make output folder
disp('Select save location for output folder: ')
save_dir = uigetdir;

output_folder = append(save_dir,'/stimEP_outputs');
if ~isfolder(output_folder)
    mkdir(output_folder)
end

% Make ephys folder in output folder
ephys_code = input('Specify ephys code, e.g. ephys001: ', 's');

ephys_folder = append(output_folder,'/',ephys_code);
if ~isfolder(ephys_folder)
    mkdir(ephys_folder)
end

% Make struct to store ephys info
EPHYS_STRUCT = struct;
EPHYS_STRUCT.ephys_code = ephys_code;
EPHYS_STRUCT.ephys_folder = ephys_folder;

%% Visually inspect EMG signals before selecting a template EMG signal 

% Set up tiling configuration 
n_chans = size(emg,1); % number of channels
n_rows = input(['There are ' num2str(n_chans) ' channels to plot. Specify n rows: ']); % prompts user to select number of rows for the tiled figure given the number of channels
n_cols = input(['There are ' num2str(n_chans) ' channels to plot. Specify n columns: ']); % prompts user to select number of columns for the tiled figure given the number of channels
n_tiles = n_rows*n_cols; % total number of tiles

% Plot the signals
quotient = floor(n_chans/n_tiles); % for figure formatting purposes; quotient = number of figures that will have complete number of rows and columns specified

for q = 1:quotient
    chan_set = [(q-1)*n_tiles+1 q*n_tiles]; % set of channels that will be plotted on the current figure
    chan_set_first = chan_set(1); % first channel in the set
    chan_set_last = chan_set(2); % last channel in the set

    %%% prepare fig container here
    fig(q) = figure('Units','Normalized','OuterPosition',[0 0 1 1]);

    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    title(tiles,append('P',ephys_code(6:end),' - EMG'),'FontWeight','bold')
    xlabel(tiles, "Sampling units (a.u.)"), ylabel(tiles, "Amplitude (µV)")
    %%%

    for s = chan_set_first:chan_set_last
        nexttile
        plot(emg(s,:)) 
        
        title("EMG("+s+",:) - "+emg_labels(s))
    end

    saveas(fig, append(ephys_folder,'/emg'))
end

% If number of channels is odd, there will be some leftover channels to plot:
m = mod(n_chans,n_tiles);

if m ~= 0
    chan_set = [n_tiles-m+1 n_tiles]; % set of channels that will be plotted on the current figure
    chan_set_first = chan_set(1); % first channel in the set
    chan_set_last = chan_set(2); % last channel in the set
    
    %%% prepare fig container  here
    fig(m+1) = figure('Units','Normalized','OuterPosition',[0 0 1 1]);

    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','tight','Padding','tight','TileIndexing','columnmajor');
    title(tiles,append('P',ephys_code(6:end),' - EMG'),'FontWeight','bold')
    xlabel(tiles, "Sampling units (a.u.)"), ylabel(tiles, "Amplitude (µV)")
    
     
    %%%

    for s = chan_set_first:chan_set_last
        nexttile
        plot(emg(s,:))

        title("EMG("+s+",:) - "+emg_labels(s))
    end

    saveas(fig, append(ephys_folder,'/emg'))
end

EPHYS_STRUCT.emg = emg;
EPHYS_STRUCT.emg_labels = emg_labels;

%% Trim the template EMG signal before extracting stimulus artifact peaks 
emg2trim_idx = input('Specify index of EMG signal to trim, e.g. 1: ');
emg2trim = emg(emg2trim_idx,:);
emg2trim_label = emg_labels(emg2trim_idx);

fig = figure('Units','Normalized','OuterPosition',[0 0 1 1]);

plot(emg2trim) % plot the signal  
[x, ~] = ginput(2); % prompt the user to select 2 points

start_idx = round(x(1)); % get the starting index (xval) of segment in the original signal
end_idx = round(x(2)); % get the end index (xval) of segment in the original signal
endpt_idcs = [start_idx end_idx];

emg_segment = emg2trim(endpt_idcs(1):endpt_idcs(2)); % use the start & end indices to trim the original signal
plot(emg_segment) % plot the resulting segment

title("P"+ephys_code(6:end)+" - EMG "+emg2trim_idx+" ("+emg2trim_label+")",'FontWeight','bold')
xlabel("Sampling units (a.u.)"), ylabel("Amplitude (µV)")

EPHYS_STRUCT.emg2trim_idx = emg2trim_idx;
EPHYS_STRUCT.emg2trim = emg2trim;
EPHYS_STRUCT.emg2trim_label = emg2trim_label;
EPHYS_STRUCT.emg_segment = emg_segment;
EPHYS_STRUCT.segment_endpt_idcs = endpt_idcs;

saveas(fig, append(ephys_folder,'/emg_segment'))
%% Extract stimulus artifact peaks from template EMG signal 

% Find the maximum peak prominence in the signal
[~, ~, ~, pk_proms] = findpeaks(emg_segment); 
max_prom = max(pk_proms);

% Let user specify a minimum threshold (% of maximum  peak prominence expressed as a decimal)
threshold = input('Enter threshold as decimal: '); % percentage of maximum peak prominence expressed as a decimal
min_prom = threshold*max_prom; % e.g., 90% of max. peak prominence

% Display peaks detected based on the specified threshold
fig = figure('Units','Normalized','OuterPosition',[0 0 1 1]);
findpeaks(emg_segment,'MinPeakProminence',min_prom)

% Provide the option to adjust threshold
user_ans = input('Adjust threshold? [Y/N]: ', 's');

while user_ans == "Y"
    threshold = input('Enter threshold as decimal: ');
    min_prom = threshold*max_prom;

    fig = figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    findpeaks(emg_segment,'MinPeakProminence',min_prom) 

    user_ans = input('Adjust threshold? [Y/N]: ','s');
end

title("P"+ephys_code(6:end)+" - EMG "+emg2trim_idx+" ("+emg2trim_label+")",'FontWeight','bold')
xlabel("Sampling units (a.u.)"), ylabel("Amplitude (µV)")

% Call 'findpeaks' with minimum peak prominence specified
[peaks, pk_locs, pk_widths, pk_proms] = findpeaks(emg_segment,'MinPeakProminence',min_prom);

%
for p = 1:length(pk_locs)-1
    if p >= length(pk_locs)
        continue 
    end

    if pk_locs(p+1)-pk_locs(p) < sampling_rate_emg*0.97
        peaks(p+1) = 0;
        pk_locs(p+1) = 0;
        pk_widths(p+1) = 0;
        pk_proms(p+1) = 0;
        
        peaks = nonzeros(peaks);
        pk_locs = nonzeros(pk_locs);
        pk_widths = nonzeros(pk_widths);
        pk_proms = nonzeros(pk_proms);
    end
end

EPHYS_STRUCT.sampling_rate_emg = sampling_rate_emg;

EPHYS_STRUCT.peaks = peaks;
EPHYS_STRUCT.pk_locs = pk_locs;
EPHYS_STRUCT.pk_widths = pk_widths;
EPHYS_STRUCT.pk_proms = pk_proms;

saveas(fig, append(ephys_folder,'/emg_segment_peaks'))

%% Do bipolar re-referencing on ECoG or LFP signals 
EPHYS_STRUCT.ecog = ecog;
EPHYS_STRUCT.lfp = lfp;

signal2reref = input('Specify signal to re-reference, e.g. lfp: ', 's');

if strcmp(signal2reref, 'ecog')
    
    n_chans = size(ecog,1);

    monopolar_subsets = {1:n_chans/2 n_chans/2+1:n_chans}; % split channels into 2 equal sets
    bipolar_subsets = {1:(n_chans/2)-1 n_chans/2:n_chans-2}; % for indexing later on
    ecog_bipolar = zeros(size(ecog,1)-2, size(ecog,2));

    for s = 1:length(monopolar_subsets)
        monopolar_subset = monopolar_subsets{s};
        bipolar_subset = bipolar_subsets{s};
    
        ecog_monopolar_subset = ecog(monopolar_subset,:);
        ecog_bipolar_subset = diff(ecog_monopolar_subset);
        ecog_bipolar(bipolar_subset,:) = ecog_bipolar_subset;
    end
    
    EPHYS_STRUCT.(append(signal2reref,'_bipolar')) = ecog_bipolar;

elseif strcmp(signal2reref, 'lfp')

    if size(lfp,1) == 8
        lfp1 = lfp(1,:);
        lfp2abc = mean(lfp(2:4,:),1);
        lfp3abc = mean(lfp(5:7,:),1);
        lfp4 = lfp(8,:);

        lfp_8to4 = [lfp1; lfp2abc; lfp3abc; lfp4];
        lfp_bipolar = diff(lfp_8to4);
        EPHYS_STRUCT.(append(signal2reref,'_bipolar')) = lfp_bipolar;
    elseif size(lfp,1) == 4
        lfp_bipolar = diff(lfp);
        EPHYS_STRUCT.(append(signal2reref,'_bipolar')) = lfp_bipolar;
    end
end

%%
data = input('Specify signals to plot, e.g. lfp_bipolar: ');
sampling_rate = input('Specify sampling rate: ');

eegplot(data, 'srate', sampling_rate, 'winlength', round(size(data,2)/sampling_rate));

%% Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
EPHYS_STRUCT.sampling_rate_ecog = sampling_rate_ecog;
EPHYS_STRUCT.sampling_rate_lfp = sampling_rate_lfp;

time_window = input('Specify time window in ms w.r.t. stimulus onset, e.g. [-20 100]: ');
signal2epoch = input('Specify signal to epoch, e.g. lfp_bipolar: ', 's');
sampling_rate = input('Specify sampling rate: ');

% -----
samples_per_ms = sampling_rate/1000;

start_time = time_window(1); % start time in ms
pre_onset_len = start_time*samples_per_ms; % length from starting time to event onset, in sampling units

end_time = time_window(2); % end time in ms
post_onset_len = end_time*samples_per_ms; % length from event onset to end time, in sampling units
% -----
chans = EPHYS_STRUCT.(signal2epoch);

epochs = zeros(size(chans,1), length(pk_locs), length(pre_onset_len:post_onset_len)); % channels x epochs x samples

for c = 1:size(chans,1)
    chan = chans(c,endpt_idcs(1):endpt_idcs(2)); % trim signal with the same start & end indices as segement from 'ms_trimsignal'
    
    for p = 1:length(pk_locs)
        pk_loc = pk_locs(p);
        
        if pk_loc+pre_onset_len < 1 || pk_loc+post_onset_len > length(chan) % skip if there are insufficient points before/after event onset
            continue
        end

        epoch = chan(round(pk_loc)+pre_onset_len:round(pk_loc)+post_onset_len); % pre_onset_len has negative val
        epochs(c,p,:) = epoch; % epoch for channel 'c' around event onset 'o'
    end
end

EPHYS_STRUCT.time_window = time_window;
EPHYS_STRUCT.(append(signal2epoch,'_epochs')) = epochs;
  
%% Plot epochs
% epochs2plot = input('Specify epochs to plot, e.g. lfp_bipolar_epochs: ', 's');
% ms_plotepochs(EPHYS_STRUCT, epochs2plot)

% %% Apply a baseline correction to the evoked potentials
% baseline_period = input('Specify baseline period in ms w.r.t. stimulus onset, e.g. [5 100]: ');
% EPHYS_STRUCT = ms_baselinecorrect(EPHYS_STRUCT, baseline_period);
% 
% %% Detrend evoked potentials if necessary
% option2detrend = input('Detrend EPs? [Y/N]: ','s');
% if option2detrend == 'Y'
%     signals2detrend = input('Specify signal to detrend, e.g. evoked_potentials: ');
%     [eps_detrended, EPHYS_STRUCT] = ms_detrend(EPHYS_STRUCT, signals2detrend);
% else
% end

%% Average epochs to generate EPs
epochs2average = input('Specify epochs to average, e.g. lfp_bipolar_epochs: ', 's');
epochs = EPHYS_STRUCT.(epochs2average);

evoked_potentials = squeeze(mean(epochs,2)); % average all the epochs per channel (2nd dimension of signal_tensor)
EPHYS_STRUCT.(append(epochs2average(1:end-7),'_EPs')) = evoked_potentials;
%%
save(append(ephys_folder,"/EPHYS_STRUCT.mat"),"EPHYS_STRUCT")

%% PLOTTING ECoG EPs
EPs2plot = input('Specify EPs to plot, e.g. ecog_bipolar_EPs: ');
chanlabels = input('Specify channel labels to use, e.g. EP.channelLocsSimpleBipolar: ');

% Prepare region-specific colors for plotting
rois = unique(chanlabels); % roi/s = region/s of interest
colorpalette = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840], ...
    [0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840], ...
    [0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

roi_colors = {}; 
for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end

% Prepare figure container
n_rows = 1;
n_cols = 2;

fig = figure('Units','Normalized','OuterPosition',[0 0 0.5 1]);
tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
title(tiles, append('P',EPHYS_STRUCT.ephys_code(6:end),' - ECoG EPs'),'FontWeight','bold')
xlabel(tiles, "Time w.r.t. stimulus onset (ms)")

% Split channels into 2 sets, 1 for each of the 2 columns of the figure
n_chans = length(chanlabels);
chan_subsets = {1:n_chans/2 n_chans/2+1:n_chans};

samples_per_ms = EPHYS_STRUCT.sampling_rate_ecog/1000;
start_time = EPHYS_STRUCT.time_window(1); % start time in ms
end_time = EPHYS_STRUCT.time_window(2); % end time in ms
for s = 1:length(chan_subsets)
    nexttile
    chan_subset = chan_subsets{s};
    
    counter = 0; % used together with vertical 'offset'
    offset = max(EPs2plot,[],"all")-min(EPs2plot,[],"all"); % to plot signals on top of each other in 1 tile

    ytick_vals = [];
    ytick_labels = {};

    for c = chan_subset  
        yvals = EPs2plot(c,:)+offset*counter; % to plot signals on top of each other in 1 tile
        counter = counter+0.7; % 0.5 for mono
      
        xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms
        color_idx = find(strcmp(rois,chanlabels{c}));
        plot(xaxis_ms, yvals, 'Color', roi_colors{color_idx});
        
        ytick_vals = [ytick_vals yvals(1)];
        ytick_labels = [ytick_labels chanlabels(c)];

        hold on
    end
    hold off
 
    xlim([start_time end_time])
    ylim([min(EPs2plot(chan_subset(1),:)) offset*counter])
    yticks(round(ytick_vals))
    yticklabels(ytick_labels), set(gca,'TickLabelInterpreter','none')
end


%% PLOTTING LFPs

EPs2plot = input('Specify EPs to plot, e.g. lfp_bipolar_EPs: ');
chanlabels = input('Specify channel labels to use as a 1xnchans cell array: ');
 
samples_per_ms = EPHYS_STRUCT.sampling_rate_lfp/1000;
start_time = EPHYS_STRUCT.time_window(1); % start time in ms
end_time = EPHYS_STRUCT.time_window(2); % end time in ms

fig = figure('Units','Normalized','OuterPosition',[0 0 0.25 0.75]);
counter = 0; % used together with vertical 'offset'
offset = max(EPs2plot,[],"all");%-min(EPs2plot,[],"all"); % to plot signals on top of each other in 1 tile
ytick_vals = [];
ytick_labels = {};
for c = 1:length(chanlabels)
    yvals = EPs2plot(c,:)+offset*counter; % to plot signals on top of each other in 1 tile
    counter = counter+1;
  
   
    xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms
    plot(xaxis_ms, yvals);
    
    ytick_vals = [ytick_vals yvals(1)];
    ytick_labels = [ytick_labels chanlabels(c)];

    hold on
end
hold off
title(append('P',EPHYS_STRUCT.ephys_code(6:end),' - DLEPs'),'FontWeight','bold')
xlabel("Time w.r.t. stimulus onset (ms)")
xlim([start_time end_time])
ylim([min(EPs2plot,[],"all") offset*counter])
yticks(round(ytick_vals))
yticklabels(ytick_labels), set(gca,'TickLabelInterpreter','none')
 
%%
%% PLOTTING LFPs or EPs - per tile

EPs2plot = input('Specify EPs to plot, e.g. lfp_bipolar_EPs: ');
chanlabels = input('Specify channel labels to use as a 1xnchans cell array: ');
 
samples_per_ms = EPHYS_STRUCT.sampling_rate_lfp/1000;
start_time = EPHYS_STRUCT.time_window(1); % start time in ms
end_time = EPHYS_STRUCT.time_window(2); % end time in ms

fig = figure('Units','Normalized','OuterPosition',[0 0 0.3 0.3]); % [0 0 0.5 0.3] % [0 0 0.25 1]
n_chans = size(EPs2plot,1); % number of channels
n_rows = input(['There are ' num2str(n_chans) ' channels to plot. Specify n rows: ']); % prompts user to select number of rows for the tiled figure given the number of channels
n_cols = input(['There are ' num2str(n_chans) ' channels to plot. Specify n columns: ']); % prompts user to select number of columns for the tiled figure given the number of channels
n_tiles = n_rows*n_cols; % total number of tiles
    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    title(tiles,append('P',EPHYS_STRUCT.ephys_code(6:end),' - mean bipolar DLEP'),'FontWeight','bold')
    xlabel(tiles, "Time w.r.t. stimulus onset (ms)"), ylabel(tiles, "Amplitude (µV)")
for c = [3 2 1 4]%1:length(chanlabels)
    nexttile
    yvals = EPs2plot(c,:); % to plot signals on top of each other in 1 tile  
   
    xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms
    plot(xaxis_ms, yvals);
    %title(chanlabels{c})
    xlim([start_time end_time])
end


 
%% moving-average filter - LFP bipolar, entire time series
sigs_unfilt = EPHYS_STRUCT.lfp_bipolar;

window_len = input('Specify window length for moving average filter: '); 
num_coeff = (1/window_len)*ones(1,window_len);
den_coeff = 1;

% prep fig container
n_rows = 3;
n_cols = 1;

fig = figure('Units','Normalized','OuterPosition',[0 0 0.5 1]);
tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
title(tiles,append(EPHYS_STRUCT.ephys_code,' - bipolar LFP time series'),'FontWeight','bold')
xlabel(tiles,"Sampling units (a.u.)"), ylabel(tiles,"Amplitude (µV)")

% -----
chanlabels = {'2-1' '3-2' '4-3'};
sigs_filt = zeros(size(sigs_unfilt,1), size(sigs_unfilt,2));
for c = 1:length(chanlabels)
    sig_unfilt = sigs_unfilt(c,:);
    sig_filt = filter(num_coeff,den_coeff,sig_unfilt);
    sigs_filt(c,:) = sig_filt;
    nexttile
    plot(sig_unfilt,'Color','black')
    hold on
    plot(sig_filt,'Color','red')
    
    legend('Unfiltered LFP','Filtered LFP')
    yticklabels(chanlabels(c))
    hold off
end


%% 

n_rows = 3;
n_cols = 1;

fig = figure('Units','Normalized','OuterPosition',[0 0 0.25 1]);
tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');
title(tiles,append(EPHYS_STRUCT.ephys_code,' - bipolar LFP EPs'),'FontWeight','bold')
xlabel(tiles,"Time w.r.t. stimulus onset (ms)"), ylabel(tiles,"Amplitude (µV)")

% -----
chanlabels = {'2-1' '3-2' '4-3'};
lfp_bipolar_EPs = EPHYS_STRUCT.lfp_bipolar_EPs;

for c = 1:length(chanlabels)
    lfp_bipolar_EP = lfp_bipolar_EPs(c,:);
    evoked_potential = evoked_potentials(c,:);
    
    nexttile
    plot(xaxis_ms, lfp_bipolar_EP,'Color','black')
    hold on
    plot(xaxis_ms, evoked_potential,'Color','red','LineWidth',3)
    
    %legend('Unfiltered LFP','Filtered LFP')
    yticklabels(chanlabels(c))
    hold off
end

%% Average evoked potentials from the same region (e.g, primary motor cortex) - bipolar
chanlabels = EP.channelLocsSimpleBipolar;
eps2average = EPHYS_STRUCT.ecog_bipolar_EPs;

rois = unique(chanlabels); 
EPs_by_roi = zeros(4,size(eps2average,2));

rois_subset = {};

counter = 0;
for r = [1 3 5 7]
    counter = counter+1;
    EPs_by_roi(counter,:) = mean(eps2average(strcmp(chanlabels,rois{r}),:),1);
    rois_subset = [rois_subset rois{r}];
end

EPHYS_STRUCT.ecog_bipolar_EPs_by_roi = EPs_by_roi;
EPHYS_STRUCT.ecog_bipolar_rois = rois_subset;

%%
eps2average = EPHYS_STRUCT.lfp_bipolar_EPs;
EPHYS_STRUCT.lfp_bipolar_mean_EP = squeeze(mean(eps2average));
%% 10 - Extract post-stimulus peaks from evoked potentials
% prepare empty cell containers for storing peak values

EPs2getpeaksfrom = input('Specify EPs, e.g. lfp_bipolar_EPs: ');
sampling_rate = input('Specify sampling rate: ');

poststim_peaks_all = cell(size(EPs2getpeaksfrom,1),1);
poststim_pklocs_all = cell(size(EPs2getpeaksfrom,1),1);
poststim_pkwidths_all = cell(size(EPs2getpeaksfrom,1),1);
poststim_pkproms_all = cell(size(EPs2getpeaksfrom,1),1);

%%%
poststim_markers = input('Specify time window in ms w.r.t. stimulus onset, e.g. [-20 100]: ');

start_time = EPHYS_STRUCT.time_window(1); % start time in ms
end_time = EPHYS_STRUCT.time_window(2); % end time in ms
samples_per_ms = sampling_rate/1000; % sampling rate in ms
xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms
%%%

for a = 1:size(EPs2getpeaksfrom,1)
    EP2getpeaksfrom = EPs2getpeaksfrom(a,:);
    [~, ~, ~, pk_proms] = findpeaks(EP2getpeaksfrom(find(xaxis_ms == poststim_markers(1)):find(xaxis_ms == poststim_markers(2))));
    max_prom = max(pk_proms);

    % Let user specify a minimum threshold (% of maximum  peak prominence expressed as a decimal)
    threshold = input('Enter threshold as decimal: '); % percentage of maximum peak prominence expressed as a decimal
    min_prom = threshold*max_prom; % e.g., 90% of max. peak prominence

    findpeaks(EP2getpeaksfrom(find(xaxis_ms == poststim_markers(1)):find(xaxis_ms == poststim_markers(2))),'MinPeakProminence',min_prom)

    user_ans = input('Adjust threshold? [Y/N]: ', 's');
    while user_ans == "Y"
        threshold = input('Enter threshold as decimal: ');
        min_prom = threshold*max_prom;
    
        findpeaks(EP2getpeaksfrom(find(xaxis_ms == poststim_markers(1)):find(xaxis_ms == poststim_markers(2))),'MinPeakProminence',min_prom) 
    
        user_ans = input('Adjust threshold? [Y/N]: ','s');
    end
    [peaks, pk_locs, pk_widths, pk_proms] = findpeaks(EP2getpeaksfrom(find(xaxis_ms == poststim_markers(1)):find(xaxis_ms == poststim_markers(2))),'MinPeakProminence',min_prom);

    poststim_peaks_all(a) = {peaks};
    poststim_pklocs_all(a) = {pk_locs};
    poststim_pkwidths_all(a) = {pk_widths};
    poststim_pkproms_all(a) = {pk_proms};
end

%% change to ecog or lfp also if mono or bipolar
EPHYS_STRUCT.ecog_mono_poststim_peaks_all = poststim_peaks_all;
EPHYS_STRUCT.ecog_mono_poststim_pklocs_all = poststim_pklocs_all;
EPHYS_STRUCT.ecog_mono_poststim_pkwidths_all = poststim_pkwidths_all;
EPHYS_STRUCT.ecog_mono_poststim_pkproms_all = poststim_pkproms_all;

%% 11 - Plot average evoked potentials by brain region
ms_struct = EPHYS_STRUCT;
roi_order = [3 2 1 4];
ms_plotEPs_by_roi(EPHYS_STRUCT, roi_order)
 
%% 

