function [peaks, pk_locs, pk_widths, pk_proms] = ms_findpeaks(ephys, segment, segment_label)

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

segment_label = char(segment_label);

disp('Select stimEP_outputs folder as save location:')
output_folder = uigetdir;

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
title(append(ephys,' - ',segment_label),'FontWeight','bold')
xlabel("Sampling units (a.u.)"), ylabel("Amplitude (µV)")

saveas(gcf, append(output_folder,'/',ephys,'_',segment_label,'_peaks.png'))
end