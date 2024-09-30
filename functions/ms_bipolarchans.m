function ecog_bipolar = ms_bipolarchans(ecog)

n_chans = size(ecog,1);
chan_subsets = {1:n_chans/2 n_chans/2+1:n_chans}; % split channels into 2 equal sets
chan_subsets_bipolar = {1:(n_chans/2)-1 n_chans/2:n_chans-2}; % for indexing later on

ecog_bipolar = zeros(size(ecog,1)-2, size(ecog,2));

for s = 1:length(chan_subsets)
    chan_subset = chan_subsets{s};
    chan_subset_bipolar = chan_subsets_bipolar{s};

    ecog_subset = ecog(chan_subset,:);
    ecog_subset_bipolar = diff(ecog_subset);
    ecog_bipolar(chan_subset_bipolar,:) = ecog_subset_bipolar;
end

end
      
