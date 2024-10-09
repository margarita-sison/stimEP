function struct = ms_refbipolar(struct, signal_type)

signal_matrix = struct.(signal_type);
n_chans = size(signal_matrix,1);

monopolar_subsets = {1:n_chans/2 n_chans/2+1:n_chans}; % split channels into 2 equal sets
bipolar_subsets = {1:(n_chans/2)-1 n_chans/2:n_chans-2}; % for indexing later on

bipolar_chans = zeros(size(signal_matrix,1)-2, size(signal_matrix,2));

for s = 1:length(monopolar_subsets)
    monopolar_subset = monopolar_subsets{s};
    bipolar_subset = bipolar_subsets{s};

    signal_monopolar_subset = signal_matrix(monopolar_subset,:);
    signal_bipolar_subset = diff(signal_monopolar_subset);
    bipolar_chans(bipolar_subset,:) = signal_bipolar_subset;
end

struct.(append(signal_type,'_bipolar')) = bipolar_chans;
end
      
