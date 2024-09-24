%% Currently implemented processes in this pipeline:
% - Visualizing EMG signals
% - Aligning stimulus artifacts in EMG signals with ECOG or LFP signals
% - Extracting epochs from ECOG or LFP signals
% - Visualizing ECOG or LFP evoked potentials (average of epochs)

%% Visualize EMG signals and select a template signal 

addpath("C:\Users\Miocinovic_lab\Documents\mssison\GitHub\stimEP\functions\") % add path to functions directory + "/" if Mac or "\" if Windows 
datadir = "C:\Users\Miocinovic_lab\Documents\mssison\ORdata_copies_MS\"; % add path to directory containing ephys files + "/" if Mac or "\" if Windows 
ephys = "ephys015\"; % specify ephys code + "/" if Mac or "\" if Windows 

addpath("/Users/margaritasison/GitHub/stimEP/functions/") 
datadir = "/Users/margaritasison/Downloads/ORdata_copes_MS/"; 
ephys = "ephys015/"; 

signaltype = "emg"; % specify as char or string

ms_plotsignals(datadir, ephys, signaltype)

%% Trim the template signal (upon visual inspection, you may want to only use a segment of the template signal)
signal2trim = emg(3,:); 
[segment, start_idx, end_idx] = ms_trimsignal(signal2trim);

%%
[peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(segment);

%%
signal2epoch = ecog;
timewindow = [-20 200];
fs = sampling_rate_ecog;

[start_time, end_time, epoch_tensor] = ms_getepochs(signal2epoch, timewindow, pk_locs, start_idx, end_idx, fs);

%%
%EP_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ephys_num = 15;

ms_meanepochs(EP_dir, ephys_num, epoch_tensor, start_time, end_time, fs)
