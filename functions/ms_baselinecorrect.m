function eps_demeaned = ms_baselinecorrect(MS_STRUCT, baselineperiod)
% Function
% --------
% Subtracts the mean of a specified baseline period from every point in the
% time series
% 
% Input arguments
% ---------------
% ms_struct (struct)                    - struct containing:
%       evoked_potentials (mxn double)  : matrix of signals, e.g. from ecog or lfp; m = number of signals (channels), n = sample points
%       timewindow (1x2 double)         : milliseconds before and after stimulus onset, e.g. [-20 200]
%       fs (double)                     : sampling rate of signals (samples per second)
% baselineperiod (1x2 double)           - endpoints of baseline period in milliseconds w.r.t. stimulus onset, e.g. [20 200]
% 
% Output argument
% ---------------
% eps_demeaned (mxn double)             - baseline-corrected evoked potentials  

evoked_potentials = MS_STRUCT.evoked_potentials; 
eps_demeaned = zeros(size(evoked_potentials,1), size(evoked_potentials,2)); % empty container for baseline-corrected EPs

% Prepare x-axis values in ms
start_time = MS_STRUCT.timewindow(1); % start time of EPs in ms
end_time = MS_STRUCT.timewindow(2); % end time of EPs in ms

samples_per_ms = MS_STRUCT.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms
%%%

bs_start_idx = find(xaxis_ms == baselineperiod(1)); % baseline start index
bs_end_idx = find(xaxis_ms == baselineperiod(2)); % baseline end index

for e = 1:size(evoked_potentials,1)
    evoked_potential = evoked_potentials(e,:);

    baseline = evoked_potential(bs_start_idx:bs_end_idx); % baseline period
    baseline_mean = mean(baseline); % mean of baseline period

    ep_demeaned = evoked_potential-baseline_mean; % subtract mean of baseline period from time series
    eps_demeaned(e,:) = ep_demeaned;
end
MS_STRUCT.eps_demeaned = eps_demeaned;
evalin('base',MS_STRUCT)
end