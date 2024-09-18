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

% Convert signal to time domain




start_time = timewindow(1);
end_time = timewindow(2);


end