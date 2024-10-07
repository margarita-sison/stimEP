function ms_plotemg(ephys, emg, emg_labels)
% Function
% --------
% Plots all EMG signals for a visual inspection
% 
% Input arguments
% ---------------
% ephys (char or str)   - ephys code, e.g. "ephys001"
% emg (nxm double)      - matrix of EMG signals to plot; m = number of EMG channels, n = sample points
% emg_labels (1xn cell) - cell array of channel labels
% 
% Output
% ------
% Saves figure/s showing the plotted signals

%% 
disp('Select stimEP_outputs folder as save location:')
output_folder = uigetdir;

%% Set up tiling configuration 
n_chans = size(emg,1); % number of channels

n_rows = input(['There are ' num2str(n_chans) ' channels to plot. Specify n rows: ']); % prompts user to select number of rows for the tiled figure given the number of channels
n_cols = input(['There are ' num2str(n_chans) ' channels to plot. Specify n columns: ']); % prompts user to select number of columns for the tiled figure given the number of channels

n_tiles = n_rows*n_cols; % total number of tiles

%% Plot the signals
quotient = floor(n_chans/n_tiles); % for figure formatting purposes; quotient = number of figures that will have complete number of rows and columns specified

for q = 1:quotient
    chan_set = [(q-1)*n_tiles+1 q*n_tiles]; % set of channels that will be plotted on the current figure
    chan_set_first = chan_set(1); % first channel in the set
    chan_set_last = chan_set(2); % last channel in the set

    %%% prepare fig container here
    fig(q) = figure; 

    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    ephys = char(ephys);
    title(tiles,ephys,'FontWeight','bold')
    xlabel(tiles, "Sampling units (a.u.)"), ylabel(tiles, "Amplitude (µV)")

    fig(q).WindowState = 'maximized'; % maximize window
    %%%

    for s = chan_set_first:chan_set_last
        nexttile
        plot(emg(s,:)) 
        
        title("emg("+s+",:) - "+emg_labels(s))
    end

    saveas(fig, append(output_folder,'/',ephys,'_emg.png'))
end

%% If number of channels is odd, there will be some leftover channels to plot:
m = mod(size(emg,1),n_tiles);

if m ~= 0
    chan_set = [n_tiles-m+1 n_tiles]; % set of channels that will be plotted on the current figure
    chan_set_first = chan_set(1); % first channel in the set
    chan_set_last = chan_set(2); % last channel in the set
    
    %%% prepare fig container  here
    fig(m+1) = figure;

    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    ephys = char(ephys);
    title(tiles,ephys,'FontWeight','bold')
    xlabel(tiles, "Sampling units (a.u.)"), ylabel(tiles, "Amplitude (µV)")
    
    fig(m+1).WindowState = 'maximized'; % maximize window
    %%%

    for s = chan_set_first:chan_set_last
        nexttile
        plot(emg(s,:))

        title(emg+"("+s+",:) - "+emg_labels(s))
    end

    saveas(fig, append(output_folder,'/',ephys,'_emg.png'))
end
end