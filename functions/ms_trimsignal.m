function [segment, start_idx, end_idx] = ms_trimsignal(signal2trim)
% Function
% --------
% Trims a signal and saves the resulting segment and its endpoints
% 
% Input arguments
% ---------------
% signal2trim (1xn double)  - signal to trim, n = number of samples
% 
% Output arguments
% ----------------
% segment (1xn double)      - resulting segment, n = number of samples
% start_idx (double)        - starting index (xval) of segment in the original signal
% end_idx (double)          - end index (xval) of segment in the original signal

fig = figure; % prepare fig container
fig.WindowState = 'maximized';

plot(signal2trim) % plot the signal  
[x, ~] = ginput(2); % prompt the user to select 2 points

start_idx = round(x(1)); % get the starting index (xval) of segment in the original signal
end_idx = round(x(2)); % get the end index (xval) of segment in the original signal

segment = signal2trim(start_idx:end_idx); % use the start & end indices to trim the original signal
plot(segment) % plot the resulting segment
end