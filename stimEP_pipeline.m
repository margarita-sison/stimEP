%% Currently implemented processes in this pipeline:
% - Visualizing EMG signals
% - Aligning stimulus artifacts in EMG signals with ECOG or LFP signals
% - Extracting epochs from ECOG or LFP signals
% - Visualizing ECOG or LFP evoked potentials (average of epochs)

%% Visualize EMG signals and select a template signal 

% addpath("C:\Users\Miocinovic_lab\Documents\mssison\GitHub\stimEP\functions\") % add path to functions directory + "/" if Mac or "\" if Windows 
% datadir = "C:\Users\Miocinovic_lab\Documents\mssison\ORdata_copies_MS\"; % add path to directory containing ephys files + "/" if Mac or "\" if Windows 
% ephys = "ephys015\"; % specify ephys code + "/" if Mac or "\" if Windows 

addpath("/Users/margaritasison/GitHub/stimEP/functions/") 
datadir = "/Users/margaritasison/Downloads/ORdata_copes_MS/"; 
ephys = "ephys015/"; 

signaltype = "emg"; % specify as char or string

ms_plotsignals(datadir, ephys, signaltype)

MS_STRUCT = struct; % save info that will be useful later in a struct

ephys = char(ephys);
MS_STRUCT.ephys = ephys(1:end-1);

%% Trim the template signal (upon visual inspection, you may want to only use a segment of the template signal)
signal2trim = emg(3,:); 
[segment, endpt_idcs] = ms_trimsignal(signal2trim);

MS_STRUCT.template_segment = segment;
MS_STRUCT.template_endpts = endpt_idcs;

%% Extract location of peak artifacts along the segment
[peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(segment);

MS_STRUCT.peaks = peaks;
MS_STRUCT.onset_pts = pk_locs;
MS_STRUCT.peak_widths = pk_widths;
MS_STRUCT.peak_proms = pk_proms;

%% Take epochs around peak artifacts in signal/s of interest, e.g. ecog signals
ms_struct = MS_STRUCT;
signal2epoch = ecog;
fs = sampling_rate_ecog;
timewindow = [-200 100]; % specify a time window in ms (duration of epoch w.r.t. event onset)

epoch_tensor = ms_getepochs(ms_struct, signal2epoch, fs, timewindow);

%% Visualizing epochs and discarding artifact-laden epochs

%% Update the struct
MS_STRUCT.fs = fs;
MS_STRUCT.timewindow = timewindow;
MS_STRUCT.epoch_tensor = epoch_tensor;
ms_struct = MS_STRUCT;

%% Get the evoked potentials
evoked_potentials = squeeze(mean(ms_struct.epoch_tensor,2)); % average all the epochs (2nd dim of epoch_tensor)

%% 
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
MS_STRUCT.evoked_potentials = evoked_potentials;
ms_struct = MS_STRUCT;

evoked_potentials = ms_meanepochs(ep_dir, ms_struct);

%% 
ms_struct = MS_STRUCT;
baselineperiod = [-200 -100];
eps_demeaned = ms_baselinecorrect(ms_struct, baselineperiod);


%%
montage = "monopolar";
eps2plot = eps_demeaned;

ms_plotEPs(ep_dir, montage, ms_struct, eps2plot)

%%

% Prepare x-axis values in ms
poststim_period = [5 100];
start_time = ms_struct.timewindow(1); % start time in ms
end_time = ms_struct.timewindow(2); % end time in ms

samples_per_ms = ms_struct.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

poststim_start_idx = find(xaxis_ms == poststim_period(1));
poststim_end_idx = find(xaxis_ms == poststim_period(2));

for e = 1:size(eps_demeaned,1)
    ep_demeaned = eps_demeaned(e,:);
    ep_poststim = ep_demeaned(poststim_start_idx:poststim_end_idx);
    eps_poststim(e,:) = ep_poststim;
end

% update timewindow
MS_STRUCT.timewindow = poststim_period;
ms_struct = MS_STRUCT;
%%
peaks_all = cell(size(eps_poststim,1),1);
pk_locs_all = cell(size(eps_poststim,1),1);
pk_widths_all = cell(size(eps_poststim,1),1);
pk_proms_all = cell(size(eps_poststim,1),1);

% display label
for e = 1:size(eps_poststim,1)
    ep_poststim = eps_poststim(e,:);
    [peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(ep_poststim);

    peaks_all(e) = {peaks};
    pk_locs_all(e) = {pk_locs};
    pk_widths_all(e) = {pk_widths};
    pk_proms_all(e) = {pk_proms};
end

% eps2detrend = eps_demeaned;
% eps_detrended = ms_detrend(eps2detrend);

%%

%% Pending to-do's
% Visualizing epochs and discarding artifact-laden epochs
% Put everything in a struct that can easily be saved