function struct = ms_getepochs(struct, time_window, signal2epoch)

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
% time_window (1x2 double)       - milliseconds before and after stimulus onset, e.g. [-20 200]
% 
% Output argument
% ---------------
% epoch_tensor (mxexp double)    - m channels (signals) x e epochs per channel x p sample points per epoch

%%
endpt_idcs = struct.segment_endpt_idcs;
pk_locs = struct.pk_locs;
signal_matrix = struct.(signal2epoch);

if strcmp(signal2epoch,'ecog') || strcmp(signal2epoch,'ecog_bipolar')
    sampling_rate = struct.sampling_rate_ecog;
elseif strcmp(signal2epoch,'lfp') || strcmp(signal2epoch,'lfp_bipolar')
    sampling_rate = struct.sampling_rate_lfp;
end
% -----
samples_per_ms = sampling_rate/1000;

start_time = time_window(1); % start time in ms
pre_onset_len = start_time*samples_per_ms; % length from starting time to event onset, in sampling units

end_time = time_window(2); % end time in ms
post_onset_len = end_time*samples_per_ms; % length from event onset to end time, in sampling units
% -----
epochs = zeros(size(signal_matrix,1), length(pk_locs), length(pre_onset_len:post_onset_len)); % channels x epochs x samples

for c = 1:size(signal_matrix,1)
    chan = signal_matrix(c,endpt_idcs(1):endpt_idcs(2)); % trim signal with the same start & end indices as segement from 'ms_trimsignal'
    
    for p = 1:length(pk_locs)
        pk_loc = pk_locs(p);
        
        if pk_loc+pre_onset_len < 1 || pk_loc+post_onset_len > length(chan) % skip if there are insufficient points before/after event onset
            continue
        end

        epoch = chan(round(pk_loc)+pre_onset_len:round(pk_loc)+post_onset_len); % pre_onset_len has negative val
        epochs(c,p,:) = epoch; % epoch for channel 'c' around event onset 'o'
    end
end

struct.time_window = time_window;
struct.(append(signal2epoch,'_epochs')) = epochs;
end