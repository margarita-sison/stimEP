function struct = ms_trimemg(struct)

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

ephys_code = struct.ephys_code;
ephys_folder = struct.ephys_folder;

emg2trim_idx = struct.emg2trim_idx;
emg2trim = struct.emg2trim;
emg2trim_label = char(struct.emg2trim_label);

fig = figure; % prepare fig container
fig.WindowState = 'maximized';

plot(emg2trim) % plot the signal  
[x, ~] = ginput(2); % prompt the user to select 2 points

start_idx = round(x(1)); % get the starting index (xval) of segment in the original signal
end_idx = round(x(2)); % get the end index (xval) of segment in the original signal
endpt_idcs = [start_idx end_idx];

emg_segment = emg2trim(endpt_idcs(1):endpt_idcs(2)); % use the start & end indices to trim the original signal
plot(emg_segment) % plot the resulting segment

title(ephys_code+" - emg("+emg2trim_idx+",:) "+emg2trim_label,'FontWeight','bold')
xlabel("Sampling units (a.u.)"), ylabel("Amplitude (µV)")

struct.emg_segment = emg_segment;
struct.segment_endpt_idcs = endpt_idcs;

saveas(fig, append(ephys_folder,'/emg_segment'))
end