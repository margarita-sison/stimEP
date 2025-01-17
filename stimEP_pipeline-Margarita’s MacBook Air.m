%% Visually inspect EMG signals before selecting a template EMG signal
% Add path to folder containing all the functions used here
fxndir = uigetdir(cd, 'Select Functions Folder'); 
addpath(append(fxndir,'/'))

% Add path to folder containing all the ephys files 
datadir = uigetdir(cd, 'Select OR Data Folder');
datadir = append(datadir,'/');

% Specify ephys code 
ephys = input('Specify ephys code, e.g. ephys001: ','s');
ephys = append(ephys,'/'); 

% Specify signal type to plot
signaltype = input('Specify signal type to plot: ','s');

ms_plotsignals(datadir, ephys, signaltype)

%% Trim the template EMG signal before extracting stimulus artifact peaks
% After visually inspecting the signal, you may want to only use a part of it
signal2trim = input('Specify signal to trim, e.g. emg(1,:): ');
[segment, endpt_idcs] = ms_trimsignal(MS_STRUCT, signal2trim);

%% Extract stimulus artifact peaks from template EMG signal
[peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(MS_STRUCT, segment);

%% Re-reference ECoG signals in a bipolar montage using adjacent contacts
ecog_bipolar = ms_bipolarchans(MS_STRUCT, ecog);

%% Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
signal2epoch = input('Specify signal to epoch, e.g. lfp: ');
fs = input('Specify sampling rate: ');
timewindow = input('Specify time window in ms w.r.t. stimulus onset, e.g. [-20 100]: ');

epoch_tensor = ms_getepochs(MS_STRUCT, signal2epoch, fs, timewindow);

%% Average epochs to generate EPs
evoked_potentials = squeeze(mean(epoch_tensor,2)); % average all the epochs per channel (2nd dimension of epoch_tensor)
MS_STRUCT.evoked_potentials = evoked_potentials;
 
%% Apply a baseline correction to the evoked potentials
baselineperiod = input('Specify a baseline period, e.g. [5 100]: ');
eps_demeaned = ms_baselinecorrect(MS_STRUCT, baselineperiod);

%% Detrend evoked potentials if necessary
option2detrend = input('Detrend EPs? [Y/N]: ','s');
if option2detrend == 'Y'
    signals2detrend = input('Specify signal to detrend, e.g. evoked_potentials: ');
    eps_detrended = ms_detrend(MS_STRUCT, signals2detrend);
else
end

%% PLOTTING -
ecog_or_lfp = 'lfp';
eps2plot = eps_demeaned;

ms_plotEPs(ep_dir, chanlabels, ms_struct, eps2plot)
%%%

%% Average evoked potentials from the same region (e.g, primary motor cortex)
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
chanlabels = "channelLocsSimpleBipolar";
ms_struct = MS_STRUCT;
eps2average = eps_demeaned;

[EPs_by_roi, rois] = ms_EPs_by_roi(ep_dir, chanlabels, ms_struct, eps2average);
MS_STRUCT.EPs_by_roi = EPs_by_roi;
MS_STRUCT.rois = rois;
ms_struct = MS_STRUCT;

%% 10 - Extract post-stimuulus peaks from evoked potentials
% prepare empty cell containers for storing peak values
poststim_peaks_all = cell(size(EPs_by_roi,1),1);
poststim_pklocs_all = cell(size(EPs_by_roi,1),1);
poststim_pkwidths_all = cell(size(EPs_by_roi,1),1);
poststim_pkproms_all = cell(size(EPs_by_roi,1),1);

%%%
poststim_markers = [5 100]; % time point markers in ms w.r.t. stimulus onset (for post-stimulus peak extraction purposes only)

start_time = ms_struct.timewindow(1); % start time in ms
end_time = ms_struct.timewindow(2); % end time in ms
samples_per_ms = ms_struct.fs/1000; % sampling rate in ms
xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms
%%%

for a = 1:size(EPs_by_roi,1)
    EP_by_roi = EPs_by_roi(a,:);
    [peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(EP_by_roi(find(xaxis_ms == poststim_markers(1)):find(xaxis_ms == poststim_markers(2))));

    poststim_peaks_all(a) = {peaks};
    poststim_pklocs_all(a) = {pk_locs};
    poststim_pkwidths_all(a) = {pk_widths};
    poststim_pkproms_all(a) = {pk_proms};
end

MS_STRUCT.poststim_peaks_all = poststim_peaks_all;
MS_STRUCT.poststim_pkwidths_all = poststim_pkwidths_all;
MS_STRUCT.poststim_pkproms_all = poststim_pkproms_all;

%% 11 - Plot average evoked potentials by brain region
ms_struct = MS_STRUCT;
roi_order = [3 2 1 4];
ms_plotEPs_by_roi(ms_struct, roi_order)

%% Pending to-do's
% Visualize epochs and discard artifact-laden epochs