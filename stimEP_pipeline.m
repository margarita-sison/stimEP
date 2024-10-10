%% Prepare workspace ======================================================

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

%% Visually inspect EMG signals before selecting a template EMG signal ====
EPHYS_STRUCT.emg = emg;
EPHYS_STRUCT.emg_labels = emg_labels;

ms_plotemg(EPHYS_STRUCT);

%% Trim the template EMG signal before extracting stimulus artifact peaks =
emg2trim_idx = input('Specify index of EMG signal to trim, e.g. 1: ');
emg2trim = emg(emg2trim_idx,:);
emg2trim_label = emg_labels(emg2trim_idx);

EPHYS_STRUCT.emg2trim_idx = emg2trim_idx;
EPHYS_STRUCT.emg2trim = emg2trim;
EPHYS_STRUCT.emg2trim_label = emg2trim_label;

EPHYS_STRUCT = ms_trimemg(EPHYS_STRUCT);

%% Extract stimulus artifact peaks from template EMG signal ===============
EPHYS_STRUCT = ms_findpeaks(EPHYS_STRUCT);

%% Do bipolar re-referencing on ECoG or LFP signals =======================
EPHYS_STRUCT.ecog = ecog;
EPHYS_STRUCT.lfp = lfp;

signal_type = input('Specify type of signal to re-reference, e.g. lfp: ', 's');
EPHYS_STRUCT = ms_refbipolar(EPHYS_STRUCT, signal_type);

%% Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
EPHYS_STRUCT.sampling_rate_ecog = sampling_rate_ecog;
EPHYS_STRUCT.sampling_rate_lfp = sampling_rate_lfp;

time_window = input('Specify time window in ms w.r.t. stimulus onset, e.g. [-20 100]: ');
signal_type = input('Specify type of signal to get epochs from, e.g. lfp_bipolar: ', 's');
sampling_rate = input('Specify sampling rate of signals: ', 's');

EPHYS_STRUCT = ms_getepochs(EPHYS_STRUCT, time_window, signal_type, sampling_rate);
saveas(append(ephys_folder,'/EPHYS_STRUCT.mat'))

%% Plot epochs
epochs2plot = input('Specify epochs to plot, e.g. lfp_bipolar_epochs: ', 's');
n_epochs = input()
ms_plotepochs(EPHYS_STRUCT, epochs2plot, n_epochs)

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
signal_type = input('Specify tensor to generate EPs from, e.g. lfp_bipolar_epochs: ', 's');
signal_tensor = struct.(signal_type);

evoked_potentials = squeeze(mean(signal_tensor,2)); % average all the epochs per channel (2nd dimension of signal_tensor)
EPHYS_STRUCT.(append(signal_type(1:end-7),'_EPs')) = evoked_potentials;
 
%% PLOTTING -
EPs2plot = input('Specify EP matrix to plot, e.g. ecog_bipolar_EPs: ','s');
sampling_rate = input('Specify sampling rate of signals: ', 's');
EPs2plot_labels = input('Specify channel labels to use, e.g. EP.channelLocsSimpleBipolar: ');

ms_plotEPs(EPHYS_STRUCT, EPs2plot, sampling_rate, EPs2plot_labels)
%%%

%% Average evoked potentials from the same region (e.g, primary motor cortex)
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
chanlabels = "channelLocsSimpleBipolar";
ms_struct = EPHYS_STRUCT;
eps2average = eps_demeaned;

[EPs_by_roi, rois] = ms_EPs_by_roi(EPHYS_STRUCT, eps2average);
EPHYS_STRUCT.EPs_by_roi = EPs_by_roi;
EPHYS_STRUCT.rois = rois;
ms_struct = EPHYS_STRUCT;

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

EPHYS_STRUCT.poststim_peaks_all = poststim_peaks_all;
EPHYS_STRUCT.poststim_pkwidths_all = poststim_pkwidths_all;
EPHYS_STRUCT.poststim_pkproms_all = poststim_pkproms_all;

%% 11 - Plot average evoked potentials by brain region
ms_struct = EPHYS_STRUCT;
roi_order = [3 2 1 4];
ms_plotEPs_by_roi(EPHYS_STRUCT, roi_order)
 