function [segment, endpt_idcs] = ms_trimsignal(ephys, signal2trim, signal2trim_label)

% Function
% --------
% Trims a signal and saves the resulting segment and its endpoints
% 
% Input arguments
% ---------------
% ephys (char or str)       - ephys code, e.g. "ephys001"
% signal2trim (1xn double)  - signal to trim, n = number of samples
% signal2trim_label (cell)  - label of signal to trim, e.g. {'L FDI'}

% Output arguments
% ----------------
% segment (1xn double)      - resulting segment, n = number of samples
% endpt_idcs (1x2 double)   - starting and end indices (xvals) of segment in the original signal

signal2trim_label = char(signal2trim_label);

disp('Select stimEP_outputs folder as save location:')
output_folder = uigetdir;

fig = figure; % prepare fig container
fig.WindowState = 'maximized';

plot(signal2trim) % plot the signal  
[x, ~] = ginput(2); % prompt the user to select 2 points

start_idx = round(x(1)); % get the starting index (xval) of segment in the original signal
end_idx = round(x(2)); % get the end index (xval) of segment in the original signal
endpt_idcs = [start_idx end_idx];

segment = signal2trim(endpt_idcs(1):endpt_idcs(2)); % use the start & end indices to trim the original signal
plot(segment) % plot the resulting segment

title(append(ephys,' - ',signal2trim_label),'FontWeight','bold')
xlabel("Sampling units (a.u.)"), ylabel("Amplitude (µV)")

saveas(fig, append(output_folder,'/',ephys,'_',signal2trim_label,'.png'))
end