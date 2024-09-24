%% pipeline
% 1 fxn - specify ephys code and view emg channels
% 1 fxn (trim) - specify which emg channel to use, ginput prompt to select points
% 1 fxn to find+plot peaks (find max peak, get 80-90% of that then plot)
% % 1 fxn to speficy ms before/after peak (convert to time domain here?)
%  % plot all epochs -> PPT
% average epochs, get labels, plot on top

load C:\Users\Miocinovic_lab\Desktop\mssison\ORdata_copies_MS\ephys053\f26_RT1D-5.000F0014__SSEP__Larm__6mA_preprocessed_MS.mat

%% Visualize the signals in 'emg' 
fig1 = figure; % prepare figure container
fig1.Position([3 4]) = [560*3 420*2]; % adjust fig width & height
tiles = tiledlayout(4,2,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor'); % length(emg_labels) = 8

for e = 1:length(emg_labels)
    nexttile
    emg_signal = emg(e,:);
    plot(emg_signal)
    title("emg("+e+",:)")
end
%%
% Select emg(4,:)
emg_signal = emg(4,:);

fig2 = figure;
fig2.Position([3 4]) = [560*3 420]; % adjust fig width & height
plot(emg_signal)

% Trim 'emg_segment'
signal_start_idx = 1932710;
signal_end_idx = 2716710;
emg_signal = emg_signal(signal_start_idx:signal_end_idx);

%% Approach 1: Use the 'findpeaks' function to detect artifact peaks in the 'emg' signal
min_prom =  1000; % set 'MinPeakProminence'
[peaks, pk_locs, pk_widths, pk_proms] = findpeaks(emg_signal,'MinPeakProminence',min_prom); 

% Plot the peaks
fig3 = figure;
fig3.Position([3 4]) = [560*3 420]; % adjust fig width & height
findpeaks(emg_signal,'MinPeakProminence',min_prom);
 
%
samples_per_ms = sampling_rate_ecog/1000;

pre_pk_ms = 20; % in ms
pre_pk_len = pre_pk_ms*samples_per_ms;

epoch_ms = 200; % in ms
epoch_len = epoch_ms*samples_per_ms;

mean_epochs = zeros(length(ecog_labels),epoch_len+1);
for e = 1:length(ecog_labels)
    
    ecog_signal = ecog(e,signal_start_idx:signal_end_idx);

    epochs_per_chan = zeros(length(pk_locs),epoch_len+1);
    for p = 1:length(pk_locs)
        pk_loc = pk_locs(p);

        epoch_start_idx = pk_loc-pre_pk_len;
        epoch_end_idx = epoch_start_idx+epoch_len;
        epoch = ecog_signal(epoch_start_idx:epoch_end_idx);

        epochs_per_chan(p,:) = epoch;
        mean_epoch = mean(epochs_per_chan,1);
    end
    
    mean_epochs(e,:) = mean_epoch;

end

n_rows = 4;
n_columns = 3;
n_tiles = n_rows*n_columns;

quotient = floor(length(ecog_labels)/n_tiles);
for q = 1:quotient

    chan_range = [(q-1)*n_tiles+1 q*n_tiles];

    range_start = chan_range(1);
    range_end = chan_range(2);

    fig(q) = figure;
    tiles = tiledlayout(n_rows,n_columns,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
           
    fig(q).WindowState = 'maximized'; % maximize window
    
    for r = range_start:range_end
        nexttile
        plot(mean_epochs(r,:))
        title("ecog = "+r)
        ylim([-300 200])
    end
end

m = mod(length(ecog_labels),n_tiles);

chan_range = [length(ecog_labels)-m+1 length(ecog_labels)];

range_start = chan_range(1);
range_end = chan_range(2);

fig(m+1) = figure;
tiles = tiledlayout(n_rows,n_columns,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');

fig(m+1).WindowState = 'maximized'; % maximize window

for r = range_start:range_end
    nexttile
    plot(mean_epochs(r,:))
    title("ecog = "+r)
    ylim([-300 200])
end
% 
% if makeppt == 1
%     n_epochs = length(pk_locs);
% 
%     n_rows = input(['n epochs = ' num2str(n_epochs) '. n rows = ']);
%     n_cols = input(['n epochs = ' num2str(n_epochs) '. n columns = ']);
%     n_tiles = n_rows*n_cols;
% 
%     quotient = floor(n_epochs/n_tiles);
% 
%     max_yval = max(epoch_tensor,[],"all");
%     min_yval = min(epoch_tensor,[],"all");
% 
%     for c = 1:n_chans
%         chan = squeeze(epoch_tensor(c,:,:));
% 
%         for q = 1:quotient
% 
%             epoch_set = [(q-1)*n_tiles+1 q*n_tiles];
% 
%             epoch_set_first = epoch_set(1);
%             epoch_set_last = epoch_set(2);
% 
%             fig(q) = figure;
%             tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
%             ylabel(tiles, "Amplitude (µV)")
%             xlabel(tiles, "Time w.r.t. stimulus onset (ms)")
% 
%             fig(q).WindowState = 'maximized'; % maximize window
% 
%             for e = epoch_set_first:epoch_set_last
%                 nexttile
% 
%                 xaxis_ms = start_time:1/samples_per_ms:end_time;
% 
%                 plot(xaxis_ms, chan(e,:))
% 
%                 xlim([start_time end_time])
%                 ylim([min_yval max_yval])
% 
%                 title("channel = "+c+", epoch = "+e)
%             end
%         end % for q = 1:quotient
% 
%     end % c = 1:n_chans
% 
%     m = mod(n_epochs, n_tiles);
%     if m ~= 0
%         epoch_set = [n_tiles-m+1 n_tiles];
% 
%         epoch_set_first = epoch_set(1);
%         epoch_set_last = epoch_set(2);
% 
%         fig(m+1) = figure;
%         tiles = tiledlayout(n_rows,n_cols,'TileSpacing','Compact','Padding','Compact','TileIndexing','columnmajor');
% 
%         fig(m+1).WindowState = 'maximized'; % maximize window
% 
%         for s = epoch_set_first:epoch_set_last
%             nexttile
%             plot(signal2plot(s,:))
%             if signaltype == "emg"
%                 title(signaltype+"("+s+",:) - "+emg_labels(s))
%             else 
%             end
%         end
%     end
% end
