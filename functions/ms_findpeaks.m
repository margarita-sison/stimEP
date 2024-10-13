function struct = ms_findpeaks(struct)

% Function
% --------
% Finds peaks (local maxima) in a signal based on a user-specified
% minimum threshold. The threshold is defined as a percentage of the maximum peak
% prominence.
% 
% Input arguments 
% ---------------
% ephys (char or str)       - ephys code, e.g. "ephys001"
% segment (1xn double)      - signal to extract peaks from
% segment_label (cell)      - label of segment, e.g. {'L FDI'}
% 
% Output arguments
% ----------------
% peaks (1xn double)        - local maxima (y-values)
% pk_locs (1xn double)      - peak locations (x-values)
% pk_widths (1xn double)    - peak widths (as defined in MATLAB)
% pk_proms (1xn double)     - peak prominences (as defined in MATLAB)

ephys_code = struct.ephys_code;
ephys_folder = struct.ephys_folder;

emg2trim_idx = struct.emg2trim_idx;
emg_segment = struct.emg_segment;
emg2trim_label = char(struct.emg2trim_label);

sampling_rate = struct.sampling_rate_emg;
%% Find the maximum peak prominence in the signal
[~, ~, ~, pk_proms] = findpeaks(emg_segment); 
max_prom = max(pk_proms);

%% Let user specify a minimum threshold (% of maximum  peak prominence expressed as a decimal)
threshold = input('Enter threshold as decimal: '); % percentage of maximum peak prominence expressed as a decimal
min_prom = threshold*max_prom; % e.g., 90% of max. peak prominence

%% Display peaks detected based on the specified threshold
fig = figure; % prepare fig container
fig.WindowState = 'maximized';
findpeaks(emg_segment,'MinPeakProminence',min_prom)

%% Provide the option to adjust threshold
user_ans = input('Adjust threshold? [Y/N]: ', 's');

while user_ans == "Y"
    threshold = input('Enter threshold as decimal: ');
    min_prom = threshold*max_prom;

    fig = figure; % prepare fig container
    fig.WindowState = 'maximized';
    findpeaks(emg_segment,'MinPeakProminence',min_prom) 

    user_ans = input('Adjust threshold? [Y/N]: ','s');
end

%% Call 'findpeaks' with minimum peak prominence specified
[peaks, pk_locs, pk_widths, pk_proms] = findpeaks(emg_segment,'MinPeakProminence',min_prom);
title(ephys_code+" - emg("+emg2trim_idx+",:) "+emg2trim_label,'FontWeight','bold')
xlabel("Sampling units (a.u.)"), ylabel("Amplitude (µV)")

%%

for p = 1:length(pk_locs)-1
    if p >= length(pk_locs)
        continue 
    end

    if pk_locs(p+1)-pk_locs(p) < sampling_rate*0.97
        peaks(p+1) = 0;
        pk_locs(p+1) = 0;
        pk_widths(p+1) = 0;
        pk_proms(p+1) = 0;
        
        peaks = nonzeros(peaks);
        pk_locs = nonzeros(pk_locs);
        pk_widths = nonzeros(pk_widths);
        pk_proms = nonzeros(pk_proms);
    end
end

for p = 1:length(pk_locs)-1
    if p >= length(pk_locs)
        continue 
    end

    if pk_locs(p+1)-pk_locs(p) < sampling_rate*0.97
        peaks(p+1) = 0;
        pk_locs(p+1) = 0;
        pk_widths(p+1) = 0;
        pk_proms(p+1) = 0;
        
        peaks = nonzeros(peaks);
        pk_locs = nonzeros(pk_locs);
        pk_widths = nonzeros(pk_widths);
        pk_proms = nonzeros(pk_proms);
    end
end
      
struct.peaks = peaks;
struct.pk_locs = pk_locs;
struct.pk_widths = pk_widths;
struct.pk_proms = pk_proms;

saveas(fig, append(ephys_folder,'/emg_segment_peaks'))
end