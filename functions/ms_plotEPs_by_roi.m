function ms_plotEPs_by_roi(MS_STRUCT, roi_order)

% Function
% --------
% Plots average evoked potentials by brain region (e.g., primary motor cortex)
% 
% Input arguments
% ---------------
% ms_struct (struct)            - struct containing:
%       ephys (char)            : ephys code, e.g. 'ephys001'
%       rois (1xr cell)         : brain regions of interest
%       timewindow (1x2 double) : milliseconds before and after stimulus onset, e.g. [-20 200]
%       fs (double)             : sampling rate of signals (samples per second)
%       EPs_by_roi (rxn double) : matrix of evoked potentials averaged by brain region; r = number of unique brain regions, n = sample points
% roi_order (1xr double)        - order of rois to plot, e.g. [3 1 2 4] (check 'rois' cell array first)
%
% Output
% ------
% Figure displaying evoked potentials and accompanying labels

%% Prepare region-specific colors for plotting
rois = MS_STRUCT.rois; % roi/s = region/s of interest

colorpalette = {"#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" ...
    "#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" ...
    "#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"};
roi_colors = {}; 

for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end

%% Prepare x-axis values in ms
start_time = MS_STRUCT.timewindow(1); % start time in ms
end_time = MS_STRUCT.timewindow(2); % end time in ms

samples_per_ms = MS_STRUCT.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

%% Plot the EPs
EPs_by_roi = MS_STRUCT.EPs_by_roi;
figure;
%fig.WindowState = 'maximized';

counter = 0; % used together with vertical 'offset'
offset = max(EPs_by_roi,[],"all"); % to plot signals on top of each other on the same axes

ytick_vals = [];
ytick_labels = {};

for r = 1:size(EPs_by_roi, 1);%roi_order
    EP_by_roi = EPs_by_roi(r,:);
   
    yvals = EP_by_roi+offset*counter*2; % to plot signals on top of each other on the same axes

    % poststim_peaks = ms_struct.poststim_peaks_all{r};
    % idcs = [];
    % for p = 1:length(poststim_peaks)
    %     [~,idx] = min(abs(EP_by_roi-poststim_peaks(p)));
    %     idcs = [idcs idx];
    % end

    %plot(xaxis_ms, yvals, '-', 'Marker', "|", 'MarkerIndices', idcs, 'MarkerSize', 30, 'MarkerEdgeColor', "#000080", 'MarkerFaceColor', "#000080")
    plot(xaxis_ms, yvals)
    ytick_vals = [ytick_vals yvals(1)];
    ytick_labels = [ytick_labels rois{r}];

    counter = counter+1;
    hold on
end
hold off 
xlim([start_time end_time])
ylim([min(EPs_by_roi(1,:)) offset*counter*2])
yticks(round(ytick_vals))
yticklabels(ytick_labels)
set(gca,'TickLabelInterpreter','none')

title(MS_STRUCT.ephys,'FontWeight','bold')
xlabel("Time w.r.t. stimulus onset (ms)")

end