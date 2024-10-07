%% Prepare workspace
% Add path to folder containing all the functions used here
disp('Select functions folder: ')
fxndir = uigetdir; 
addpath(append(fxndir, '/'))

% Load EP struct
disp('Load EP struct: ')
[ep_file, ep_fileloc] = uigetfile;
load(append(ep_fileloc, ep_file))

% Load SSEP file
disp('Load SSEP file: ')
[ssep_file, ssep_fileloc] = uigetfile;
load(append(ssep_fileloc, ssep_file))

% Make output folder
disp('Select save location for output folder: ')
savedir = uigetdir;

output_folder = strcat(savedir,'/stimEP_outputs/');
if ~isfolder(output_folder)
    mkdir(output_folder)
end

ephys = input('Specify ephys code, e.g. ephys001: ', 's');

%% Visually inspect EMG signals before selecting a template EMG signal
ms_plotemg(ephys, emg, emg_labels);

%% Trim the template EMG signal before extracting stimulus artifact peaks
emg2trim_num = input('Specify EMG signal to trim, e.g. 1: ');
emg2trim = emg(emg2trim_num,:);
emg2trim_label = emg_labels(emg2trim_num);

[segment, endpt_idcs] = ms_trimsignal(ephys, emg2trim, emg2trim_label);

%% Extract stimulus artifact peaks from template EMG signal
[peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(ephys, segment, emg2trim_label);

%% Re-reference ECoG signals in a bipolar montage using adjacent contacts
ecog_bipolar = ms_bipolarchans(ecog);

%% Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
signal2epoch = input('Specify signal to epoch, e.g. lfp: ');
fs = input('Specify sampling rate: ');
timewindow = input('Specify time window in ms w.r.t. stimulus onset, e.g. [-20 100]: ');

[epoch_tensor, MS_STRUCT] = ms_getepochs(MS_STRUCT, signal2epoch, fs, timewindow);

%% Average epochs to generate EPs
evoked_potentials = squeeze(mean(epoch_tensor,2)); % average all the epochs per channel (2nd dimension of epoch_tensor)
MS_STRUCT.evoked_potentials = evoked_potentials;
 
%% Apply a baseline correction to the evoked potentials
baselineperiod = input('Specify a baseline period, e.g. [5 100]: ');
[eps_demeaned, MS_STRUCT] = ms_baselinecorrect(MS_STRUCT, baselineperiod);

%% Detrend evoked potentials if necessary
option2detrend = input('Detrend EPs? [Y/N]: ','s');
if option2detrend == 'Y'
    signals2detrend = input('Specify signal to detrend, e.g. evoked_potentials: ');
    [eps_detrended, MS_STRUCT] = ms_detrend(MS_STRUCT, signals2detrend);
else
end

%% PLOTTING -
eps2plot = eps_demeaned;
ms_plotEPs(MS_STRUCT, eps2plot)
%%%

%% Average evoked potentials from the same region (e.g, primary motor cortex)
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
chanlabels = "channelLocsSimpleBipolar";
ms_struct = MS_STRUCT;
eps2average = eps_demeaned;

[EPs_by_roi, rois] = ms_EPs_by_roi(MS_STRUCT, eps2average);
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
ms_plotEPs_by_roi(MS_STRUCT, roi_order)

%% Pending to-do's
% Visualize epochs and discard artifact-laden epochs