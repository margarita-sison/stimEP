function x_hfilt = ms_hfilt(x, fs, cutoff)
% Function
% --------
% Add description
% 
% Input arguments
% ---------------
% x (data type) - add description
% fs
% cutoff
% 
% Output
% ------
% x_hfilt

[b_high, a_high] = butter(2, cutoff/(fs/2), "high");
x_hfilt = filtfilt(b_high, a_high, x);
end