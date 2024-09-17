function ms_plotsignals(datadir, ephys, signaltype)
% Function
% --------
% Add description
% 
% Input arguments
% ---------------
% datadir (char or str)     - path to folder containing ORdata copies
% ephys (char or str)       - ephys code, e.g. "ephys001")
% signaltype (char or str)  - signal type to plot, e.g. emg or ecog
%%
%addpath("C:\Users\Miocinovic_lab\Documents\mssison\GitHub\stimEP\functions\")
cd(strcat(datadir,ephys,"preprocessed"))
[ssep_file, ssep_fileloc, ssep_fileidx] = uigetfile;
load(strcat(ssep_fileloc,ssep_file))

%%
if signaltype == "ecog"
    signal2plot = ecog;
elseif signaltype == "emg"
    signal2plot = emg;
elseif signaltype == "lfp"
    signal2plot = lfp;
end

%%
n_chans = size(signal2plot,1);

n_rows = input(['n channels = ' num2str(n_chans) '. n rows = ']);
n_cols = input(['n channels = ' num2str(n_chans) '. n columns = ']);
n_tiles = n_rows*n_cols;

quotient = floor(n_chans/n_tiles);

for q = 1:quotient

    chan_set = [(q-1)*n_tiles+1 q*n_tiles];

    chan_set_first = chan_set(1);
    chan_set_last = chan_set(2);

    fig(q) = figure;
    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
           
    fig(q).WindowState = 'maximized'; % maximize window
    
    for s = chan_set_first:chan_set_last
        nexttile
        plot(signal2plot(s,:))
        if signaltype == "emg"
            title(signaltype+"("+s+",:) - "+emg_labels(s))
        else 
        end
    end
end

m = mod(size(signal2plot,1),n_tiles);
if m ~= 0
    chan_set = [n_tiles-m+1 n_tiles];
    
    chan_set_first = chan_set(1);
    chan_set_last = chan_set(2);
    
    fig(m+1) = figure;
    tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
    
    fig(m+1).WindowState = 'maximized'; % maximize window
    
    for s = chan_set_first:chan_set_last
        nexttile
        plot(signal2plot(s,:))
        if signaltype == "emg"
            title(signaltype+"("+s+",:) - "+emg_labels(s))
        else 
        end
    end
end
end