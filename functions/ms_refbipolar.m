function struct = ms_refbipolar(struct, signal2reref)

signal_matrix = struct.(signal2reref);
n_chans = size(signal_matrix,1);

if strcmp(signal2reref, 'ecog')
    monopolar_subsets = {1:n_chans/2 n_chans/2+1:n_chans}; % split channels into 2 equal sets
    bipolar_subsets = {1:(n_chans/2)-1 n_chans/2:n_chans-2}; % for indexing later on
    bipolar_chans = zeros(size(signal_matrix,1)-2, size(signal_matrix,2));
elseif strcmp(signal2reref, 'lfp')
    monopolar_subsets = {1:n_chans};
    bipolar_subsets = {1:n_chans-1};
    bipolar_chans = zeros(size(signal_matrix,1)-1, size(signal_matrix,2));
end

for s = 1:length(monopolar_subsets)
    monopolar_subset = monopolar_subsets{s};
    bipolar_subset = bipolar_subsets{s};

    signal_monopolar_subset = signal_matrix(monopolar_subset,:);
    signal_bipolar_subset = diff(signal_monopolar_subset);
    bipolar_chans(bipolar_subset,:) = signal_bipolar_subset;
end

struct.(append(signal2reref,'_bipolar')) = bipolar_chans;
end
      
