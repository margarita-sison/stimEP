function ms_plotsignals(datadir, ephys, signaltype)
% Function
% --------
% Plots all signals of a signal type for visual inspection
% 
% Input arguments
% ---------------
% datadir (char or str) - path to folder containing ORdata copies
% ephys (char or str)   - ephys code, e.g. "ephys001")
% signaltype (variable) - signal type to plot, e.g. "ecog" or "emg"
% 
% Output
% ------
% Figure showing the plotted signals

%% Load SSEP file to base workspace
cd(strcat(datadir,ephys,"preprocessed")) % set current directory
[ssep_file, ssep_fileloc, ssep_fileidx] = uigetfile; % prompts user to select SSEP-containing file
filepath = strcat(ssep_fileloc,ssep_file); 
load(filepath) % load SSEP file to base workspace

%load2base = sprintf('load(''%s'')', filepath);
%evalin('base', load2base) % does the same as load(filepath)

%% Extract signal variable to plot given signal type specified by user
if signaltype == "ecog"
    signal2plot = ecog;
elseif signaltype == "emg"
    signal2plot = emg;
elseif signaltype == "lfp"
    signal2plot = lfp;
else
    error('Signal type not recognized. Recognized signal types: "ecog", "emg", "lfp".')
end

%% Set up plotting configuration 
n_chans = size(signal2plot,1); % number of channels

n_rows = input(['n channels = ' num2str(n_chans) '. n rows = ']); % prompts user to select number of rows for the tiled figure given the number of channels
n_cols = input(['n channels = ' num2str(n_chans) '. n columns = ']); % prompts user to select number of columns for the tiled figure given the number of channels
n_tiles = n_rows*n_cols; % total number of tiles

%% Plot the signals
quotient = floor(n_chans/n_tiles); % for figure formatting purposes; quotient = number of figures that will have complete number of rows and columns specified

for q = 1:quotient

    chan_set = [(q-1)*n_tiles+1 q*n_tiles]; % set of channels that will be plotted on the current figure
    chan_set_first = chan_set(1); % first channel in the set
    chan_set_last = chan_set(2); % last channel in the set

    %%% preparing fig container 
    fig(q) = figure; 

    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    xlabel(tiles, "Sampling units (a.u.)")       
    ylabel(tiles, "Amplitude (µV)")

    fig(q).WindowState = 'maximized'; % maximize window
    %%%

    for s = chan_set_first:chan_set_last
        nexttile
        plot(signal2plot(s,:)) 

        if signaltype == "emg"
            title(signaltype+"("+s+",:) - "+emg_labels(s))
        end

    end
end

%% If number of channels is odd, there will be some leftover channels to plot:
m = mod(size(signal2plot,1),n_tiles);

if m ~= 0
    chan_set = [n_tiles-m+1 n_tiles];
    chan_set_first = chan_set(1);
    chan_set_last = chan_set(2);
    
    %%% preparing fig container 
    fig(m+1) = figure;

    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    xlabel(tiles, "Sampling units (a.u.)")       
    ylabel(tiles, "Amplitude (µV)")
    
    fig(m+1).WindowState = 'maximized'; % maximize window
    %%%

    for s = chan_set_first:chan_set_last
        nexttile
        plot(signal2plot(s,:))

        if signaltype == "emg"
            title(signaltype+"("+s+",:) - "+emg_labels(s))
        end
        
    end
end
end