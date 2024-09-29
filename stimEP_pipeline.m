%% What you can do with this pipeline:
% 1 - Visually inspect EMG signals before selecting a template EMG signal
% 2 - Trim the template EMG signal before extracting stimulus artifact peaks
% 3 - Extract stimulus artifact peaks from template EMG signal
% 4 - Align stimulus artifact peaks in template EMG signal with ECOG and/or LFP signals
% 5 - Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
% 6 - Average epochs to generate evoked potentials
% 7 - Apply a baseline correction to the evoked potentials
% 8 - Detrend evoked potentials if necessary
% 9 - Average evoked potentials from the same brain region (e.g, primary motor cortex)
% 10 - Extract post-stimuulus peaks from evoked potentials
%% 1 - Visually inspect EMG signals before selecting a template EMG signal
% Add path to functions directory + "/" if Mac or "\" if Windows (functions
% directory = functions folder containing all the functions used in this
% pipeline)
%addpath("C:\Users\Miocinovic_lab\Documents\mssison\GitHub\stimEP\functions\") 
addpath("/Users/margaritasison/GitHub/stimEP/functions/") 

% Add path to directory containing ephys files + "/" if Mac or "\" if Windows 
%datadir = "C:\Users\Miocinovic_lab\Documents\mssison\ORdata_copies_MS\"; 
datadir = "/Users/margaritasison/Downloads/ORdata_copes_MS/"; 

% Specify ephys code + "/" if Mac or "\" if Windows 
%ephys = "ephys015\"; 
ephys = "ephys015/"; 

signaltype = "emg"; % specify as char or string

ms_plotsignals(datadir, ephys, signaltype)

% Save info that will be useful later on in a struct
MS_STRUCT = struct;
ephys = char(ephys);
MS_STRUCT.ephys = ephys(1:end-1);

%% 2 - Trim the template EMG signal before extracting stimulus artifact peaks
% After visually inspecting the signal, you may want to only use a part of
% it
signal2trim = emg(3,:); % emg(3,:) = R FCR
[segment, endpt_idcs] = ms_trimsignal(signal2trim);

MS_STRUCT.template_segment = segment;
MS_STRUCT.template_endpts = endpt_idcs;

%% 3 - Extract stimulus artifact peaks from template EMG signal
[peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(segment);

MS_STRUCT.peaks = peaks;
MS_STRUCT.onset_pts = pk_locs; % peaks = proxy for stimulus onset points
MS_STRUCT.peak_widths = pk_widths;
MS_STRUCT.peak_proms = pk_proms;

%% 4 - Align stimulus artifact peaks in template EMG signal with ECOG and/or LFP signals
%% % 5 - Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
ms_struct = MS_STRUCT;
signal2epoch = ecog;
fs = sampling_rate_ecog; 
timewindow = [-20 200]; % specify a time window in ms (w.r.t. stimulus onset)

epoch_tensor = ms_getepochs(ms_struct, signal2epoch, fs, timewindow);

MS_STRUCT.fs = fs;
MS_STRUCT.timewindow = timewindow;
MS_STRUCT.epoch_tensor = epoch_tensor;
ms_struct = MS_STRUCT;

%% 6 - Average epochs to generate evoked potentials
evoked_potentials = squeeze(mean(ms_struct.epoch_tensor,2)); % average all the epochs per channel (2nd dimension of epoch_tensor)
MS_STRUCT.evoked_potentials = evoked_potentials;

%%% run this block to plot signals for a visual check
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
montage = "monopolar";
ms_struct = MS_STRUCT;
eps2plot = evoked_potentials;

ms_plotEPs(ep_dir, montage, ms_struct, eps2plot)
%%%

%% 7 - Apply a baseline correction to the evoked potentials
ms_struct = MS_STRUCT;
baselineperiod = [5 200]; 

eps_demeaned = ms_baselinecorrect(ms_struct, baselineperiod);
MS_STRUCT.eps_demeaned = eps_demeaned;

%%% run this block to plot signals for a visual check
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
montage = "monopolar";
ms_struct = MS_STRUCT;
eps2plot = eps_demeaned;

ms_plotEPs(ep_dir, montage, ms_struct, eps2plot)
%%%

%% 8 - Detrend evoked potentials if necessary
eps_detrended = zeros(size(evoked_potentials,1), size(evoked_potentials,2));
for e = 1:size(evoked_potentials,1)
    evoked_potential = evoked_potentials(e,:);
    ep_detrended = detrend(evoked_potential);
    eps_detrended(e,:) = ep_detrended;
end

MS_STRUCT.eps_detrended = eps_detrended;

%%% run this block to plot signals for a visual check
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
montage = "monopolar";
ms_struct = MS_STRUCT;
eps2plot = eps_detrended;

ms_plotEPs(ep_dir, montage, ms_struct, eps2plot)
%%%

%% 9 - Average evoked potentials from the same region (e.g, primary motor cortex)
%ep_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ep_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
montage = "monopolar";
ms_struct = MS_STRUCT;
eps2average = eps_demeaned;

[EPs_by_roi, rois] = ms_EPs_by_roi(ep_dir, montage, ms_struct, eps2average);
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
ms_struct = MS_STRUCT;

%%



%% Pending to-do's
% Visualizing epochs and discarding artifact-laden epochs
 