addpath("/Users/margaritasison/GitHub/stimEP/functions/")
datadir = "/Users/margaritasison/Downloads/ORdata_copes_MS/";
ephys = "ephys015/";

% addpath("C:\Users\Miocinovic_lab\Documents\mssison\GitHub\stimEP\functions\")
% datadir = "C:\Users\Miocinovic_lab\Documents\mssison\ORdata_copies_MS\";
% ephys = "ephys015\";

signaltype = "emg";

ms_plotsignals(datadir, ephys, signaltype)
%%
signal2trim = emg(3,:);
[start_idx, end_idx, segment] = ms_trimsignal(signal2trim);
%[~, ~, segment] = ms_trimsignal(signal2trim);

%%
[peaks, pk_locs, pk_widths, pk_proms, min_prom] = ms_findpeaks(segment);

%%


