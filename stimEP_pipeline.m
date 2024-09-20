% addpath("/Users/margaritasison/GitHub/stimEP/functions/")
% datadir = "/Users/margaritasison/Downloads/ORdata_copes_MS/";
% ephys = "ephys015/";

addpath("C:\Users\Miocinovic_lab\Documents\mssison\GitHub\stimEP\functions\")
datadir = "C:\Users\Miocinovic_lab\Documents\mssison\ORdata_copies_MS\";
ephys = "ephys015\";

signaltype = "emg";

ms_plotsignals(datadir, ephys, signaltype)
%%
signal2trim = emg(3,:);
[start_idx, end_idx, segment] = ms_trimsignal(signal2trim);
%[~, ~, segment] = ms_trimsignal(signal2trim);

%%
[peaks, pk_locs, pk_widths, pk_proms, min_prom] = ms_findpeaks(segment);

%%
signal2epoch = ecog;
timewindow = [-20 200];
fs = sampling_rate_ecog;

[start_time, end_time, epoch_tensor] = ms_getepochs(signal2epoch, timewindow, pk_locs, start_idx, end_idx, fs);

%%
EP_dir = "C:\Users\Miocinovic_lab\Documents\mssison\EPdata_10-21-2022_ANALYZED_postopMRI.mat\";
ephys_num = 15;

ms_meanepochs(EP_dir, ephys_num, epoch_tensor, start_time, end_time, fs)
