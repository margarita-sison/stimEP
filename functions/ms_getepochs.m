function [start_time, end_time, epoch_tensor] = ms_getepochs(signal2epoch, timewindow, pk_locs, start_idx, end_idx, fs)
%function [epoch_tensor, ppt] = ms_getepochs(signal2epoch, timewindow, fs, makeppt)
% version without visualization

% Function
% --------
% Add description
% 
% Input arguments
% ---------------
% signal2epoch (variable)        - signal to epoch, e.g. ecog
% timewindow (1x2 double)       - milliseconds before and after peak, e.g. [-20 200]
% fs (double)                   - sampling rate of signal to epoch
% makeppt (logical)             - generates a ppt containing all the epochs if makeppt == 1
%
% Output Arguments
% ----------------
% epoch_tensor (3-dim double)   - 
% ppt

% Note: Try to integrate EEGLAB function to view epochs 
n_chans = size(signal2epoch,1);

samples_per_ms = fs/1000;

start_time = timewindow(1);
pre_peak_len = start_time*samples_per_ms;

end_time = timewindow(2);
post_peak_len = end_time*samples_per_ms;

epoch_tensor = zeros(n_chans, length(pk_locs), length(pre_peak_len:post_peak_len));

for c = 1:n_chans
    chan = signal2epoch(c,start_idx:end_idx);
    
    for p = 1:length(pk_locs)
        pk_loc = pk_locs(p);
        
        if pk_loc+pre_peak_len < 1 || pk_loc+post_peak_len > length(chan)
            continue
        end

        epoch = chan(pk_loc+pre_peak_len:pk_loc+post_peak_len);
        epoch_tensor(c,p,:) = epoch;
    end
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