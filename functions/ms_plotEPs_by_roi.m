function ms_plotEPs_by_roi(ep_dir, montage, ms_struct, roi_order)
%% Prepare region-specific colors for plotting
rois = ms_struct.rois; % roi/s = region/s of interest

colorpalette = {"#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" ...
    "#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" ...
    "#0072BD" "#D95319"	"#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"};
roi_colors = {}; 

for r = 1:length(rois)
    roi_color = colorpalette{r};
    roi_colors{r} = roi_color;
end

%% Prepare x-axis values in ms
start_time = ms_struct.timewindow(1); % start time in ms
end_time = ms_struct.timewindow(2); % end time in ms

samples_per_ms = ms_struct.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

%% Plot the EPs
% n_rows = length(rois);
% n_cols = 1;

%tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact');

fig = figure;
fig.WindowState = 'maximized';

counter = 0; % used together with vertical 'offset'
offset = max(EPs_by_roi,[],"all"); % to plot signals on top of each other in 1 tile

ytick_vals = [];
ytick_labels = {};

for r = 1:size(EPs_by_roi,1)
    EP_by_roi = EPs_by_roi(r,:);
   
    yvals = EP_by_roi+offset*counter; % to plot signals on top of each other in 1 tile

    poststim_peaks = MS_STRUCT.poststim_peaks_all{r};
    idcs = [];
    for p = 1:length(poststim_peaks)
        [~,idx] = min(abs(EP_by_roi-poststim_peaks(p)));
        idcs = [idcs idx];
    end

    plot(xaxis_ms, yvals, '-', 'Marker', "|", 'MarkerIndices', idcs, 'MarkerSize', 72, 'MarkerEdgeColor', "r", 'MarkerFaceColor', "r")

    ytick_vals = [ytick_vals yvals(1)];
    ytick_labels = [ytick_labels rois{r}];

    counter = counter+1;
    hold on
end
hold off 
xlim([start_time end_time])
ylim([min(EPs_by_roi(1,:)) offset*counter])
yticks(round(ytick_vals))
yticklabels(ytick_labels)

end