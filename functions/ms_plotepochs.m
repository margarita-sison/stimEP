function ms_plotepochs(struct, epochs2plot)

ephys_code = struct.ephys_code;
ephys_folder = struct.ephys_folder;
epochs2plot = struct.(epochs2plot);

epochs_folder = append(ephys_folder,'/epochs');
if ~isfolder(epochs_folder)
    mkdir(epochs_folder)
end

n_chans = size(epochs2plot,1);
n_epochs = size(epochs2plot,2);

n_rows = input(['There are ' num2str(n_epochs) ' epochs to plot. Specify n rows: ']); % prompts user to select number of rows for the tiled figure given the number of channels
n_cols = input(['There are ' num2str(n_epochs) ' epochs to plot. Specify n columns: ']); % prompts user to select number of columns for the tiled figure given the number of channels
n_tiles = n_rows*n_cols;

quotient = floor(n_epochs/n_tiles);

for c = 1:n_chans
    epochs_per_chan = squeeze(epochs2plot(c,:,:));

    for q = 1:quotient
        epoch_set = [(q-1)*n_tiles+1 q*n_tiles];
        epoch_set_first = epoch_set(1);
        epoch_set_last = epoch_set(2);

        fig(q) = figure('visible','off','Units','normalized','OuterPosition',[0 0 1 1]);

        tiles = tiledlayout(n_rows,n_cols,'TileSpacing','compact','Padding','compact','TileIndexing','columnmajor');
        title(tiles, append(ephys_code,' - epochs'),'FontWeight','bold')
        xlabel(tiles, "Sampling units (a.u.)"), ylabel(tiles, "Amplitude (µV)")

        for e = epoch_set_first:epoch_set_last  
            nexttile
            epoch2plot = epochs_per_chan(e,:);
            plot(epoch2plot)
            xlim([size(epoch2plot,1) size(epoch2plot,2)])
            title(("channel = "+c+", epoch = "+e))
        end

        saveas(fig, append(epochs_folder,'/',ephys_code,'_chan',num2str(c),'_epochs',num2str(epoch_set_first),'-',num2str(epoch_set_last)))
    end
    
    m = mod(n_epochs,n_tiles);
    
    if m~=0
        epoch_set = [n_tiles-m+1 n_tiles];
        epoch_set_first = epoch_set(1);
        epoch_set_last = epoch_set(2);

        fig(q) = figure('visible','off','Units','normalized','OuterPosition',[0 0 1 1]);

        tiles = tiledlayout(n_rows,n_cols,'TileSpacing','compact','Padding','compact','TileIndexing','columnmajor');
        title(tiles, append(ephys_code,' - epochs'),'FontWeight','bold')
        xlabel(tiles, "Sampling units (a.u.)"), ylabel(tiles, "Amplitude (µV)")
        
        for e = epoch_set_first:epoch_set_last  
            nexttile
            epoch2plot = epochs_per_chan(e,:);
            plot(epoch2plot)
            xlim([size(epoch2plot,1) size(epoch2plot,2)])
            title(("channel = "+c+", epoch = "+e))
        end

        saveas(fig, append(epochs_folder,'/',ephys_code,'_chan',num2str(c),'_epochs',num2str(epoch_set_first),'-',num2str(epoch_set_last)))
    end
end
end
