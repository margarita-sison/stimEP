function [epoch_tensor, MS_STRUCT] = ms_getepochs(MS_STRUCT, signal2epoch, fs, timewindow)

% Function
% --------
% Takes epochs from target signal/s based on a user-specified
% time window around an event (e.g., stimulus onset)
% 
% Input arguments 
% ---------------
% MS_STRUCT (struct)            - struct containing:
%       endpt_idcs (1x2 double) : starting and end indices (xvals) of segment from which onset points were taken (for alignment purposes)
%       onset_pts (1xn double)  : vector of event onset points, e.g. stimulus artifact peak locations
% signal2epoch (mxn double)     - signal/s to epoch, e.g. ecog or lfp; m = number of signals (channels), n = sample points
% fs (double)                   - sampling rate of signal to epoch (samples per second)
% timewindow (1x2 double)       - milliseconds before and after stimulus onset, e.g. [-20 200]
% 
% Output argument
% ---------------
% epoch_tensor (mxexp double)    - m channels (signals) x e epochs per channel x p sample points per epoch

n_chans = size(signal2epoch,1); % number of channels
samples_per_ms = fs/1000; % samples per ms

start_time = timewindow(1); % start time in ms
pre_onset_len = start_time*samples_per_ms; % length from starting time to event onset, in sampling units

end_time = timewindow(2); % end time in ms
post_onset_len = end_time*samples_per_ms; % length from event onset to end time, in sampling units

onset_pts = MS_STRUCT.onset_pts;
epoch_tensor = zeros(n_chans, length(onset_pts), length(pre_onset_len:post_onset_len)); % channels x epochs x samples

endpt_idcs = MS_STRUCT.template_endpts;
for c = 1:n_chans
    chan = signal2epoch(c,endpt_idcs(1):endpt_idcs(2)); % trim signal with the same start & end indices as segement from 'ms_trimsignal'
    
    for o = 1:length(onset_pts)
        onset_pt = onset_pts(o);
        
        if onset_pt+pre_onset_len < 1 || onset_pt+post_onset_len > length(chan) % skip if there are insufficient points before/after event onset
            continue
        end

        epoch = chan(onset_pt+pre_onset_len:onset_pt+post_onset_len); % pre_onset_len has negative val
        epoch_tensor(c,o,:) = epoch; % epoch for channel 'c' around event onset 'o'
    end
end

MS_STRUCT.fs = fs;
MS_STRUCT.timewindow = timewindow;
MS_STRUCT.epoch_tensor = epoch_tensor;
 
end