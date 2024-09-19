function [epoch_tensor, ppt] = ms_getepochs(signal2epoch, timewindow, fs, makeppt)
% Function
% --------
% Add description
% 
% Input arguments
% ---------------
% signal2epoch (char or str)    - signal to epoch, e.g. "ecog"
% timewindow (1x2 double)       - milliseconds before and after peak, e.g. [-20 200]
% fs (double)                   - sampling rate of signal to epoch
% makeppt (logical)             - generates a ppt containing all the epochs if makeppt == 1
%
% Output Arguments
% ----------------
% epoch_tensor (3-dim double)   - 
% ppt

n_chans = size(signal2epoch,1);

samples_per_ms = fs/1000;

start_time = timewindow(1);
pre_peak_len = start_time*samples_per_ms;

end_time = timewindow(2);
post_peak_len = end_time*samples_per_ms;

epoch_tensor = zeros(n_chans, length(pk_locs), length(pre_peak_len:post_peak_len));

for c = 1:length(n_chans)
    chan = signal2epoch(c,:);

    for p = 1:length(pk_locs)
        pk_loc = pk_locs(p);
        
        if 
            continue
        end
        epoch = chan(pk_loc+pre_peak_len:pk_loc+post_peak_len);

        epoch_tensor(c,p,:) = epoch;
    end
end

if makeppt == 1
    %yaxis = -20:1/22:200
end