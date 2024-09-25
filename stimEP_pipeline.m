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

EP_STRUCT = struct; % save info that will be useful later in a struct
EP_STRUCT.ephys = ephys(1:end-1);

%% Trim the template signal (upon visual inspection, you may want to only use a segment of the template signal)
signal2trim = emg(3,:); 
[segment, endpt_idcs] = ms_trimsignal(signal2trim);

EP_STRUCT.template_segment = segment;
EP_STRUCT.template_endpts = endpt_idcs;

%% Extract location of peak artifacts along the segment
[peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(segment);

EP_STRUCT.peaks = peaks;
EP_STRUCT.peak_locs = pk_locs;
EP_STRUCT.peak_widths = pk_widths;
EP_STRUCT.peak_proms = pk_proms;

%% Take epochs around peak artifacts in signal/s of interest, e.g. ecog signals
signal2epoch = ecog;
fs = sampling_rate_ecog;
onset_pts = pk_locs;
timewindow = [-20 100];

epoch_tensor = ms_getepochs(signal2epoch, fs, endpt_idcs, onset_pts, timewindow);

%% Visualizing epochs and discarding artifact-laden epochs

%%
%EP_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
EP_dir = "/Users/margaritasison/Downloads/EPdata_10-21-2022_ANALYZED_postopMRI.mat/";
ephys_num = 15;
 
ms_meanepochs(EP_dir, ephys_num, epoch_tensor, fs, timewindow)

%% Pending to-do's
% Visualizing epochs and discarding artifact-laden epochs
% Put everything in a struct that can easily be saved