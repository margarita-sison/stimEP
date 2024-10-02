function [peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(MS_STRUCT, segment)

% Function
% --------
% Finds peaks (local maxima) in a signal based on a user-specified
% minimum threshold. The threshold is defined as a percentage of the maximum peak
% prominence.
% 
% Input arguments 
% ---------------
% segment (1xn double)      - signal to extract peaks from
% 
% Output arguments
% ----------------
% peaks (1xn double)        - local maxima (y-values)
% pk_locs (1xn double)      - peak locations (x-values)
% pk_widths (1xn double)    - peak widths (as defined in MATLAB)
% pk_proms (1xn double)     - peak prominences (as defined in MATLAB)

%% Find the maximum peak prominence in the signal
[~, ~, ~, pk_proms] = findpeaks(segment); 
max_prom = (max(pk_proms));

%% Let user specify a minimum threshold (% of maximum  peak prominence expressed as a decimal)
threshold = input('Enter threshold as decimal: '); % percentage of maximum peak prominence expressed as a decimal
min_prom = threshold*max_prom; % e.g., 90% of max. peak prominence

%% Display peaks detected based on the specified threshold
figure;
findpeaks(segment,'MinPeakProminence',min_prom)

%% Provide the option to adjust threshold
user_ans = input('Adjust threshold? Y/N: ',"s");

while user_ans == "Y"
    threshold = input('Enter threshold as decimal: ');
    min_prom = threshold*max_prom;

    figure;
    findpeaks(segment,'MinPeakProminence',min_prom) 

    user_ans = input('Adjust threshold? Y/N: ',"s");
end

%% Call 'findpeaks' with minimum peak prominence specified
[peaks, pk_locs, pk_widths, pk_proms] = findpeaks(segment,'MinPeakProminence',min_prom);

MS_STRUCT.peaks = peaks;
MS_STRUCT.onset_pts = pk_locs; % peaks = proxy for stimulus onset points
MS_STRUCT.peak_widths = pk_widths;
MS_STRUCT.peak_proms = pk_proms;
evalin('base',MS_STRUCT)
end