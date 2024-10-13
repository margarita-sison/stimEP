function x_lfilt = ms_lfilt(x, fs, cutoff)
% Function
% --------
% Add description
% 
% Input arguments
% ---------------
%

[b_low, a_low] = butter(2, cutoff/(fs/2), "low");
x_lfilt = filtfilt(b_low, a_low, x);
end